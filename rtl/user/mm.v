`timescale 1ns / 1ps
module mm
       #(  parameter pADDR_WIDTH = 12,
           parameter pDATA_WIDTH = 32,
           parameter Tape_Num    = 11
        )
       (
           //axilite interface==============================
           //write(input)--
           output  reg                     awready,
           output  reg                      wready,
           input   wire                     awvalid,
           input   wire [(pADDR_WIDTH-1):0] awaddr,
           input   wire                     wvalid,
           input   wire [(pDATA_WIDTH-1):0] wdata,
           //read(output)---
           output  wire                     arready,
           input   wire                     rready,
           input   wire                     arvalid,
           input   wire [(pADDR_WIDTH-1):0] araddr,
           output  wire                     rvalid,
           output  wire [(pDATA_WIDTH-1):0] rdata,
           //stream slave (input data)=========================
           input   wire                     ss_tvalid,
           input   wire [(pDATA_WIDTH-1):0] ss_tdata,
           input   wire                     ss_tlast,
           output  reg                     ss_tready,
           //stream master (output data)=======================
           input   wire                     sm_tready,
           output  reg                     sm_tvalid,
           output  reg [(pDATA_WIDTH-1):0] sm_tdata,
           output  reg                     sm_tlast,

           // bram for tap RAM
           output  reg [3:0]               tap_WE,
           output  wire                     tap_EN,
           output  reg [(pDATA_WIDTH-1):0] tap_Di,
           output  reg [(pADDR_WIDTH-1):0] tap_A,
           input   wire [(pDATA_WIDTH-1):0] tap_Do,

           // bram for data RAM
           output  reg [3:0]               data_WE,
           output  wire                     data_EN,
           output  reg [(pDATA_WIDTH-1):0] data_Di,
           output  reg [(pADDR_WIDTH-1):0] data_A,
           input   wire [(pDATA_WIDTH-1):0] data_Do,

           input   wire                     axis_clk,
           input   wire                     axis_rst_n
       );
parameter idle=0,
          start = 1,
          compute=2,
          done=3;
reg [2:0] current_state,next_state;
reg ap_start,finish_input,ap_done;
reg [4:0]input_count;
reg [(pDATA_WIDTH-1):0] matrix_A [0:3][0:3] ;
reg [(pDATA_WIDTH-1):0] matrix_B [0:3][0:3] ;
reg [(pDATA_WIDTH-1):0] matrix_out [0:3][0:3] ;

wire [(pDATA_WIDTH-1):0] A0 ;
wire [(pDATA_WIDTH-1):0] A1 ;
wire [(pDATA_WIDTH-1):0] A2 ;
wire [(pDATA_WIDTH-1):0] A3 ;
wire [(pDATA_WIDTH-1):0] A4 ;
wire [(pDATA_WIDTH-1):0] A5 ;
wire [(pDATA_WIDTH-1):0] A6 ;
wire [(pDATA_WIDTH-1):0] A7 ;
wire [(pDATA_WIDTH-1):0] A8 ;
wire [(pDATA_WIDTH-1):0] A9 ;
wire [(pDATA_WIDTH-1):0] A10;
wire [(pDATA_WIDTH-1):0] A11;
wire [(pDATA_WIDTH-1):0] A12;
wire [(pDATA_WIDTH-1):0] A13;
wire [(pDATA_WIDTH-1):0] A14;
wire [(pDATA_WIDTH-1):0] A15;

wire [(pDATA_WIDTH-1):0] B0;
wire [(pDATA_WIDTH-1):0] B1;
wire [(pDATA_WIDTH-1):0] B2;
wire [(pDATA_WIDTH-1):0] B3;
wire [(pDATA_WIDTH-1):0] B4;
wire [(pDATA_WIDTH-1):0] B5;
wire [(pDATA_WIDTH-1):0] B6;
wire [(pDATA_WIDTH-1):0] B7;
wire [(pDATA_WIDTH-1):0] B8;
wire [(pDATA_WIDTH-1):0] B9;
wire [(pDATA_WIDTH-1):0] B10;
wire [(pDATA_WIDTH-1):0] B11;
wire [(pDATA_WIDTH-1):0] B12;
wire [(pDATA_WIDTH-1):0] B13;
wire [(pDATA_WIDTH-1):0] B14;
wire [(pDATA_WIDTH-1):0] B15;

assign A0  = matrix_A[0][0];
assign A1  = matrix_A[0][1];
assign A2  = matrix_A[0][2];
assign A3  = matrix_A[0][3];
assign A4  = matrix_A[1][0];
assign A5  = matrix_A[1][1];
assign A6  = matrix_A[1][2];
assign A7  = matrix_A[1][3];
assign A8  = matrix_A[2][0];
assign A9  = matrix_A[2][1];
assign A10 = matrix_A[2][2];
assign A11 = matrix_A[2][3];
assign A12 = matrix_A[3][0];
assign A13 = matrix_A[3][1];
assign A14 = matrix_A[3][2];
assign A15 = matrix_A[3][3];


assign B0  = matrix_B[0][0];
assign B1  = matrix_B[0][1];
assign B2  = matrix_B[0][2];
assign B3  = matrix_B[0][3];
assign B4  = matrix_B[1][0];
assign B5  = matrix_B[1][1];
assign B6  = matrix_B[1][2];
assign B7  = matrix_B[1][3];
assign B8  = matrix_B[2][0];
assign B9  = matrix_B[2][1];
assign B10 = matrix_B[2][2];
assign B11 = matrix_B[2][3];
assign B12 = matrix_B[3][0];
assign B13 = matrix_B[3][1];
assign B14 = matrix_B[3][2];
assign B15 = matrix_B[3][3];


//FSM
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
    begin
        current_state<=idle;
    end
    else
        current_state<=next_state;
end
always @(*) begin
    case (current_state)
        idle:
        begin
            if(ap_start)
                next_state=start;
            else
                next_state=idle;
        end
        start:
        begin
            if(input_count==31 && ss_tvalid && ss_tready)
                next_state=compute;
            else
                next_state=start;
        end
        compute:
        begin

            next_state=done;

        end
        done:
        begin
            if(sm_tready&& sm_tvalid)
                next_state=idle;
        end
    endcase
end
//control logic
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
        ap_start<=0;
    else if(awaddr==004&& wdata==1)
        ap_start<=1;
end
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
    begin
        input_count<=0;
    end
    else
    begin
        if(current_state==start&&ss_tready&&ss_tvalid)
            input_count<=input_count+1;
        else if(current_state==idle)
            input_count<=0;
    end
end

always@(posedge axis_clk) begin
    if(!axis_rst_n) begin
        awready <= 0;
    end else if(wvalid && awvalid) begin
        awready <= !awready;
    end else begin
        awready <= awready;
    end
end
always@(posedge axis_clk) begin
    if(!axis_rst_n) begin
        wready <= 0;
    end else if(wvalid && awvalid) begin
        wready <= !wready;
    end else begin
        wready <= wready;
    end
end

//datapath
//input
always @(posedge axis_clk ) begin
    if(input_count==0)
        matrix_A[0][0]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==1)
        matrix_A[0][1]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==2)
        matrix_A[0][2]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==3)
        matrix_A[0][3]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==4)
        matrix_A[1][0]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==5)
        matrix_A[1][1]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==6)
        matrix_A[1][2]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==7)
        matrix_A[1][3]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==8)
        matrix_A[2][0]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==9)
        matrix_A[2][1]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==10)
        matrix_A[2][2]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==11)
        matrix_A[2][3]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==12)
        matrix_A[3][0]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==13)
        matrix_A[3][1]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==14)
        matrix_A[3][2]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==15)
        matrix_A[3][3]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==16)
        matrix_B[0][0]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==17)
        matrix_B[0][1]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==18)
        matrix_B[0][2]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==19)
        matrix_B[0][3]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==20)
        matrix_B[1][0]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==21)
        matrix_B[1][1]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==22)
        matrix_B[1][2]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==23)
        matrix_B[1][3]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==24)
        matrix_B[2][0]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==25)
        matrix_B[2][1]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==26)
        matrix_B[2][2]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==27)
        matrix_B[2][3]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==28)
        matrix_B[3][0]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==29)
        matrix_B[3][1]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==30)
        matrix_B[3][2]<=ss_tdata;
end
always @(posedge axis_clk ) begin
    if(input_count==31)
        matrix_B[3][3]<=ss_tdata;
end
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
        matrix_out[0][0]<=0;
    else if(current_state==compute)
        matrix_out[0][0]<=matrix_A[0][0]*matrix_B[0][0]+matrix_A[0][1]*matrix_B[1][0]+matrix_A[0][2]*matrix_B[2][0]+matrix_A[0][3]*matrix_B[3][0];
    else if(current_state==idle)
        matrix_out[0][0]<=0;
end
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
        matrix_out[0][1]<=0;
    else if(current_state==compute)
        matrix_out[0][1]<=matrix_A[0][0]*matrix_B[0][1]+matrix_A[0][1]*matrix_B[1][1]+matrix_A[0][2]*matrix_B[2][1]+matrix_A[0][3]*matrix_B[3][1];
    else if(current_state==idle)
        matrix_out[0][1]<=0;
end
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
        matrix_out[0][2]<=0;
    else if(current_state==compute)
        matrix_out[0][2]<=matrix_A[0][0]*matrix_B[0][2]+matrix_A[0][1]*matrix_B[1][2]+matrix_A[0][2]*matrix_B[2][2]+matrix_A[0][3]*matrix_B[3][2];
    else if(current_state==idle)
        matrix_out[0][2]<=0;
end
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
        matrix_out[0][3]<=0;
    else if(current_state==compute)
        matrix_out[0][3]<=matrix_A[0][0]*matrix_B[0][3]+matrix_A[0][1]*matrix_B[1][3]+matrix_A[0][2]*matrix_B[2][3]+matrix_A[0][3]*matrix_B[3][3];
    else if(current_state==idle)
        matrix_out[0][3]<=0;
end
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
        matrix_out[1][0]<=0;
    else if(current_state==compute)
        matrix_out[1][0]<=matrix_A[1][0]*matrix_B[0][0]+matrix_A[1][1]*matrix_B[1][0]+matrix_A[1][2]*matrix_B[2][0]+matrix_A[1][3]*matrix_B[3][0];
    else if(current_state==idle)
        matrix_out[1][0]<=0;
end
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
        matrix_out[1][1]<=0;
    else if(current_state==compute)
        matrix_out[1][1]<=matrix_A[1][0]*matrix_B[0][1]+matrix_A[1][1]*matrix_B[1][1]+matrix_A[1][2]*matrix_B[2][1]+matrix_A[1][3]*matrix_B[3][1];
    else if(current_state==idle)
        matrix_out[1][1]<=0;
end
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
        matrix_out[1][2]<=0;
    else if(current_state==compute)
        matrix_out[1][2]<=matrix_A[1][0]*matrix_B[0][2]+matrix_A[1][1]*matrix_B[1][2]+matrix_A[1][2]*matrix_B[2][2]+matrix_A[1][3]*matrix_B[3][2];
    else if(current_state==idle)
        matrix_out[1][2]<=0;
end
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
        matrix_out[1][3]<=0;
    else if(current_state==compute)
        matrix_out[1][3]<=matrix_A[1][0]*matrix_B[0][3]+matrix_A[1][1]*matrix_B[1][3]+matrix_A[1][2]*matrix_B[2][3]+matrix_A[1][3]*matrix_B[3][3];
    else if(current_state==idle)
        matrix_out[1][3]<=0;
end
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
        matrix_out[2][0]<=0;
    else if(current_state==compute)
        matrix_out[2][0]<=matrix_A[2][0]*matrix_B[0][0]+matrix_A[2][1]*matrix_B[1][0]+matrix_A[2][2]*matrix_B[2][0]+matrix_A[2][3]*matrix_B[3][0];
    else if(current_state==idle)
        matrix_out[2][0]<=0;
end
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
        matrix_out[2][1]<=0;
    else if(current_state==compute)
        matrix_out[2][1]<=matrix_A[2][0]*matrix_B[0][1]+matrix_A[2][1]*matrix_B[1][1]+matrix_A[2][2]*matrix_B[2][1]+matrix_A[2][3]*matrix_B[3][1];
    else if(current_state==idle)
        matrix_out[2][1]<=0;
end
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
        matrix_out[2][2]<=0;
    else if(current_state==compute)
        matrix_out[2][2]<=matrix_A[2][0]*matrix_B[0][2]+matrix_A[2][1]*matrix_B[1][2]+matrix_A[2][2]*matrix_B[2][2]+matrix_A[2][3]*matrix_B[3][2];
    else if(current_state==idle)
        matrix_out[2][2]<=0;
end
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
        matrix_out[2][3]<=0;
    else if(current_state==compute)
        matrix_out[2][3]<=matrix_A[2][0]*matrix_B[0][3]+matrix_A[2][1]*matrix_B[1][3]+matrix_A[2][2]*matrix_B[2][3]+matrix_A[2][3]*matrix_B[3][3];
    else if(current_state==idle)
        matrix_out[2][3]<=0;
end
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
        matrix_out[3][0]<=0;
    else if(current_state==compute)
        matrix_out[3][0]<=matrix_A[3][0]*matrix_B[0][0]+matrix_A[3][1]*matrix_B[1][0]+matrix_A[3][2]*matrix_B[2][0]+matrix_A[3][3]*matrix_B[3][0];
    else if(current_state==idle)
        matrix_out[3][0]<=0;
end
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
        matrix_out[3][1]<=0;
    else if(current_state==compute)
        matrix_out[3][1]<=matrix_A[3][0]*matrix_B[0][1]+matrix_A[3][1]*matrix_B[1][1]+matrix_A[3][2]*matrix_B[2][1]+matrix_A[3][3]*matrix_B[3][1];
    else if(current_state==idle)
        matrix_out[3][1]<=0;
end
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
        matrix_out[3][2]<=0;
    else if(current_state==compute)
        matrix_out[3][2]<=matrix_A[3][0]*matrix_B[0][2]+matrix_A[3][1]*matrix_B[1][2]+matrix_A[3][2]*matrix_B[2][2]+matrix_A[3][3]*matrix_B[3][2];
    else if(current_state==idle)
        matrix_out[3][2]<=0;
end
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
        matrix_out[3][3]<=0;
    else if(current_state==compute)
        matrix_out[3][3]<=matrix_A[3][0]*matrix_B[0][3]+matrix_A[3][1]*matrix_B[1][3]+matrix_A[3][2]*matrix_B[2][3]+matrix_A[3][3]*matrix_B[3][3];
    else if(current_state==idle)
        matrix_out[3][3]<=0;
end
//axi-ss : input Din  use tready=1 to get the next input
// --------------------------------------------------------------------------------------------------------
// clk     :__/▔\__/▔\__/▔\__/▔\__/▔\__/▔\__/▔\__/▔\__/▔\__/▔\__/▔\__/▔\__/▔\__/▔\__
// tdata   :|x|0          |1         |2
// tvalid  :▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
// tlast   :_______________________________/▔▔\_______

// tready  :________/▔▔\______/▔▔\______/▔▔\____
// ---------------------------------------------------------------------------------------------------------
always @(posedge axis_clk or negedge axis_rst_n ) begin
    if(!axis_rst_n)
        ss_tready<='b0;
    else
    begin
        if(current_state==start)
        begin
            if(ss_tvalid)
                ss_tready<='b1;
        end
        else if(current_state==done)
        begin
            ss_tready<='b0;

        end
    end
end


//axi-sm :output Dout use sm_tvalid=1 to trasmit an answer
// --------------------------------------------------------------------------------------------------------
// clk     :__/▔\__/▔\__/▔\__/▔\__/▔\__/▔\__/▔\__/▔\__/▔\__/▔\__/▔\__/▔\__/▔\__/▔\__
// tready  :▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔

// tdata   :|x|0          |1         |2
// tvalid  :________/▔▔\______/▔▔\______/▔▔\____
// tlast   :_______________________________/▔▔\_______
// ---------------------------------------------------------------------------------------------------------


always @(*) begin
    sm_tdata=matrix_out[3][3];
end
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(!axis_rst_n)
        sm_tvalid<=0;
    else
    begin
        if(current_state==done)
        begin
            sm_tvalid<=1;
        end
        else
            sm_tvalid<=0;
    end
end

endmodule
