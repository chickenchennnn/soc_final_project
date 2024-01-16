`timescale 1ns / 1ps
module qsort
#(  parameter pADDR_WIDTH = 12,
    parameter pDATA_WIDTH = 32
)
(
    // axi lite
	// ap_start, ap_done, ap_idle
	// coef
	// len
    output  reg                      awready,
    output  reg                      wready,
    input   wire                     awvalid,
    input   wire [(pADDR_WIDTH-1):0] awaddr,
    input   wire                     wvalid,
    input   wire [(pDATA_WIDTH-1):0] wdata,
    output  reg                      arready,
    input   wire                     rready,
    input   wire                     arvalid,
    input   wire [(pADDR_WIDTH-1):0] araddr,
    output  reg                      rvalid,
    output  reg  [(pDATA_WIDTH-1):0] rdata, 
    
    // axi stream
	// data_in, data_out
    input   wire                     ss_tvalid, 
    input   wire [(pDATA_WIDTH-1):0] ss_tdata, 
    input   wire                     ss_tlast, 
    output  reg                      ss_tready, 
    input   wire                     sm_tready, 
    output  wire                     sm_tvalid, 
    output  wire [(pDATA_WIDTH-1):0] sm_tdata, 
    output  wire                     sm_tlast, 

    input   wire                     axis_clk,
    input   wire                     axis_rst_n
);

	wire [31:0] a0, a1, a2, a3, a4, a5, a6, a7, a8, a9;
	assign a0 = save_data[0];
	assign a1 = save_data[1];
	assign a2 = save_data[2];
	assign a3 = save_data[3];
	assign a4 = save_data[4];
	assign a5 = save_data[5];
	assign a6 = save_data[6];
	assign a7 = save_data[7];
	assign a8 = save_data[8];
	assign a9 = save_data[9];
	wire [31:0] b0, b1, b2, b3, b4, b5, b6, b7, b8, b9;
	assign b0 = save_data_11[0];
	assign b1 = save_data_11[1];
	assign b2 = save_data_11[2];
	assign b3 = save_data_11[3];
	assign b4 = save_data_11[4];
	assign b5 = save_data_11[5];
	assign b6 = save_data_11[6];
	assign b7 = save_data_11[7];
	assign b8 = save_data_11[8];
	assign b9 = save_data_11[9];

	// main FSM
	reg [2:0] current_state;
	reg [2:0] next_state;
	// parameter declaration
	parameter S_IDLE = 'd0;
	// input first 11 data
	parameter S_INPUT = 'd1;
	// get stream input data
	parameter S_CAL = 'd2;
	// calculate multiply, add and shift sram simultaneously
	parameter S_OUT = 'd3;
	// shift the pointer and stream output result
	parameter S_SHIFT = 'd4;
	parameter S_WAIT = 'd5;
	// reset all counter
	parameter S_WAIT_AP_DONE = 'd6;
	
	reg [31:0] pattern_count;
	// length
	reg [31:0] length;
	// ap_ctrl register
	reg ap_idle; 
	reg ap_done;
	reg ap_start;
	// ap_idle: r/w
	// set to 1 when reset
	// set to 0 when ao_start is sampled
	// set to 1 when process completed and last data is transfered
	always@(posedge axis_clk) begin
		if(!axis_rst_n) begin
			ap_idle <= 1;
		end else if (ap_start) begin
			ap_idle <= 0;
		end else if(rdata[1] && rvalid) begin
			ap_idle <= 1;
		end else begin
			ap_idle <= ap_idle;
		end
	end
	// ap_done: r/w
	// set to 0 when reset
	// set to 0 when ap_done is read
	// set to 1 when process completed and last data is transfered
	always@(posedge axis_clk) begin
		if(!axis_rst_n) begin
			ap_done <= 0;
		end else if(rdata[1] && rvalid)begin
			ap_done <= 0;
		end else if(current_state == S_WAIT_AP_DONE)begin
			ap_done <= 1;
		end else begin
			ap_done <= ap_done;
		end
	end
	
	// ap_start: read only
	// set to 1 by testbench means start proggram
	// set to 0 when 1 is observed
	always@(posedge axis_clk) begin
		if(!axis_rst_n) begin
			ap_start <= 0;
		end else begin
			if(awvalid && wvalid && awaddr == 12'h08)
				ap_start <= wdata[0];
			else if(ss_tready && ss_tvalid)
				ap_start <= 0;
			else
				ap_start <= ap_start;
		end
	end
	
	//------------------------------------------------------------AXI Lite Read--------------------------------------------------------
    // read channel
	parameter AXI_READ_IDLE = 2'd0;
	parameter AXI_READ_REG = 2'd1;
	parameter AXI_READ_SRAM = 2'd2;
	parameter AXI_READ_OUT = 2'd3;
	
	reg [1:0] axi_current_state;
	reg [1:0] axi_next_state;
	
	reg [5:0] save_araddr;
	
	// save araddr
	always@(posedge axis_clk) begin
		if(!axis_rst_n) begin
			save_araddr <= 0;
		end else begin
			if(arvalid)
				save_araddr <= araddr;
			else
				save_araddr <= save_araddr;
		end
	end
	
	// FSM
	always@(posedge axis_clk) begin
		if(!axis_rst_n) begin
			axi_current_state <= AXI_READ_IDLE;
		end else begin
			axi_current_state <= axi_next_state;
		end
	end
	
	always@(*) begin
		case(axi_current_state)
		AXI_READ_IDLE:
			if(arvalid)
				if(araddr[6])
					axi_next_state = AXI_READ_SRAM;
				else
					axi_next_state = AXI_READ_OUT;
			else
				axi_next_state = AXI_READ_IDLE;
		AXI_READ_OUT:
			if(rready)
				axi_next_state = AXI_READ_IDLE;
			else
				axi_next_state = AXI_READ_OUT;
		AXI_READ_SRAM:
			axi_next_state = AXI_READ_OUT;
		endcase
	end
	
	always@(posedge axis_clk) begin
		if(!axis_rst_n) begin
			arready <= 1;
		end else begin
			if(axi_current_state == AXI_READ_IDLE && !arvalid)
				arready <= 1;
			else
				arready <= 0;
		end
	end
	
	always@(posedge axis_clk) begin
		if(!axis_rst_n) begin
			rvalid <= 0;
		end else begin
			if (axi_current_state == AXI_READ_OUT)
				rvalid <= 1;
			else
				rvalid <= 0;
		end
	end
	
	reg [(pDATA_WIDTH-1):0] next_rdata;
	always@(*) begin
		case(axi_current_state)
		AXI_READ_IDLE: next_rdata = 0;
		AXI_READ_SRAM: next_rdata = 0;
		AXI_READ_OUT:
			if(save_araddr == 'h00)
				next_rdata = {29'd0,ap_idle,ap_done,ap_start};
			else
				next_rdata = 0;
		default: next_rdata = 32'hFFFF;
		endcase
	end
	
	always@(posedge axis_clk) begin
		if(!axis_rst_n) begin
			rdata <= 0;
		end else begin
			rdata <= next_rdata;
		end
	end
	
	//---------------------------------------------------------------Main Process FSM-----------------------------------------------------------

	// counter
	reg [3:0] counter;
	reg [3:0] next_counter;
	reg [31:0] save_data [9:0];
	
	integer i;
	
	always@(posedge axis_clk) begin
		if(!axis_rst_n) begin
			for(i=0;i<10;i++)
				save_data[i] <= 0;
		end else begin
			if(ss_tready && ss_tvalid) begin
				for(i=0;i<9;i++)
					save_data[i+1] <= save_data[i];
				save_data[0] <= ss_tdata;
			end else begin
				for(i=0;i<10;i++)
					save_data[i] <= save_data[i];
			end
		end
	end
	// sorting network
	wire [31:0] save_data_1 [9:0];
	comp c1_1(save_data[0],save_data[1],axis_clk,axis_rst_n,save_data_1[0],save_data_1[1]);
	comp c1_2(save_data[2],save_data[3],axis_clk,axis_rst_n,save_data_1[2],save_data_1[3]);
	comp c1_3(save_data[4],save_data[5],axis_clk,axis_rst_n,save_data_1[4],save_data_1[5]);
	comp c1_4(save_data[6],save_data[7],axis_clk,axis_rst_n,save_data_1[6],save_data_1[7]);
	comp c1_5(save_data[8],save_data[9],axis_clk,axis_rst_n,save_data_1[8],save_data_1[9]);
	wire [31:0] save_data_2 [9:0];
	comp c2_1(save_data_1[1],save_data_1[2],axis_clk,axis_rst_n,save_data_2[1],save_data_2[2]);
	comp c2_2(save_data_1[3],save_data_1[4],axis_clk,axis_rst_n,save_data_2[3],save_data_2[4]);
	comp c2_3(save_data_1[5],save_data_1[6],axis_clk,axis_rst_n,save_data_2[5],save_data_2[6]);
	comp c2_4(save_data_1[7],save_data_1[8],axis_clk,axis_rst_n,save_data_2[7],save_data_2[8]);
	wire [31:0] save_data_3 [9:0];
	comp c3_1(save_data_1[0],save_data_2[1],axis_clk,axis_rst_n,save_data_3[0],save_data_3[1]);
	comp c3_2(save_data_2[2],save_data_2[3],axis_clk,axis_rst_n,save_data_3[2],save_data_3[3]);
	comp c3_3(save_data_2[4],save_data_2[5],axis_clk,axis_rst_n,save_data_3[4],save_data_3[5]);
	comp c3_4(save_data_2[6],save_data_2[7],axis_clk,axis_rst_n,save_data_3[6],save_data_3[7]);
	comp c3_5(save_data_2[8],save_data_1[9],axis_clk,axis_rst_n,save_data_3[8],save_data_3[9]);
	wire [31:0] save_data_4 [9:0];
	comp c4_1(save_data_3[1],save_data_3[2],axis_clk,axis_rst_n,save_data_4[1],save_data_4[2]);
	comp c4_2(save_data_3[3],save_data_3[4],axis_clk,axis_rst_n,save_data_4[3],save_data_4[4]);
	comp c4_3(save_data_3[5],save_data_3[6],axis_clk,axis_rst_n,save_data_4[5],save_data_4[6]);
	comp c4_4(save_data_3[7],save_data_3[8],axis_clk,axis_rst_n,save_data_4[7],save_data_4[8]);
	wire [31:0] save_data_5 [9:0];
	comp c5_1(save_data_3[0],save_data_4[1],axis_clk,axis_rst_n,save_data_5[0],save_data_5[1]);
	comp c5_2(save_data_4[2],save_data_4[3],axis_clk,axis_rst_n,save_data_5[2],save_data_5[3]);
	comp c5_3(save_data_4[4],save_data_4[5],axis_clk,axis_rst_n,save_data_5[4],save_data_5[5]);
	comp c5_4(save_data_4[6],save_data_4[7],axis_clk,axis_rst_n,save_data_5[6],save_data_5[7]);
	comp c5_5(save_data_4[8],save_data_3[9],axis_clk,axis_rst_n,save_data_5[8],save_data_5[9]);
	wire [31:0] save_data_6 [9:0];
	comp c6_1(save_data_5[1],save_data_5[2],axis_clk,axis_rst_n,save_data_6[1],save_data_6[2]);
	comp c6_2(save_data_5[3],save_data_5[4],axis_clk,axis_rst_n,save_data_6[3],save_data_6[4]);
	comp c6_3(save_data_5[5],save_data_5[6],axis_clk,axis_rst_n,save_data_6[5],save_data_6[6]);
	comp c6_4(save_data_5[7],save_data_5[8],axis_clk,axis_rst_n,save_data_6[7],save_data_6[8]);
	wire [31:0] save_data_7 [9:0];
	comp c7_1(save_data_5[0],save_data_6[1],axis_clk,axis_rst_n,save_data_7[0],save_data_7[1]);
	comp c7_2(save_data_6[2],save_data_6[3],axis_clk,axis_rst_n,save_data_7[2],save_data_7[3]);
	comp c7_3(save_data_6[4],save_data_6[5],axis_clk,axis_rst_n,save_data_7[4],save_data_7[5]);
	comp c7_4(save_data_6[6],save_data_6[7],axis_clk,axis_rst_n,save_data_7[6],save_data_7[7]);
	comp c7_5(save_data_6[8],save_data_5[9],axis_clk,axis_rst_n,save_data_7[8],save_data_7[9]);
	wire [31:0] save_data_8 [9:0];
	comp c8_1(save_data_7[1],save_data_7[2],axis_clk,axis_rst_n,save_data_8[1],save_data_8[2]);
	comp c8_2(save_data_7[3],save_data_7[4],axis_clk,axis_rst_n,save_data_8[3],save_data_8[4]);
	comp c8_3(save_data_7[5],save_data_7[6],axis_clk,axis_rst_n,save_data_8[5],save_data_8[6]);
	comp c8_4(save_data_7[7],save_data_7[8],axis_clk,axis_rst_n,save_data_8[7],save_data_8[8]);
	wire [31:0] save_data_9 [9:0];
	comp c9_1(save_data_7[0],save_data_8[1],axis_clk,axis_rst_n,save_data_9[0],save_data_9[1]);
	comp c9_2(save_data_8[2],save_data_8[3],axis_clk,axis_rst_n,save_data_9[2],save_data_9[3]);
	comp c9_3(save_data_8[4],save_data_8[5],axis_clk,axis_rst_n,save_data_9[4],save_data_9[5]);
	comp c9_4(save_data_8[6],save_data_8[7],axis_clk,axis_rst_n,save_data_9[6],save_data_9[7]);
	comp c9_5(save_data_8[8],save_data_7[9],axis_clk,axis_rst_n,save_data_9[8],save_data_9[9]);
	wire [31:0] save_data_10 [9:0];
	comp c10_1(save_data_9[1],save_data_9[2],axis_clk,axis_rst_n,save_data_10[1],save_data_10[2]);
	comp c10_2(save_data_9[3],save_data_9[4],axis_clk,axis_rst_n,save_data_10[3],save_data_10[4]);
	comp c10_3(save_data_9[5],save_data_9[6],axis_clk,axis_rst_n,save_data_10[5],save_data_10[6]);
	comp c10_4(save_data_9[7],save_data_9[8],axis_clk,axis_rst_n,save_data_10[7],save_data_10[8]);
	wire [31:0] save_data_11 [9:0];
	comp c11_1( save_data_9[0],save_data_10[1],axis_clk,axis_rst_n,save_data_11[0],save_data_11[1]);
	comp c11_2(save_data_10[2],save_data_10[3],axis_clk,axis_rst_n,save_data_11[2],save_data_11[3]);
	comp c11_3(save_data_10[4],save_data_10[5],axis_clk,axis_rst_n,save_data_11[4],save_data_11[5]);
	comp c11_4(save_data_10[6],save_data_10[7],axis_clk,axis_rst_n,save_data_11[6],save_data_11[7]);
	comp c11_5( save_data_10[8],save_data_9[9],axis_clk,axis_rst_n,save_data_11[8],save_data_11[9]);
	
	
	always@(posedge axis_clk) begin
		if(!axis_rst_n) begin
			counter <= 0;
		end else begin
			counter <= next_counter;
		end
	end
	
	always@(*) begin
		if(current_state == S_INPUT && ss_tvalid && ss_tready)
			if(counter == 9)
				next_counter = 0;
			else
				next_counter = counter + 1;
		else if (current_state == S_OUT && sm_tready && sm_tvalid)
			if(counter == 1)
				next_counter = 0;
			else
				next_counter = counter + 1;
		else if(current_state == S_CAL)
			if(counter == 11)
				next_counter = 0;
			else
				next_counter = counter + 1;
		else
			next_counter = counter;
	end
	
	always@(posedge axis_clk) begin
		if(!axis_rst_n) begin
			current_state <= S_IDLE;
		end else begin
			current_state <= next_state;
		end
	end
	
	always@(*) begin
	case(current_state)
	S_IDLE:
		if(ap_start)
			next_state = S_INPUT;
		else
			next_state = S_IDLE;
	S_INPUT:
		if(counter == 'd9 && ss_tvalid && ss_tready)
			next_state = S_CAL;
		else
			next_state = S_INPUT;
	S_CAL:
		if(counter == 'd11)
			next_state = S_OUT;
		else
			next_state = S_CAL;
	S_OUT: 
		if(counter == 'd1)
			next_state = S_WAIT_AP_DONE;
		else
			next_state = S_OUT;
	/*S_WAIT: if(sm_tready)
				if(pattern_count == length-1)
					next_state = S_WAIT_AP_DONE;
				else
					next_state = S_GET_DATA;
			else
				next_state = S_WAIT;*/
	S_WAIT_AP_DONE:
		if(rvalid && rdata[1])
			next_state = S_IDLE;
		else
			next_state = S_WAIT_AP_DONE;
	default: next_state = S_IDLE;
	endcase
	end
	
	//------------------------------------------------------------AXI Lite Write--------------------------------------------------------
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
	
	//---------------------------------------------------------------AXI stream-----------------------------------------------------------
	always@ (posedge axis_clk) begin
		ss_tready <= current_state == S_INPUT;
	end
	
	assign sm_tvalid = current_state == S_OUT;
	assign sm_tlast = 0;
	assign sm_tdata = save_data_11[9];

endmodule

module comp(
	input [31:0] in1,
	input [31:0] in2,
	input clk,
	input rst_n,
	output reg [31:0] out1,
	output reg [31:0] out2
);
	always@(posedge clk) begin
		if(!rst_n) begin
			out1 <= 0;
			out2 <= 0;
		end else if(in1 < in2) begin
			out1 <= in1;
			out2 <= in2;
		end else begin
			out1 <= in2;
			out2 <= in1;
		end
	end

endmodule