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
 * This user_barm_dealer deal with 10 cycle delay
 * And deal with wishbone to bram
 * With an enable signal: enable
 *
 *-------------------------------------------------------------
 */

module user_bram_dealer #(
    parameter BITS = 32,
    parameter DELAYS=10
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input enable,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o

);
    wire clk;
    wire rst;

    wire [31:0] rdata; 
    wire [31:0] wdata;
    reg [BITS-1:0] count;

    wire valid;
    wire [3:0] wstrb;

    wire [11:0]bram_addr;


    reg ready;
    reg [3:0] delay_cnt;

    // WB MI A
    assign valid = wbs_cyc_i && wbs_stb_i && enable;
    assign wstrb = wbs_sel_i & {4{wbs_we_i}};
    assign wbs_dat_o = rdata;
    assign wdata = wbs_dat_i;
    assign wbs_ack_o = ready;

    assign clk = wb_clk_i;
    assign rst = wb_rst_i;
    assign clk = wb_clk_i;
    assign rst = wb_rst_i;
    assign bram_addr = (wbs_adr_i - 32'h38000000) >> 2; 
    
    always @(posedge clk) begin
        if (rst) begin
            ready <= 1'b0;
            delay_cnt <= 4'b0;
        end 
        else begin
            ready <= 1'b0;
            if (valid && !ready) begin
                if ( delay_cnt == DELAYS ) begin
                    delay_cnt <= 16'b0;
                    ready <= 1'b1;
                end 
                else begin
                    delay_cnt <= delay_cnt + 1;
                end
            end
            else begin
                ready <= 1'b0;
                delay_cnt <= 4'b0;
            end            
        end
    end

    bram user_bram (
        .CLK(clk),
        .WE0(wstrb),
        .EN0(valid),
        .Di0(wbs_dat_i),
        .Do0(rdata),
        //.A0(wbs_adr_i)
        .A0({20'b0,bram_addr})
    );

endmodule


`default_nettype wire
