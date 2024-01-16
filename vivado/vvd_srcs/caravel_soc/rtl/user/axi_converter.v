
`default_nettype wire
/*
 *-------------------------------------------------------------
 *
 * This axi_converter deal with wishbone to axi stream and axi lite to fir hardware
 *
 *-------------------------------------------------------------
 */
module axi_converter #(
           parameter BITS = 32
       )(
`ifdef USE_POWER_PINS
           inout vccd1,	// User area 1 1.8V supply
           inout vssd1,	// User area 1 digital ground
`endif
           input clk,
           input rst,
           input enable,
           /*input ready,*/

           // Wishbone Slave ports (WB MI A)
           input wbs_stb_i,
           input wbs_cyc_i,
           input wbs_we_i,
           input [3:0] wbs_sel_i,
           input [31:0] wbs_dat_i,
           input [31:0] wbs_adr_i,
           output reg wbs_ack_o,
           output reg [31:0] wbs_dat_o,

           // AXI Lite FIR
           input         awready_fir,
           input         wready_fir,
           output          awvalid_fir,
           output   [11:0] awaddr_fir,
           output          wvalid_fir,
           output [31:0] wdata_fir,

           input arready_fir,
           output rready_fir,
           output arvalid_fir,
           output [11:0] araddr_fir,
           input rvalid_fir,
           input [31:0] rdata_fir,

           // AXI Lite QS
           input         awready_qs,
           input         wready_qs,
           output          awvalid_qs,
           output   [11:0] awaddr_qs,
           output          wvalid_qs,
           output [31:0] wdata_qs,

           input arready_qs,
           output rready_qs,
           output arvalid_qs,
           output [11:0] araddr_qs,
           input rvalid_qs,
           input [31:0] rdata_qs,

           // AXI Lite MM
           input         awready_mm,
           input         wready_mm,
           output          awvalid_mm,
           output   [11:0] awaddr_mm,
           output          wvalid_mm,
           output [31:0] wdata_mm,

           input arready_mm,
           output rready_mm,
           output arvalid_mm,
           output [11:0] araddr_mm,
           input rvalid_mm,
           input [31:0] rdata_mm,


           // AXI stream FIR
           output reg ss_tvalid_fir,
           output reg [31:0] ss_tdata_fir,
           output reg ss_tlast_fir,
           input ss_tready_fir,

           output reg sm_tready_fir,
           input sm_tvalid_fir,
           input [31:0] sm_tdata_fir,
           input sm_tlast_fir,

           // AXI stream QS
           output reg ss_tvalid_qs,
           output reg [31:0] ss_tdata_qs,
           output reg ss_tlast_qs,
           input ss_tready_qs,

           output reg sm_tready_qs,
           input sm_tvalid_qs,
           input [31:0] sm_tdata_qs,
           input sm_tlast_qs,

           // AXI stream MM
           output reg ss_tvalid_mm,
           output reg [31:0] ss_tdata_mm,
           output reg ss_tlast_mm,
           input ss_tready_mm,

           output reg sm_tready_mm,
           input sm_tvalid_mm,
           input [31:0] sm_tdata_mm,
           input sm_tlast_mm

       );
wire clk;
wire rst;
wire enable; //decode address is 0x30
wire ready; // wait over 10 cc
//lite or stream
wire is_lite;
assign is_lite= (wbs_adr_i[7] == 0) ? 1: 0;
// stream decode
wire stream_is_qs, stream_is_mm, stream_is_fir;
assign stream_is_fir = (wbs_adr_i[7:4] == 'h8) ? 1 : 0;
assign stream_is_mm = (wbs_adr_i[7:4] == 'ha) ? 1 : 0;
assign stream_is_qs = (wbs_adr_i[7:4] == 'hc) ? 1 : 0;


//================================================================================================
// // AXI Lite
//================================================================================================
wire         awready; // input
wire         wready; // input
wire          awvalid;
wire   [11:0] awaddr;
wire          wvalid;
wire [31:0] wdata;

wire arready; // input
reg rready;
reg arvalid;
reg [11:0] araddr;
wire rvalid; // input
wire [31:0] rdata; // input

// assign
assign awvalid_fir = awvalid;
assign awvalid_qs = awvalid;
assign awvalid_mm = awvalid;
assign awaddr_fir = awaddr;
assign awaddr_qs = awaddr;
assign awaddr_mm = awaddr;
assign wvalid_fir = wvalid;
assign wvalid_qs = wvalid;
assign wvalid_mm = wvalid;
assign wdata_fir = wdata;
assign wdata_qs = wdata;
assign wdata_mm = wdata;
assign rready_fir = rready;
assign rready_qs = rready;
assign rready_mm = rready;
assign arvalid_fir = arvalid;
assign arvalid_qs = arvalid;
assign arvalid_mm = arvalid;
assign araddr_fir = araddr;
assign araddr_qs = araddr;
assign araddr_mm = araddr;
assign awready = awready_fir || awready_qs || awready_mm;
assign wready = wready_fir || wready_qs || wready_mm;
assign arready = arready_fir || arready_qs || arready_mm;
assign rvalid = rvalid_fir || rvalid_qs || rvalid_mm;
assign rdata = rdata_fir || rdata_qs || rdata_mm;


//lite mode
reg axi_w_done ,axi_r_done;
always @(posedge clk) begin
    if(!enable)
        wbs_dat_o<=0;
    else if(rvalid && rready)
        wbs_dat_o<=rdata;
    else if(sm_tvalid_fir && sm_tready_fir && stream_is_fir)
        wbs_dat_o<=sm_tdata_fir;
    else if(sm_tvalid_qs && sm_tready_qs && stream_is_qs)
        wbs_dat_o<=sm_tdata_qs;
    else if(sm_tvalid_mm && sm_tready_mm && stream_is_mm)
        wbs_dat_o<=sm_tdata_mm;
end
always @(posedge clk) begin
    begin
        if(!enable)
            axi_w_done<=0;
        if(wvalid && wready)
            axi_w_done<=1;
        else if(wbs_ack_o)
            axi_w_done<=0;
    end
end
always @(posedge clk ) begin
    begin
        if(!enable)
            axi_r_done<=0;
        if(rvalid && rready)
            axi_r_done<=1;
        else if(wbs_ack_o)
            axi_r_done<=0;
    end
end
//wishbone
//================================================================================================
// send back to wishbone after 10 cycles of waiting
//================================================================================================
always @(posedge clk) begin
    begin
        if(wbs_ack_o ==1)
            wbs_ack_o<=0;
        else
        begin
            if(is_lite)
            begin
                if(/*ready &&*/ (axi_w_done || axi_r_done))
                    wbs_ack_o<=1;
                else
                    wbs_ack_o<=0;
            end
            else
            begin
                if(sm_tvalid_fir && sm_tready_fir && stream_is_fir)
                    wbs_ack_o<=1;
                else if(sm_tvalid_qs && sm_tready_qs && stream_is_qs)
                    wbs_ack_o<=1;
                else if(sm_tvalid_mm && sm_tready_mm && stream_is_mm)
                    wbs_ack_o<=1;
                else if(ss_tvalid_fir && ss_tready_fir && stream_is_fir)
                    wbs_ack_o<=1;
                else if(ss_tvalid_qs && ss_tready_qs && stream_is_qs)
                    wbs_ack_o<=1;
                else if(ss_tvalid_mm && ss_tready_mm && stream_is_mm)
                    wbs_ack_o<=1;
            end
        end
    end
end


//==========================================================================================
// cancel 10 additional delay for axi-2-wishbone
//==========================================================================================

// always @(posedge clk) begin
//     begin
//         if(wbs_ack_o ==1)
//             wbs_ack_o<=0;
//         else
//         begin
//             if(is_lite)
//             begin
//                 if((axi_w_done || axi_r_done))
//                     wbs_ack_o<=1;
//                 else
//                     wbs_ack_o<=0;
//             end
//             else
//             begin
//                 if((ss_done || sm_done))
//                     wbs_ack_o<=1;
//                 else
//                     wbs_ack_o<=0;
//             end
//         end
//     end
// end

//axilite
assign awvalid=enable && is_lite && wbs_we_i && !axi_w_done;
assign awaddr=wbs_adr_i;
assign wvalid=enable && is_lite && wbs_we_i && !axi_w_done;
assign wdata=wbs_dat_i;

always @(*) begin
    rready= enable && is_lite && (!wbs_we_i);
end
always @(*) begin
    arvalid =enable && is_lite && (!wbs_we_i) && !axi_r_done;
end
always @(*) begin
    araddr=wbs_adr_i;
end

//==========================================================================================
// axistream FIR
//==========================================================================================
//control signal
reg ss_done_fir,ss_done_mm,ss_done_qs;
reg sm_done_fir,sm_done_mm,sm_done_qs;

always @(posedge clk) begin
    if(ss_tvalid_fir==0)
        ss_done_fir<=0;
    else if(stream_is_fir&& ss_tvalid_fir && ss_tready_fir)
        ss_done_fir<=1;
end

always @(posedge clk) begin
    if(sm_tvalid_fir==0)
        sm_done_fir<=0;
    else if(stream_is_fir&& sm_tvalid_fir && sm_tready_fir)
        sm_done_fir<=1;
end
always @(posedge clk) begin
    if(sm_tvalid_mm==0)
        sm_done_mm<=0;
    else if(stream_is_mm&& sm_tvalid_mm && sm_tready_mm)
        sm_done_mm<=1;
end

always @(posedge clk) begin
    if(wbs_ack_o==1)
        sm_done_qs<=0;
    else if(stream_is_qs&& sm_tvalid_qs && sm_tready_qs)
        sm_done_qs<=1;
end


always @(*) begin
    if(enable && !is_lite && wbs_we_i && stream_is_fir && !ss_done_fir)
        ss_tvalid_fir=1;
    else
        ss_tvalid_fir=0;
end
always @(*) begin
    if(enable && !is_lite && wbs_we_i && stream_is_fir)
        ss_tdata_fir=wbs_dat_i;
    else
        ss_tdata_fir=0;
end

always @(*) begin
    if(enable && !is_lite && !wbs_we_i && stream_is_fir)
        sm_tready_fir=1;
    else
        sm_tready_fir=0;
end

//==========================================================================================
// axistream QS
//==========================================================================================


always @(posedge clk) begin
    if(ss_tvalid_qs==0)
        ss_done_qs<=0;
    else if(stream_is_qs&& ss_tvalid_qs && ss_tready_qs)
        ss_done_qs<=1;
end


always @(*) begin
    if(enable && !is_lite && wbs_we_i && stream_is_qs && !ss_done_qs)
        ss_tvalid_qs=1;
    else
        ss_tvalid_qs=0;
end
always @(*) begin
    if(enable && !is_lite && wbs_we_i && stream_is_qs)
        ss_tdata_qs=wbs_dat_i;
    else
        ss_tdata_qs=0;
end
always @(*) begin
    if(enable && !is_lite && !wbs_we_i && stream_is_qs && !sm_done_qs)
        sm_tready_qs=1;
    else
        sm_tready_qs=0;
end

//==========================================================================================
// axistream MM
//==========================================================================================


always @(posedge clk) begin
    if(ss_tvalid_mm==0)
        ss_done_mm<=0;
    else if(stream_is_mm&& ss_tvalid_mm && ss_tready_mm)
        ss_done_mm<=1;
end


always @(*) begin
    if(enable && !is_lite && wbs_we_i && stream_is_mm && !ss_done_mm)
        ss_tvalid_mm=1;
    else
        ss_tvalid_mm=0;
end
always @(*) begin
    if(enable && !is_lite && wbs_we_i && stream_is_mm)
        ss_tdata_mm=wbs_dat_i;
    else
        ss_tdata_mm=0;
end
always @(*) begin
    if(enable && !is_lite && !wbs_we_i && stream_is_mm )
        sm_tready_mm=1;
    else
        sm_tready_mm=0;
end



// X[n] ready to accept
// Y[n] ready to read stream_y_done==1








endmodule



`default_nettype wire
