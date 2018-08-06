// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
// Date        : Wed Jul 11 16:52:02 2018
// Host        : orion-server running 64-bit Ubuntu 16.04.4 LTS
// Command     : write_verilog -force -mode funcsim -rename_top math_mult_32 -prefix
//               math_mult_32_ math_mult_32_sim_netlist.v
// Design      : math_mult_32
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k160tfbg676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "math_mult_32,mult_gen_v12_0_13,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "mult_gen_v12_0_13,Vivado 2017.4" *) 
(* NotValidForBitStream *)
module math_mult_32
   (CLK,
    A,
    B,
    SCLR,
    P);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF p_intf:b_intf:a_intf, ASSOCIATED_RESET sclr, ASSOCIATED_CLKEN ce, FREQ_HZ 50000000, PHASE 0.000" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME a_intf, LAYERED_METADATA undef" *) input [31:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME b_intf, LAYERED_METADATA undef" *) input [31:0]B;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 sclr_intf RST" *) (* x_interface_parameter = "XIL_INTERFACENAME sclr_intf, POLARITY ACTIVE_HIGH" *) input SCLR;
  (* x_interface_info = "xilinx.com:signal:data:1.0 p_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME p_intf, LAYERED_METADATA undef" *) output [63:0]P;

  wire [31:0]A;
  wire [31:0]B;
  wire CLK;
  wire [63:0]P;
  wire SCLR;
  wire [47:0]NLW_U0_PCASC_UNCONNECTED;
  wire [1:0]NLW_U0_ZERO_DETECT_UNCONNECTED;

  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "32" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "32" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "2" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "63" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "kintex7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  math_mult_32_mult_gen_v12_0_13 U0
       (.A(A),
        .B(B),
        .CE(1'b1),
        .CLK(CLK),
        .P(P),
        .PCASC(NLW_U0_PCASC_UNCONNECTED[47:0]),
        .SCLR(SCLR),
        .ZERO_DETECT(NLW_U0_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule

(* C_A_TYPE = "0" *) (* C_A_WIDTH = "32" *) (* C_B_TYPE = "0" *) 
(* C_B_VALUE = "10000001" *) (* C_B_WIDTH = "32" *) (* C_CCM_IMP = "0" *) 
(* C_CE_OVERRIDES_SCLR = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_SCLR = "1" *) 
(* C_HAS_ZERO_DETECT = "0" *) (* C_LATENCY = "2" *) (* C_MODEL_TYPE = "0" *) 
(* C_MULT_TYPE = "1" *) (* C_OPTIMIZE_GOAL = "1" *) (* C_OUT_HIGH = "63" *) 
(* C_OUT_LOW = "0" *) (* C_ROUND_OUTPUT = "0" *) (* C_ROUND_PT = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "kintex7" *) (* downgradeipidentifiedwarnings = "yes" *) 
module math_mult_32_mult_gen_v12_0_13
   (CLK,
    A,
    B,
    CE,
    SCLR,
    ZERO_DETECT,
    P,
    PCASC);
  input CLK;
  input [31:0]A;
  input [31:0]B;
  input CE;
  input SCLR;
  output [1:0]ZERO_DETECT;
  output [63:0]P;
  output [47:0]PCASC;

  wire \<const0> ;
  wire [31:0]A;
  wire [31:0]B;
  wire CLK;
  wire [63:0]P;
  wire [47:0]PCASC;
  wire SCLR;
  wire [1:0]NLW_i_mult_ZERO_DETECT_UNCONNECTED;

  assign ZERO_DETECT[1] = \<const0> ;
  assign ZERO_DETECT[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "32" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "32" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "2" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "63" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "kintex7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  math_mult_32_mult_gen_v12_0_13_viv i_mult
       (.A(A),
        .B(B),
        .CE(1'b0),
        .CLK(CLK),
        .P(P),
        .PCASC(PCASC),
        .SCLR(SCLR),
        .ZERO_DETECT(NLW_i_mult_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2015"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
CvmaYyJzAT4gGJRlCkE1yXt5Lv9gJbr2gC0wBzixkhI3TupXRLTg9s4Z9WVWp43QDkUuM3VRZjAj
RVnqESt3JA==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
hHyS2uxRkJ6sHR79RwG8dxYfMwySDoNzo0ZpVSoiAp/93R212I5J1LxM+7EujDw/cO/x9djlyxbz
erzC6/tIqQ2nS2hUZANmmER9YkiA1RlXlIqDOWo8pOFHNj1c4jf7Zdq7OJMDPvKF+fLgmk5Lu9Y0
15oIyfQw7L+gXpW1qEU=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Cfhh7YIOGyVJiZpd5j8xa2ugbHZdDDpkNcw6vvVCCgnGCfzlen3wlGk0omzzJqyVapnfg0aPFCVf
eH/noQVGu1bQkowx0JKcNE5x1v5DKH//UNI+lq09SNF0WKlMcTAGlNSUzO8kgVv9uNbKUHDXodcD
5iGh6bHMhVPSu1QKpTfJlIMd2CMz0JfDQiVbfTaAGKvrQhaqVte7pYpnqiXM7povPwt/ntWHBH4s
XSF4J4eDVLMuQmQNy3vrqFdEUqmQFtLWgNRpG2fwo19Y2lRzT3ux5SiA0Iv55uR6x7AG21x8BZlD
JC102ufirdrREfWUzlClY8zmr+TUHpTF/SgPMw==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
UWceDgHVHZAg17Yudaw03bncVn75AJ6y0RYlYeqdZU3kMG9E1W6q5REaQAI7sMZSrC2g0zavsx4w
utskoq80P2avoebtdvBfjr/nBCQqUN3AvM3GSk85froboZgk4fCQ8UtEj2Qk7ob+ox/md7d9P9dw
2YULi+eG04dUc1g45wwF0ZoZdARk7Ml+fXMnm7zxmvqVieAEsVq6ETZN/P0pwvIpAakLTayKriGC
qcrb1S28bOuV+Na/FX9rxN6hM5aK7vSdFqja5GGs32r9UVRIkX6i7uqS9pWQDR0Qa31W3z6wrRrT
+2wzEwNMDKYuWVIM1FQo/Tp0NKa1Y+kyjahSGA==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2017_05", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
tLsJPLnIUk5FSxPTGLkNhAFldHrP7oFH8h39nfqyEmnC/AmGzR3fePfCEcee3I4TYySABpWhyXIf
m1jGiCuHfIpFkF2EJqjWmBev0bD33cbw1av2xtJRFa5gaQjxChO9URfjedFvCQWWwjlxejc9nD0N
O0V2XUDQxd573YmSBuByzshlxt3bujEd6Xeeb8N8NI8c2ZsfY4693LGdb3k6gtY9ZEoo4XuYVt6n
S2tNFVJTfQjyBEXbuCPqpwGf6bPdy2SKvTE/s4rSIVTO08J6bXDaEOBUGg13XVoJJqrayiJRVuQL
LhoiPzgOqS6ude1uUaMHE/SN9X/vt/6uOsOl2w==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
jgk19ieS+ZYiySHKvgAHMus0OAx0HPJ59p64LMaYK8CyW0wSM8LIn++sFz9tsOBdLj2gb8IKpSVr
SOX9XXXM2pQFSME7x8q0m+EPg9m1+ghIpW4bU/w4zVq4NBjYydZCI0Hpy+X3op0a3+eENVEw5SoK
4R/zOL7aV/2nZ//wkaw=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
L/BPRr/PHH5da1O06dKRr5ST8eskM6lzR1UPuTvZQ6RCsFEjTD1HgyqjW7/ypnIq7V5TYDC553+Y
rJnEENzDc6RSpzenrYxw7NrURpUedIWlCc/PEf5Zq9gu1ESkpND7t98rc+uiAz7zsn/pHD/K50NR
q9l/gcWkOCgArmADo1Lw9usrfZ8ECIPKY2kLxeTYbh4fsrCpPQsQUk4NxX3N1Q0h3RRUCdHSFc0O
lvGip/vd24OK8zXDMaQv4fPmgToFQMUvLrJXErEUeRlkpxkcX6g6Zu4RMWwwmkNIfZHpc5K8Q3RL
MMc5rARUSXbNbpf28H3iyAMZ0y+EgI0CrKwooA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
q5LfU4j0KTst7h11DGJNjLbaIURs5SvGLq3xsrvYaRFSZIQVPNQNB+X/3ufy5jnDfjOpOrlhcqNZ
hZOGziElp5541aN0dP7Fprgap727Bv444hcfKPDFugSekO5/+nPh1MBGgUyiT5nZcjISKjixG3SC
HWkH74O9HcizoioFikP8arxQOciuf5ZcbxoHLvVtvfgn6ExoSHVqqHna3+1Wx185z2T+ltq6nUQs
vImswnMz27hNQ5xu1KEPQMit63LNDVh2M6nDnY27woRMHEO+gYhBJjZfSVT0/X10IJnZ6XZycKya
lSjyz32baT/Oad/AVOrgLnp0Kxtyuc4wy3Pb2A==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
SY0+BOVyjRuxs53/N8NrmL5YzdIcMr7e1dKwRSnes6U0duNqxOWUjtQBVjXTFZ5/op3jvnWYLW5C
i9iwfiPlmHtTdkhQ4TxeO45S4uJ16DiTVQfmq42bikiO3xcz4Az+EIuIkt/ghfs53hTgStHtquT8
eCJ23yhZv5/b2VZNCla5c2KOfrvD7mNKnYoeazJsYWSDhCBNvMao35Aa6CC2fFLSxRa31u7p+5YD
WYqKA2GkMPdUbrXy8v4wMPk4O7l0BNdJCQknvwhbnlaNrLA6NcPJSGxOGMMSk7r15Qj1Ochz+UFA
ZXJObxELooQYn4de/jztPgqfU97VL01jk4+A5A==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 26992)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
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

endmodule
`endif
