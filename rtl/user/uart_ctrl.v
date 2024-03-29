module ctrl(
           input wire        rst_n,
           input wire        clk,
           input wire        i_wb_valid,
           input wire [31:0] i_wb_adr,
           input wire        i_wb_we,
           input wire [31:0] i_wb_dat,
           input wire [3:0]  i_wb_sel,
           output reg        o_wb_ack,
           output reg [31:0] o_wb_dat,
           input wire [7:0]  i_rx,
           input wire        i_irq,
           input wire        i_rx_busy,
           input wire        i_frame_err,
           output reg [7:0]  o_tx,
           input wire        i_tx_start_clear,
           input wire        i_tx_busy,
           output reg        o_tx_start,
           output reg        o_rx_valid,
           input wire        i_rx_full,
           input wire        i_rx_empty,
           output reg        irq_clear
       );

// Declare the UART memory mapped registers address
localparam RX_DATA  = 32'h3100_0000;

localparam TX_DATA	= 32'h3100_0004;

localparam STAT_REG = 32'h3100_0008;

//+------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+
//|RX_DATA |  RESERVERD  |                        DATA BITS                              |
//|        |    31-8     |  7    |  6    |  5    |  4    |  3    |  2    |  1    |  0    |
//+------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+
//|TX_DATA |  RESERVERD  |                        DATA BITS                              |
//|        |    31-8     |  7    |  6    |  5    |  4    |  3    |  2    |  1    |  0    |
//+------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+
//|STAT_REG|  RESERVERD  |  Frame Err  |  Overrun Err  |  Tx_full  |  Tx_empty  |  Rx_full  |  Rx_empty |
//|        |    31-6     |  5          |  4            |  3        |  2         |  1        |  0        |
//+------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+

//reg [31:0] rx_buffer;
reg [31:0] tx_buffer;
reg [31:0] stat_reg;
reg tx_start_local;


reg [3:0] o_wb_state_w, o_wb_state_r;
reg [7:0] o_wb_dat_w;
reg o_wb_ack_w;
localparam IDLE = 4'b0000;
localparam RX = 4'b0001;
localparam TX = 4'b0010;


reg fifo_ivalid;
wire fifo_full_b, fifo_full;
reg [7:0] fifo_idata;
wire fifo_ovalid;
reg fifo_oready;
wire [7:0] fifo_odata;
wire fifo_empty;

reg o_tx_start_w;
reg[7:0] o_tx_w;
reg [4:0] tx_wait_cnt_r, tx_wait_cnt_w;

reg wb_pause_w, wb_pause_r;

wire debug_write = i_wb_valid && i_wb_we;

assign fifo_full = !fifo_full_b;

sync_fifo  tx_fifo(
               .clk(clk),
               .rst_n(rst_n),
               .ivalid(fifo_ivalid),
               .iready(fifo_full_b),
               .idata(fifo_idata),
               .ovalid(fifo_ovalid),
               .oready(fifo_oready),
               .odata(fifo_odata),
               .empty(fifo_empty)
           );


always @(*) begin
    o_wb_ack_w = 0;
    o_wb_dat_w = 0;
    o_wb_state_w = o_wb_state_r;
    o_rx_valid = 0;
    fifo_ivalid = 1'b0;
    fifo_idata = 8'h0;
    wb_pause_w = 0;
    irq_clear = 0;

    if(i_wb_valid && !i_wb_we && !wb_pause_r)begin
        wb_pause_w = 1'b1;
        case(i_wb_adr)
            RX_DATA:begin
                o_wb_state_w = RX;
                o_wb_dat_w = i_rx;
                o_wb_ack_w = 1'b1;
                o_rx_valid = 1'b1;
            end
            STAT_REG:begin
                o_wb_state_w = IDLE;
                o_wb_dat_w = stat_reg;
                o_wb_ack_w = 1'b1;
            end
            TX_DATA:begin
                o_wb_state_w = IDLE;
                o_wb_dat_w = 32'h00000000;
                o_wb_ack_w = 1'b1;
            end
        endcase
    end
    if(i_wb_valid && i_wb_we && i_wb_adr == TX_DATA && !wb_pause_r)begin
        o_wb_dat_w = 32'h00000000;
        o_wb_ack_w = 1'b1;
        fifo_ivalid = 1'b1;
        fifo_idata = i_wb_dat[7:0];
        wb_pause_w = 1'b1;
        irq_clear = 1'b1;
    end


end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        o_wb_state_r <= IDLE;
        o_wb_dat <= 32'h00000000;
        o_wb_ack <= 1'b0;
        wb_pause_r <= 1'b0;
    end else begin
        o_wb_state_r <= o_wb_state_w;
        o_wb_dat <= o_wb_dat_w;
        o_wb_ack <= o_wb_ack_w;
        wb_pause_r <= wb_pause_w;
    end
end


always @(*) begin
    o_tx_start_w = o_tx_start;
    o_tx_w = 8'h0;
    tx_wait_cnt_w = tx_wait_cnt_r;
    fifo_oready = 1'b0;
    if(i_tx_start_clear)begin
        o_tx_start_w = 1'b0;
        o_tx_w = 8'h0;
    end

    else if(!fifo_empty && !i_tx_busy)begin
        if(tx_wait_cnt_r == 7)begin
            o_tx_start_w = 1'b1;
            o_tx_w = fifo_odata;
            fifo_oready = 1'b1;
            tx_wait_cnt_w = 0;
        end
        else begin
            o_tx_start_w = o_tx_start;
            o_tx_w = o_tx;
            fifo_oready = 1'b0;
            tx_wait_cnt_w = tx_wait_cnt_r + 1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        o_tx_start <= 1'b0;
        o_tx <= 8'b0;
        tx_wait_cnt_r <= 0;
    end
    else begin
        o_tx_start <= o_tx_start_w;
        o_tx <= o_tx_w;
        tx_wait_cnt_r <= tx_wait_cnt_w;
    end
end

// always@(posedge clk or negedge rst_n)begin
//     if(!rst_n || i_tx_start_clear)begin
//         tx_buffer <= 32'h00000000;
//         tx_start_local <= 1'b0;
//     end else begin
//         if(i_wb_valid && i_wb_we && i_wb_adr==TX_DATA && !i_tx_busy)begin
//             tx_buffer <= i_wb_dat;
//             tx_start_local <= 1'b1;
//         end
//     end
// end
// always@(posedge clk or negedge rst_n)begin
//     if(!rst_n || i_tx_start_clear)begin
//         o_tx <= 8'b0;
//         o_tx_start <= 1'b0;
//     end else begin
//         o_tx <= tx_buffer[7:0];
//         o_tx_start <= tx_start_local;
//     end
// end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        stat_reg <= 32'h0000_0005;
    end else begin
        if(i_wb_valid && !i_wb_we)begin
            if(i_wb_adr==STAT_REG)
                stat_reg[5:4] <= 2'b00;
        end
        stat_reg[3:0] <= {fifo_full, fifo_empty, i_rx_full, i_rx_empty};

        // if(i_tx_busy)
        //     stat_reg[3:2] <= 2'b10;
        // else
        //     stat_reg[3:2] <= 2'b01;

        if(i_frame_err && i_rx_busy)
            stat_reg[5] <= 1'b1;
        // else if(i_irq && !stat_reg[1] && !i_frame_err)
        //     stat_reg[1:0] <= 2'b10;
        else if(i_rx_busy && stat_reg[1:0]==2'b10)
            stat_reg[4] <= 1'b1;
        // else if((i_wb_valid && i_wb_adr==RX_DATA && !i_wb_we && stat_reg[1:0]==2'b10) || i_frame_err)
        //     stat_reg[1:0] <= 2'b01;
    end
end






// always@(posedge clk or negedge rst_n)begin
//     if(!rst_n)begin
//         rx_buffer <= 32'h00000000;
//     end else begin
//         if(i_irq && !stat_reg[1] && !i_frame_err)begin
//             rx_buffer <= i_rx;
//             //$display("rx_buffer: %d", i_rx);
//         end
//     end
// end



// always@(posedge clk or negedge rst_n)begin
//     if(!rst_n)begin
//         o_rx_finish <= 1'b0;
//     end else begin
//         if((i_wb_valid && i_wb_adr==RX_DATA && !i_wb_we && stat_reg[1:0]==2'b10) || i_frame_err)
//             o_rx_finish <= 1'b1;
//         else
//             o_rx_finish <= 1'b0;
//     end
// end

// always@(posedge clk or negedge rst_n)begin
//     if(!rst_n || i_tx_start_clear)begin
//         o_tx <= 8'b0;
//         o_tx_start <= 1'b0;
//     end else begin
//         o_tx <= tx_buffer[7:0];
//         o_tx_start <= tx_start_local;
//     end
// end



endmodule
