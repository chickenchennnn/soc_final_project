// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype wire
/*
 *-------------------------------------------------------------
 *
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */

module user_project_wrapper #(
           parameter BITS = 32
       ) (
`ifdef USE_POWER_PINS
           inout vdda1,	// User area 1 3.3V supply
           inout vdda2,	// User area 2 3.3V supply
           inout vssa1,	// User area 1 analog ground
           inout vssa2,	// User area 2 analog ground
           inout vccd1,	// User area 1 1.8V supply
           inout vccd2,	// User area 2 1.8v supply
           inout vssd1,	// User area 1 digital ground
           inout vssd2,	// User area 2 digital ground
`endif

           // Wishbone Slave ports (WB MI A)
           input wb_clk_i,
           input wb_rst_i,
           input wbs_stb_i,
           input wbs_cyc_i,
           input wbs_we_i,
           input [3:0] wbs_sel_i,
           input [31:0] wbs_dat_i,
           input [31:0] wbs_adr_i,
           output wbs_ack_o,
           output [31:0] wbs_dat_o,

           // Logic Analyzer Signals
           input  [127:0] la_data_in,
           output [127:0] la_data_out,
           input  [127:0] la_oenb,

           // IOs
           input  [`MPRJ_IO_PADS-1:0] io_in,
           output [`MPRJ_IO_PADS-1:0] io_out,
           output [`MPRJ_IO_PADS-1:0] io_oeb,

           // Analog (direct connection to GPIO pad---use with caution)
           // Note that analog I/O is not available on the 7 lowest-numbered
           // GPIO pads, and so the analog_io indexing is offset from the
           // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
           inout [`MPRJ_IO_PADS-10:0] analog_io,

           // Independent clock (on independent integer divider)
           input   user_clock2,

           // User maskable interrupt signals
           output [2:0] user_irq
       );

/*--------------------------------------*/
/* 			      Fir 				    */
/*--------------------------------------*/

// fir hardware wire
wire         awready_fir;
wire         wready_fir;
wire         awvalid_fir;
wire [11:0]  awaddr_fir;
wire         wvalid_fir;
wire [31:0]  wdata_fir;

wire         arready_fir;
wire         rready_fir;
wire         arvalid_fir;
wire [11:0]  araddr_fir;
wire         rvalid_fir;
wire [31:0]  rdata_fir;

wire         ss_tvalid_fir;
wire [31:0]  ss_tdata_fir;
wire         ss_tlast_fir;
wire         ss_tready_fir;
wire         sm_tready_fir;
wire         sm_tvalid_fir;
wire [31:0]  sm_tdata_fir;
wire         sm_tlast_fir;

wire         awready_mm;
wire         wready_mm;
wire         awvalid_mm;
wire [11:0]  awaddr_mm;
wire         wvalid_mm;
wire [31:0]  wdata_mm;

wire         arready_mm;
wire         rready_mm;
wire         arvalid_mm;
wire [11:0]  araddr_mm;
wire         rvalid_mm;
wire [31:0]  rdata_mm;

wire         ss_tvalid_mm;
wire [31:0]  ss_tdata_mm;
wire         ss_tlast_mm;
wire         ss_tready_mm;
wire         sm_tready_mm;
wire         sm_tvalid_mm;
wire [31:0]  sm_tdata_mm;
wire         sm_tlast_mm;

wire         awready_qs;
wire         wready_qs;
wire         awvalid_qs;
wire [11:0]  awaddr_qs;
wire         wvalid_qs;
wire [31:0]  wdata_qs;

wire         arready_qs;
wire         rready_qs;
wire         arvalid_qs;
wire [11:0]  araddr_qs;
wire         rvalid_qs;
wire [31:0]  rdata_qs;

wire         ss_tvalid_qs;
wire [31:0]  ss_tdata_qs;
wire         ss_tlast_qs;
wire         ss_tready_qs;
wire         sm_tready_qs;
wire         sm_tvalid_qs;
wire [31:0]  sm_tdata_qs;
wire         sm_tlast_qs;




wire [3:0]   tap_WE;
wire         tap_EN;
wire [31:0]  tap_Di;
wire [11:0]  tap_A;
wire [31:0]  tap_Do;

wire [3:0]   data_WE;
wire         data_EN;
wire [31:0]  data_Di;
wire [11:0]  data_A;
wire [31:0]  data_Do;

/*--------------------------------------*/
/*            Address Decode            */
/*--------------------------------------*/

// //decorder
wire wbs_ack_o_uart,wbs_ack_o_sw, wbs_ack_o_axi;
wire [31:0] wbs_dat_o_uart, wbs_dat_o_sw, wbs_dat_o_axi;
reg [2:0]enable;

//output
always @(*)begin
    if(wbs_cyc_i && wbs_stb_i && wbs_adr_i[31:24] == 8'h30)
        enable = 3'b001;
    else if(wbs_cyc_i && wbs_stb_i && wbs_adr_i[31:24] == 8'h31)
        enable = 3'b010;
    else if(wbs_cyc_i && wbs_stb_i && (wbs_adr_i[31:24] == 8'h38 || wbs_adr_i[31:24] == 8'h00))
        enable = 3'b100;
    else
        enable = 3'b000;
end

reg wbs_ack_o_reg;
reg [31:0] wbs_dat_o_reg;
always @(*)begin
    if(enable[0] == 1) begin
        wbs_ack_o_reg = wbs_ack_o_axi;
        wbs_dat_o_reg = wbs_dat_o_axi;
    end else if(enable[1] == 1) begin
        wbs_ack_o_reg = wbs_ack_o_uart;
        wbs_dat_o_reg = wbs_dat_o_uart;
    end else if(enable[2] == 1) begin
        wbs_ack_o_reg = wbs_ack_o_sw;
        wbs_dat_o_reg = wbs_dat_o_sw;
    end else begin
        wbs_ack_o_reg = 0;
        wbs_dat_o_reg = 0;
    end
end


assign wbs_ack_o = wbs_ack_o_reg;
assign wbs_dat_o = wbs_dat_o_reg;



//====================================================================
// addr = 3800xxxx
// Defined in user_bram.v
// user_bram_dealer user_bram_dealer (
// 	`ifdef USE_POWER_PINS
// 		.vccd1(vccd1),	// User area 1 1.8V power
// 		.vssd1(vssd1),	// User area 1 digital ground
// 	`endif

// 	.wb_clk_i(wb_clk_i),
// 	.wb_rst_i(wb_rst_i),

// 	// MGMT SoC Wishbone Slave
// 	.enable(enable[2]),
// 	.wbs_cyc_i(wbs_cyc_i),
// 	.wbs_stb_i(wbs_stb_i),
// 	.wbs_we_i(wbs_we_i),
// 	.wbs_sel_i(wbs_sel_i),
// 	.wbs_adr_i(wbs_adr_i),
// 	.wbs_dat_i(wbs_dat_i),
// 	.wbs_ack_o(wbs_ack_o_sw),
// 	.wbs_dat_o(wbs_dat_o_sw)

// );


user_proj_sdram mprj_sdram (
`ifdef USE_POWER_PINS
                    .vccd1(vccd1),	// User area 1 1.8V power
                    .vssd1(vssd1),	// User area 1 digital ground
`endif

                    .wb_clk_i(wb_clk_i),
                    .wb_rst_i(wb_rst_i),
                    .enable(enable[2]),
                    // MGMT SoC Wishbone Slave

                    .wbs_cyc_i(wbs_cyc_i),
                    .wbs_stb_i(wbs_stb_i),
                    .wbs_we_i(wbs_we_i),
                    .wbs_sel_i(wbs_sel_i),
                    .wbs_adr_i(wbs_adr_i),
                    .wbs_dat_i(wbs_dat_i),
                    .wbs_ack_o(wbs_ack_o_sw),
                    .wbs_dat_o(wbs_dat_o_sw),
                    // .la_data_in(la_data_in),
                    // .la_data_out(la_data_out),
                    .la_oenb (la_oenb)
                );



// Uart part
// Defined in uart.v
uart uart (
	`ifdef USE_POWER_PINS
         .vccd1(vccd1),	// User area 1 1.8V power
         .vssd1(vssd1),	// User area 1 digital ground
	`endif

         .wb_clk_i(wb_clk_i),
         .wb_rst_i(wb_rst_i),

         // MGMT SoC Wishbone Slave
         .wb_valid(enable[1]),
         //.wbs_stb_i(wbs_stb_i),
         //.wbs_cyc_i(wbs_cyc_i),
         .wbs_we_i( wbs_we_i),
         .wbs_sel_i(wbs_sel_i),
         .wbs_dat_i(wbs_dat_i),
         .wbs_adr_i(wbs_adr_i),
         .wbs_ack_o(wbs_ack_o_uart),
         .wbs_dat_o(wbs_dat_o_uart),

         // IO ports
         .io_in  (io_in  ),
         .io_out (io_out ),
         .io_oeb (io_oeb ),

         // irq
         .user_irq (user_irq)
     );


// axi converter
// Defined in axi_converter.v


axi_converter axi_converter (
`ifdef USE_POWER_PINS
                  .vccd1(vccd1),	// User area 1 1.8V power
                  .vssd1(vssd1),	// User area 1 digital ground
`endif
                  .clk(wb_clk_i),
                  .rst(wb_rst_i),
                  .enable(enable[0]),

                  // MGMT SoC Wishbone Slave
                  .wbs_cyc_i(wbs_cyc_i),
                  .wbs_stb_i(wbs_stb_i),
                  .wbs_we_i(wbs_we_i),
                  .wbs_sel_i(wbs_sel_i),
                  .wbs_adr_i(wbs_adr_i),
                  .wbs_dat_i(wbs_dat_i),
                  .wbs_ack_o(wbs_ack_o_axi),
                  .wbs_dat_o(wbs_dat_o_axi),
                  //fir
                  // AXI Lite
                  //write channel
                  .awready_fir(awready_fir),
                  .wready_fir(wready_fir),
                  .awvalid_fir(awvalid_fir),
                  .awaddr_fir(awaddr_fir),
                  .wvalid_fir(wvalid_fir),
                  .wdata_fir(wdata_fir),

                  //read channel
                  .arready_fir(arready_fir),
                  .rready_fir(rready_fir),
                  .arvalid_fir(arvalid_fir),
                  .araddr_fir(araddr_fir),
                  .rvalid_fir(rvalid_fir),
                  .rdata_fir(rdata_fir),

                  // AXI stream
                  .ss_tvalid_fir(ss_tvalid_fir),
                  .ss_tdata_fir(ss_tdata_fir),
                  .ss_tlast_fir(ss_tlast_fir),
                  .ss_tready_fir(ss_tready_fir),

                  .sm_tready_fir(sm_tready_fir),
                  .sm_tvalid_fir(sm_tvalid_fir),
                  .sm_tdata_fir(sm_tdata_fir),
                  .sm_tlast_fir(sm_tlast_fir),



                  //mm
                  // AXI Lite
                  //write channel
                  .awready_mm(awready_mm),
                  .wready_mm(wready_mm),
                  .awvalid_mm(awvalid_mm),
                  .awaddr_mm(awaddr_mm),
                  .wvalid_mm(wvalid_mm),
                  .wdata_mm(wdata_mm),

                  //read channel
                  .arready_mm(arready_mm),
                  .rready_mm(rready_mm),
                  .arvalid_mm(arvalid_mm),
                  .araddr_mm(araddr_mm),
                  .rvalid_mm(rvalid_mm),
                  .rdata_mm(rdata_mm),

                  // AXI stream
                  .ss_tvalid_mm(ss_tvalid_mm),
                  .ss_tdata_mm(ss_tdata_mm),
                  .ss_tlast_mm(ss_tlast_mm),
                  .ss_tready_mm(ss_tready_mm),

                  .sm_tready_mm(sm_tready_mm),
                  .sm_tvalid_mm(sm_tvalid_mm),
                  .sm_tdata_mm(sm_tdata_mm),
                  .sm_tlast_mm(sm_tlast_mm),


                  //qs
                  // AXI Lite
                  //write channel
                  .awready_qs(awready_qs),
                  .wready_qs(wready_qs),
                  .awvalid_qs(awvalid_qs),
                  .awaddr_qs(awaddr_qs),
                  .wvalid_qs(wvalid_qs),
                  .wdata_qs(wdata_qs),

                  //read channel
                  .arready_qs(arready_qs),
                  .rready_qs(rready_qs),
                  .arvalid_qs(arvalid_qs),
                  .araddr_qs(araddr_qs),
                  .rvalid_qs(rvalid_qs),
                  .rdata_qs(rdata_qs),

                  // AXI stream
                  .ss_tvalid_qs(ss_tvalid_qs),
                  .ss_tdata_qs(ss_tdata_qs),
                  .ss_tlast_qs(ss_tlast_qs),
                  .ss_tready_qs(ss_tready_qs),

                  .sm_tready_qs(sm_tready_qs),
                  .sm_tvalid_qs(sm_tvalid_qs),
                  .sm_tdata_qs(sm_tdata_qs),
                  .sm_tlast_qs(sm_tlast_qs)


              );

// FIR hardware
fir fir(
        .awready(awready_fir),
        .wready(wready_fir),
        .awvalid(awvalid_fir),
        .awaddr(awaddr_fir),
        .wvalid(wvalid_fir),
        .wdata(wdata_fir),

        .arready(arready_fir),
        .rready(rready_fir),
        .arvalid(arvalid_fir),
        .araddr(araddr_fir),
        .rvalid(rvalid_fir),
        .rdata(rdata_fir),

        .ss_tvalid(ss_tvalid_fir),
        .ss_tdata(ss_tdata_fir),
        .ss_tlast(ss_tlast_fir),
        .ss_tready(ss_tready_fir),

        .sm_tready(sm_tready_fir),
        .sm_tvalid(sm_tvalid_fir),
        .sm_tdata(sm_tdata_fir),
        .sm_tlast(sm_tlast_fir),

        // ram for tap
        .tap_WE(tap_WE),
        .tap_EN(tap_EN),
        .tap_Di(tap_Di),
        .tap_A (tap_A),
        .tap_Do(tap_Do),

        // ram for data
        .data_WE(data_WE),
        .data_EN(data_EN),
        .data_Di(data_Di),
        .data_A(data_A),
        .data_Do(data_Do),
        .axis_clk(wb_clk_i),
        .axis_rst_n(~wb_rst_i)
    );

mm mm(
       .awready(awready_mm),
       .wready(wready_mm),
       .awvalid(awvalid_mm),
       .awaddr(awaddr_mm),
       .wvalid(wvalid_mm),
       .wdata(wdata_mm),

       .arready(arready_mm),
       .rready(rready_mm),
       .arvalid(arvalid_mm),
       .araddr(araddr_mm),
       .rvalid(rvalid_mm),
       .rdata(rdata_mm),

       .ss_tvalid(ss_tvalid_mm),
       .ss_tdata(ss_tdata_mm),
       .ss_tlast(ss_tlast_mm),
       .ss_tready(ss_tready_mm),

       .sm_tready(sm_tready_mm),
       .sm_tvalid(sm_tvalid_mm),
       .sm_tdata(sm_tdata_mm),
       .sm_tlast(sm_tlast_mm),
       .axis_clk(wb_clk_i),
       .axis_rst_n(~wb_rst_i)
   );
qsort qsort(
          .awready(awready_qs),
          .wready(wready_qs),
          .awvalid(awvalid_qs),
          .awaddr(awaddr_qs),
          .wvalid(wvalid_qs),
          .wdata(wdata_qs),

          .arready(arready_qs),
          .rready(rready_qs),
          .arvalid(arvalid_qs),
          .araddr(araddr_qs),
          .rvalid(rvalid_qs),
          .rdata(rdata_qs),

          .ss_tvalid(ss_tvalid_qs),
          .ss_tdata(ss_tdata_qs),
          .ss_tlast(ss_tlast_qs),
          .ss_tready(ss_tready_qs),

          .sm_tready(sm_tready_qs),
          .sm_tvalid(sm_tvalid_qs),
          .sm_tdata(sm_tdata_qs),
          .sm_tlast(sm_tlast_qs),
          .axis_clk(wb_clk_i),
          .axis_rst_n(~wb_rst_i)
      );

// RAM for tap
bram11 tap_RAM (
           .clk(wb_clk_i),
           .we(tap_WE[0]),
           .re(~tap_WE[0]),
           .waddr(tap_A),
           .raddr(tap_A),
           .wdi(tap_Di),
           .rdo(tap_Do)
       );

// RAM for data: choose bram11 or bram12
bram11 data_RAM(
           .clk(wb_clk_i),
           .we(data_WE[0]),
           .re(~data_WE[0]),
           .waddr(data_A),
           .raddr(data_A),
           .wdi(data_Di),
           .rdo(data_Do)
       );

endmodule

`default_nettype wire
