// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
// Date        : Tue Jan 16 18:07:22 2024
// Host        : taipei running 64-bit CentOS Linux release 7.6.1810 (Core)
// Command     : write_verilog -force -mode funcsim
//               /home/soc/caravel-soc_fpga-lab_original/fuck_final/vivado/vvd_caravel_fpga/vvd_caravel_fpga.gen/sources_1/bd/design_1/ip/design_1_blk_mem_gen_0_0/design_1_blk_mem_gen_0_0_sim_netlist.v
// Design      : design_1_blk_mem_gen_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "design_1_blk_mem_gen_0_0,blk_mem_gen_v8_4_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_5,Vivado 2022.1" *) 
(* NotValidForBitStream *)
module design_1_blk_mem_gen_0_0
   (clka,
    rsta,
    ena,
    wea,
    addra,
    dina,
    douta,
    clkb,
    rstb,
    enb,
    web,
    addrb,
    dinb,
    doutb,
    rsta_busy,
    rstb_busy);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE BRAM_CTRL, READ_WRITE_MODE READ_WRITE, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA RST" *) input rsta;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [3:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [31:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [31:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [31:0]douta;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE BRAM_CTRL, READ_WRITE_MODE READ_WRITE, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB RST" *) input rstb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB WE" *) input [3:0]web;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [31:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DIN" *) input [31:0]dinb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [31:0]doutb;
  output rsta_busy;
  output rstb_busy;

  wire [31:0]addra;
  wire [31:0]addrb;
  wire clka;
  wire clkb;
  wire [31:0]dina;
  wire [31:0]dinb;
  wire [31:0]douta;
  wire [31:0]doutb;
  wire ena;
  wire enb;
  wire rsta;
  wire rsta_busy;
  wire rstb;
  wire rstb_busy;
  wire [3:0]wea;
  wire [3:0]web;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [31:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [31:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [31:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "32" *) 
  (* C_ADDRB_WIDTH = "32" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "8" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "2" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "1" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "1" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     10.7492 mW" *) 
  (* C_FAMILY = "zynq" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "1" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "1" *) 
  (* C_HAS_RSTB = "1" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "NONE" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "2" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "2048" *) 
  (* C_READ_DEPTH_B = "2048" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "32" *) 
  (* C_READ_WIDTH_B = "32" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "1" *) 
  (* C_USE_BYTE_WEA = "1" *) 
  (* C_USE_BYTE_WEB = "1" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "4" *) 
  (* C_WEB_WIDTH = "4" *) 
  (* C_WRITE_DEPTH_A = "2048" *) 
  (* C_WRITE_DEPTH_B = "2048" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "32" *) 
  (* C_WRITE_WIDTH_B = "32" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  design_1_blk_mem_gen_0_0_blk_mem_gen_v8_4_5 U0
       (.addra({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,addra[12:2],1'b0,1'b0}),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,addrb[12:2],1'b0,1'b0}),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb(dinb),
        .douta(douta),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(enb),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[31:0]),
        .regcea(1'b0),
        .regceb(1'b0),
        .rsta(rsta),
        .rsta_busy(rsta_busy),
        .rstb(rstb),
        .rstb_busy(rstb_busy),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[31:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[31:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(web));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2022.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
RgPKnWr9n0dGgttm3akiFhAlfB96usOQYxnEmPhGyTGg1AbizYAjGPWLXBWl50n/d0IA71ci4aJB
wt6mtfyNADm3ZReK7D3mKu037BOgxryoEwwf1kiC6q/PllxsdAgEMfQrfHJ3E2AzSpdYjoxVYito
y0JW6CUDcWvWa4WV0EA=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
M0l6KpOGH3jL8eRt3NCD7e2USYnkg5H9GAnE1PKmnjiouFN3Y8kjWA2PZDAQLm9UW+TsC1HeVlzO
WjNCHkjR/6ubCsIcWfpPZWdIuAenlsyq8Y9l6b8vMj8JSbDEOiFF/GHSbKsn22MJdDJKEhHFK6GV
s8gR2vywRFwG69gIRE4qGhVB+WIg8GJrDpDMYH6lCjMkTrjXuKDUcNlJN3NPLuhJ7tsditwf1pr5
moJRmGpJnip/rGm0g4o4A6ev4CtePjoao8C1wFtzHkERX9oenhh7cGjDMejU5IrLv8NxFnLj1FpB
9MuF1beTU20NI5oAn6zLiLiOtXjf0ghU3AN4DA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
hAsrUfp6Qgjm8yBjNYTEtQmVQmMxzL8TE/3oiQSxSI3+yEkXAbQCXkT9mo+LCdv+fGECOB0istHd
eLtbsiYbxjxNxYkXiUrRE5O+aSxynIray+uF9DJigTEUZu8JJXUbzxK4DDUu1Lm9tpGps4+Prz1m
0gkj13RT/Y/418s2VTw=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
BP/54Wm/GJmb1jy0bxWJJX4aiKyiWPVh4X3VL30BQrmX4PlEsNKzBJH3Qu8IIYERfnFP0ifAgboa
vypMQ5Ed0BrMePGkWIgT6I8hxJCMFpHdkSK7m1giSKyZzFfTOrVqoNFXE+qdzLfY1J5hBWCvouYo
jllavK4N3gF9FLScH2AUWYVMcVth2QPaTAU2NLnAUNH8kgtBjBfc8/KbPPTznD1QNVqvFstzcbTA
hGQ1ETVPvINQ0KqxxAG5PRhtQD4+pC+hr/Tvk+RSvGyBOfy9zE86OXkJiYs9dSFhNiMFmCPL9DBO
se4OxNNC0/7aBtb1mkSEA9YFDYEb9jS7Jasy2A==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
SnzT9DVH3xlEN8nrr2YrlvTO5qj7L22d7WaBcuKyTaiHoIwwFHrC4HQbfs0TAwkdWcOgmJoATPSF
F6qm0KiddbrlERF3MfKUldeGBJtqLdX+zGw7+3JD7S+HB9dIMOFOHy+IiCZp1/Pz8epKpi238cel
rcVoJQKz406wmXDvOo8KsT+XhRLs9BVCrBErPGGXKYDk6NXAp0duOgQE9DbslzMU83M/kUC7uERV
tQW02240peKQFp2elEZC7Tetvgp0TaFTtJiKN45REi8GQUCKGa85JjNIk1qb/+k95TIIP1xrHirc
6iX7qbwnPetv8TVu2NjkZ0WDEK5RXdOXcxBwHA==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_07", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
erkR82V0jX8ytva+9MzEs0c75Z7j7TsgxWRLNAUfbbU28i+U9YzuZlSfYU75M0f9jx1gvxtBrfKv
cNHVdkR+i5zfHDZsDwfMEEBhs8wzDCKqe+eex6BBEvlIOesCPXrr2RozQgaQ1PBh/os2Arfu+873
BjsVxFJkbhpzIqlddOo/XZV9Yi+eih7A7pXXEBR6IL7Poo4Ka49MiVQU0xJrDTm+ddOuMPDRRD7g
dsxS/uzdcBcO2myV6g/7YH/C2Ce9s6+UywJN/0JeXSqwA7bsBqqnfFicVAT0lckLopMLiuzK7dsN
EwhFeqoetciFrDIj9+o0xDMWBZhgNP1u68vURA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
R+BI65BKLT0I9hEtsxGnDyM5XY9gzULeTPOSDXvd3KWOzZJAx6C0xlbyZcFZhAEG/QIK2yd0wAi6
IUWxyF/sx3HsqKjhVi5KxnpuXDBOZVoj811O7JukedFVmDW7OHGtBkuiJ5X5irw7mfsEKRQmF/1i
V6lj9HYHZEjxtDeZjACsLY4y1QxWalSKT4HIMOHznBLL8dLbGMlS+ZmFuFn0gcwZavVl7gTkTtkf
W0gn01A9ru7NKsf+iLX0kj4dgItPu9N2g02M1vWQ9UUQEVvfV7lUc7GY1suibrD8aEkhH9S7lZ7n
bFsT4qxyvzg8ML6v4g4v7N6VuyhEtgFgNd725Q==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
jNUVKiwH68vHsU54idgvKwaVJcoxTUuxfgrQpbpmM/IpesWA3wHsGzYClwAxkKzw3KRnFyQqTWcZ
yj1EQ2CMBxlJ0kyNbZW8OK8pXzeigToZ0U6Aq3Gy+j7wBbhe83wE1Ygn82sK8dHTEulvaRLn/c5r
ispy1s7jMKIvYNzoUuZrgyBQyfaYmdqUia8XlQjFd+VwzhTXKwzvmaqHWyaHjfBKeCooO7+oUxMG
OJg83W54EVe9ronFQ8Wr9EOL8ia7qelCAgyQe/bC0HHCoMAm8apI7sX23iMR/wMiPP5V2bQzycy+
rBX/+SWkqSeIE1FLm+muFPvrE7iLwJaW8d1fzdFFjAZ5aIXArbWNfwbK8S0TczXc9lEzmpb69rwA
UJIrs4alo81qGQ32UFhjuMQjX75O9Od1HWHDj5PFaT/Ja5Ly+bK8Cc3gfO6dCE81m7d+B2JBZ/Hl
tBA19QuOAYwT2EIPOdpaVtCULb33cWODWu3qQFhZMmDzKTb3kwpcr0LL

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
MnzcA2swaxH1LRacKDou0ZmiiMRETbWIdHgeBgyQz7ILronsXLoB/C20WuFNGEVSiL2/51EZ6MXZ
vMHI8fFcMQCJcuTBDBibUMKv6bXI9s8fTbtrBZppbF/R1icG5JYhqmX4aRnv4W/dxJRjI2L35nLN
Y48E9OfgfkD1sr+IRwx8WEKFmUhuk8dLe0VOK7ywe3XEcneYvrz+HhPj16bGmNfMwNnDgZ3gKKZD
hRnys+jzvAX3HyISrErWXhMKrhWMxXeTNFJCqNQ0LWAVHQYwyKnF5xVpyXSuGNSIrva+QXqOrZBG
3VNLirNVtMRiKLfwZeMaqvswkqBDAa53utlAAA==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
d0xXkKtsKM8GvXhDZr16p1+oE3uBtD04BJ76eGGIEj/CFECfHVy9qsJ43oSKjas0+AJr4GFFnVb6
X7gJV6MmX/OboC9ier5joUCGz0mxVzkRZK9a+LPEDcg0K6+cLE36kr+FfxW9Uk2816EHBCMCf5mK
A4eAhSmAb5Nq74F/q0quiG416npbny7faiQ+xmPDfYYiM3UuMKaD4iE8ODlz1w5xThPllWESf3LZ
NTkw6fozyTqZ47vvE21O3dgIGAY1v+C6BwlCK24VwPJa1xs9csY+qTk31j5jjAc1ExlB6QF7t9UH
lk70qdNPWxT87OH7kFT8UvPO1D6BTC3/WkDZfA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
LYhdzKTvo93uJrAaiP5OfCDuOnu2BSvPnxlv6I7h2n1+xHtj34LNNKzWEgOg9dUV9cYDaHYUjjEt
DKdWcz6mZ61d5qyxAhpv67fc90v7JVgtOAcT94/Yb+AuLxXFcGA6Gic7uoJtUgz6JmTnb22Dxdjc
KuIewDj4IOTfP8XGXKTaF+cNp0CFrQgTAcVSQFyLFxr0I/9h3S+GZLecA7ntEeHEOfCJzPvy0ddi
7MCdQWECLb+fXC0IAn8V95TumcpINiRAX1BHi9IGJ4QoMrb3jOCrPkFhDMTJj2aiImUWdi/l/0QE
d7wcXlgIEYVeoKYUOJ4mqy+zZPUbLNeOPADUDQ==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 59888)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
