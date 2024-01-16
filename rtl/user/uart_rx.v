module uart_receive (
           input wire        rst_n,
           input wire        clk,
           input wire [31:0] clk_div,
           input wire        rx,
           output reg        irq,
           output wire [7:0]  rx_data,
           output reg        frame_err,
           output reg        busy,
           input wire        i_rx_valid,
           output wire       o_rx_full,
           output wire       o_rx_empty,
           input wire        irq_clear
       );

parameter WAIT        = 4'b0000;
parameter START_BIT   = 4'b0001;
parameter GET_DATA    = 4'b0010;
parameter STOP_BIT    = 4'b0011;
parameter WAIT_READ   = 4'b0100;
parameter FRAME_ERR   = 4'b0101;
parameter IRQ         = 4'b0110;
parameter FIFO   = 4'b0111;

//wire [31:0] WAIT_IRQ = clk_div * 20;
wire [31:0] WAIT_IRQ = clk_div * 20;

reg [3:0] state_w, state_r;

reg [31:0] clk_cnt_w, clk_cnt_r;

reg [2:0] rx_index_w, rx_index_r;

reg irq_w;
reg frame_err_w;
reg busy_w;
reg [7:0] rx_data_w, rx_data_r;

reg fifo_ivalid;
wire fifo_full_b, fifo_full;
reg [7:0] fifo_idata;
wire fifo_ovalid;
wire fifo_oready;
wire [7:0] fifo_odata;
wire fifo_empty;

reg [31:0] wait_cnt_w, wait_cnt_r;

assign fifo_oready = i_rx_valid;
assign rx_data = fifo_odata;
assign fifo_full = !fifo_full_b;
assign o_rx_full = fifo_full;
assign o_rx_empty = fifo_empty;

reg irq_en_w, irq_en_r;

sync_fifo  rx_fifo(
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
    state_w     = state_r;
    clk_cnt_w   = clk_cnt_r;
    rx_index_w  = rx_index_r;
    irq_w       = irq;
    rx_data_w   = rx_data_r;
    frame_err_w = frame_err;
    busy_w      = busy;
    fifo_ivalid = 1'b0;
    fifo_idata  = 8'h0;
    wait_cnt_w  = wait_cnt_r;

    case(state_r)
        WAIT: begin
            irq_w = 1'b0;
            frame_err_w = 1'b0;
            busy_w = 1'b0;
            rx_data_w = 8'b0;
            wait_cnt_w = wait_cnt_r + 1;
            if(rx == 1'b0) begin // Start bit detected
                state_w = START_BIT;
                wait_cnt_w = 32'h0000_0000;
            end

            else if (wait_cnt_r == WAIT_IRQ && !fifo_empty && irq_en_r) begin
                state_w = IRQ;
                wait_cnt_w = 32'h0000_0000;
            end
        end
        START_BIT: begin
            // Check middle of start bit to make sure it's still low
            if(clk_cnt_r == ((clk_div >> 1) - 1)) begin
                clk_cnt_w = 32'h0000_0000;
                if(rx == 1'b0) begin
                    state_w = GET_DATA;
                end
            end else begin
                clk_cnt_w = clk_cnt_r + 32'h0000_0001;
            end
            busy_w = 1'b1;
        end
        GET_DATA: begin
            // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
            if(clk_cnt_r == (clk_div - 1)) begin
                clk_cnt_w = 32'h0000_0000;
                if(rx_index_r == 3'b111) begin
                    state_w = STOP_BIT;
                end
                rx_index_w = rx_index_r + 3'b001;
                rx_data_w[rx_index_r] = rx;
                //$display("rx data bit index:%d %b", rx_index, rx_data_r[rx_index]);
            end else begin
                clk_cnt_w = clk_cnt_r + 32'h0000_0001;
            end
            busy_w = 1'b1;
        end
        STOP_BIT: begin
            // Receive Stop bit.  Stop bit = 1
            if(clk_cnt_r == (clk_div - 1)) begin
                clk_cnt_w = 32'h0000_0000;
                if(rx == 1'b1) begin
                    state_w = FIFO;//WAIT_READ;
                    frame_err_w = 1'b0;
                    fifo_idata  = rx_data_r;
                    fifo_ivalid = 1'b1;
                end else begin
                    state_w = FRAME_ERR;
                    frame_err_w = 1'b1;
                end
            end else begin
                clk_cnt_w = clk_cnt_r + 32'h0000_0001;
            end
            busy_w = 1'b1;
        end
        IRQ:begin
            irq_w = 1'b1;
            state_w = WAIT;
            busy_w = 1'b0;
        end
        FIFO:begin
            if(fifo_full && irq_en_r) begin
                state_w = IRQ;
            end
            else begin
                state_w = WAIT;
            end
        end
        FRAME_ERR:begin
            state_w = WAIT;
            irq_w = 0;
            frame_err_w = 0;
            busy_w = 1'b0;
        end
        default: begin
            state_w     = WAIT;
            clk_cnt_w   = 32'h0000_0000;
            rx_index_w  = 3'b000;
            irq_w       = 1'b0;
            rx_data_w   = 8'h0;
            frame_err_w = 1'b0;
            busy_w      = 1'b0;
        end
    endcase
end

always @(*) begin
    irq_en_w = irq_en_r;
    if(state_r == IRQ) begin
        irq_en_w = 1'b0;
    end

    if (irq_clear == 1'b1) begin
        irq_en_w = 1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state_r     <= WAIT;
        clk_cnt_r   <= 32'h0000_0000;
        rx_index_r  <= 3'b000;
        irq       <= 1'b0;
        frame_err <= 1'b0;
        rx_data_r   <= 8'h0;
        busy      <= 1'b0;
        wait_cnt_r  <= 32'h0000_0000;
        irq_en_r    <= 1'b1;
    end else begin
        state_r     <= state_w;
        clk_cnt_r   <= clk_cnt_w;
        rx_index_r  <= rx_index_w;
        irq         <= irq_w;
        rx_data_r     <= rx_data_w;
        frame_err   <= frame_err_w;
        busy        <= busy_w;
        wait_cnt_r  <= wait_cnt_w;
        irq_en_r    <= irq_en_w;
    end
end

endmodule
