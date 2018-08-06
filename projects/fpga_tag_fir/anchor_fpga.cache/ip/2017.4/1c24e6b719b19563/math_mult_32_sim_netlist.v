// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
// Date        : Wed Jul 11 16:52:02 2018
// Host        : orion-server running 64-bit Ubuntu 16.04.4 LTS
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ math_mult_32_sim_netlist.v
// Design      : math_mult_32
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k160tfbg676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "math_mult_32,mult_gen_v12_0_13,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "mult_gen_v12_0_13,Vivado 2017.4" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_mult_gen_v12_0_13 U0
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
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_mult_gen_v12_0_13
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_mult_gen_v12_0_13_viv i_mult
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
3rxjRa6LwMGLqTfsPvn6QA5gLItAqUPpvE+wNfeOMqYgGDnwSaEer8fRMatPsjlStBjT5r/NaGts
wFj7Uph8Wt17Sn74Ss6BcRShefnZEo0V90p7RHDLfK/f6Lke+0gEE43d9otLMdBiFti7Uy+qJRXf
ga6Dd0tFZ7PVofMZXFY+9/kJhvnKEy1z34i2G8cR8jGZFRj/Ona3dxVvyIXVXJAWHe5UwjtaL/xG
eprLrhPA/WENg9rq0UKviDoggAVoCdTxm0mSuibgVuKy2qc8CtJODc/uI43yqMJrYuyZTvLt+ee0
g2WGoR3bCrG/ZvI/33OD/C931zAOUEVMaEEAd5vK4HVoYSXz+vSp/lLZuKs+uolo10uPNkno8b2e
zpYJQx9ghaXFotBFd/9EBbZ4L8J7v+woL1bVuJKA9/qauWOXZcAgPhk0tMz6xaVxpko4/XIpAqTJ
o/6Q+JAp5kmwLQPOe6+y3HKpQtSsjfWqYuXCUgqtLc7jKuGcgZjrVvnR8urr2480Yw0KCT8cnn2n
LSnFBeSemz9IT5aNulA/1WfRBJ/ZAcdDs5D/vVonWxKWjc0XrXA93WnV9WvqP862B/rDD7d/ymdd
JE2uuUKMCMGRt7IXaedZcjSdZ7YC5UmvXx1epztBMqO6Oo+jDBU4t8nBXJCG8lpp/a/bg5vOE/X9
9QvjyynHufwxxFi33N5xGDKReJ1RSFLLUHUK95Ayn0XXfJzAwrgETutXGWk+sNOj36yBME37Rg8d
LHyZLp4mvLhQYO4ZkFnnrnVmkN/RNVC9qKn6KxuirH0IcG9cwy3K/8RuVgFFM6Qn6EimYbLfUZq5
117qM7jKiD+JwXxvVB+SxNvfpeQr/7eZo7pnxotZOvZN2CAm2kEcYeqHorRaxHk0SY09l+hp3Qd+
Buj3p3NIjzQObOb1prFktahWfIpLrknMJgap9oLug5VY1RwUCUDrQXI30i1e9infoLBFJc1H2suq
CCFMBqQZ9YxJqwh8U0zrbrcARksBY4kn61IFbEiwOMUOxPtplZ2nPFe8AprHQVIPIMzGp5vbvyQg
GBGqv9sJOVtgLBUtbQlrnQxNQyhxQ7c4QumUI6Ob/0+af27355SdIviXoKVUvsMfsvPhwcet15S2
dkhYWl+UNBCk8knz/bMNDPm8In3UvyuGApwYHm4ILDncHknkKAIh1OOx4pWsOseiYtCecGbWsUN9
tDQg69O8JK3jMo2/a19cUwHbk01OK5ZkHMP2LN7Ve11oowFwniPW3GyNbSZ37/eqThas4yrjZyAB
HcKp+JNSMYjclUK/Mt19skRagSnNgfeTUuvlOxloLWZDIDUUFddAEu95uf7rCbc5MW+r1B/8My/C
e/f4F9C7uLPBMTPz3aKyZsSeTpONmyzMxW3c/GGfwB8dS6rK4BTudlFWAR5HCvXq2X4zf1Z6minZ
QYTN9si6P3wtWGzvO8AMH75XLs9NSygIzI/jAcxSrWwpM0qJq75qJJK75kyu9ApDKxfgQXb4EKMm
pz78yqZh/BKp7LOJ5k+xBHh5bdeFlphaThxFLDmFO5OlJH0CIGS6gzLknoF9zgCZJtSH2EOqhRMs
7YOhgpPSTzT2hRABvi5y2hxtHx37Vq7p98kYfZsVVrIYHV94hqLbenLS9uVjGaf8eUVC0iOw1gcs
9swjow6q6M7iGXJnj+LD0CjHG6CSr+C7J8+BefrhPC5QqfNyCqx7PxzWWEgKZt2GkdxKDjy2y4US
NlVE1GceeEK0ucZGxJcsvw3jm9rRmzyFMU5Bf56L1UWAsQVngwlUjXWq+NBP7zHDwUYfHh8mm4wK
F96q1jWJqXfkAmsQ05/2IBtikT/aaCrT5cwFswTNqgj1xHb+OL5Pm/qPM5Sa+vYEkDoOTnTCuYq3
jBrtgBTufyTOxGU1T46+DWUT5iyxTD5I3ADf/Sj5uvZwphz/lVXWVMeQbMsHb14tjAm0Dlr6ekZt
Rb90M139RUYMTxEi2VmqTu2qv0jNHIBa5AF/qM1Lsjgy2DFI6mA9H4Zfipor8PPll6K2A8ege/5S
7mBHn0S4ywijKoGAxbxAPOTf0MOfDUnn6jW7qo0HDsePl5vVQOFrzD9elpUz77ScaHD8Cdf8AfXW
qZO86qOyzt4GyUnOU99NB2Dnf6ApfudlrHO2oOZ6/oW7oLcN33upRmdR9QHDopRj6gPMeZ1SD8I4
j8I6miIk9SL4MCJENmaI3tiyVtn622EnuZPyj9N0QH0XuqVMQ/oJI10CTNd3y2OOCdS/hllMJa87
nm50/HfkU+oQMHzdiIICH82lqtCrwyCwXFhsa7C8tZxVCzxfrgruJbdRL0PrW1VteRONMMVDibJ3
7oRGs5QRbUnTFJRH2lDUvmLbYS2OERQmoL6dMeuQqtzOm6wjcQGsv0RKtflg1UEy/K0TWpzkSQ2A
phkzA4ZeSoBklrTb2ftGPUVUJt52BQz7bHOrLeYMKfevdN2bQxugWW1GDMHcpL0Hx88hJpRu3mJh
BqMTwzIVLbkRo9T249rY9U1K42KLcm3k+CZE+XLfLZU1FvIK7L/gi22OnzhBn+ltEEKy087t75z2
qnFlasN/7cmAgLIqqY11NWdQR8ClHtutz982Ru39zsKRu4ATYIlIxHU2NrsYWK34VUe7HTjSFkq9
TN9AiVpSs2A5+iDTzjkf8XBnwdGumae1mWiAor4PfTDPZZf8kx+AklngwKNXOQuJJsq1aosrFS3M
klQDGKM9cFvARJ7ecM0MpwBWTDzGo574hIDciwvRiBmjCw3SO4x2anSQ4bhI9b09d2E9giJr/R/8
ND89dr/HGaGdJr9sG/t9XP3Tq6slyVJ2geJDq7hOKSq9Qs7vzEKkBMfHUmnSvzeqyiNhPajTVWgv
L06Ego5zQ7HK/3T13iizqAAzVKPBl7a13GxYuP/ieMxnvcoN2pm45a0cJEV/CMf0C8wWcTriiRGu
PWMsXsUmwXoquBGgSkBBkg2HaPdS9jyeKC1N9OMKcYZu1x9vmPmPJmLma0dSMPhkGnIMd5NF2V8r
H+Kgo/g9uddDi6+EdLS51nj0U1RSvFRpUZrqf9Z7DM9jIP0TAc2zWQWv/HYoFXM0EYKOegrB/pam
5JPcThIMrh6hdf0swzQqnNcjAHUQELpaPwyzRlzWpzPLH1Rye0xpUho4SHNt6mgN047sXY6VH7Uq
hKMRhQbGZ3YuMdl46cYGoxFLpKW+Fb1Lgs1CmYeMlmOz/e4p3Y85FEMhMS3xq87GnaUMqfkYQazw
1pFu6qHArhOmvV4J9juFrN5OrHBYbLojAg91HNWF6r3AuucKnCcgWRUslyyRWa/uT+LrDc/eJvgG
J1TeSIZLGtvnZEoNz9HKtyw9CJNn4nBYpmT+Gj1zL2f+qgSvmOnKeC+ySxSIjYrCFahY0h72T5+c
3vD3mMN8ZtzslCUFdXIT13zgDGTE08U4qeOF5L9fGXke569S48MZfiN0JIDawnURzYNUVqA18GBT
FSLR/YnNfHMMQG16LtwKgrqaXlIlp2MdHFnw1iPEtceNiLa1I7akV4e18Ucs4Erm8M5eQxdycUsa
xwgyAFNIooAGGcwCkGlxUSJZe3+2nRbmPcnCWSx0VV+qGk7EdC/95ZzxzqpFoTPmZG8lwX/+Cj3w
c1n427GqKbhNcnJVNmDsHW+5PoFUjSipsCDFKtS741TeBXblEp0xCHEFMjSQuIkf2jiV1BwmpD+H
aCDbqA2A+BcMaj/Hyf6MfG3Xg4FqbsAnN7kuYk3L4yKr+tpLWPN7RkXB9ExaOc5BhQ/xghdte8cJ
2WnQx2teD+WL6VpmZzGMz4g4yIEKR2uWU5eMOtIDoj1M7zYwvhZcXjvFAF85uZyBEVpRzCLXKW+7
twjPwrG9jPR/tI+sJ90TF9iMb55F/BPuSB1HYf1zCjZ5BnwCZ3yrjGVVZFnLkl5oCZ061fFRqYeq
NDkDRf0XM3gjuZvekoyZzj+M0HWK/+AxN+uSNhY7w0zLaR52C5ySWxflWuhCXEkwEahFAEOeSg/W
1Hlh5R8RxZ+gkMrFAAanEc3IQ/m6tQdJdx5i5kyfWr2k7hVkIAeSmQTA5PUIn4HnAu6dpi1NvCN5
zbOLzkq5yBTUKR5ryfdFWCQNoK2zl2ZKNO0hcJYnq8r0nJfF+v7Bymn8EzzRPgcaOafYCzy0eVJg
3P6SgB3qS4xKmdSpP7X2VBq1WjAuOAI52VRsR6Lp45pcWmg8ye/LaTmmx7hMCZFqtHha4QH/SXQc
0Q0dky4ijyM3QxYbxhhrwB0vm4OdsnOQ9KAUABuKljhjTBc897oYiKg5rYiwBMPUlRYrgp6XCEs6
aoMan2N5BG6hWqwdS3rPdIxa3SW/oRdqCyAn4C7rjmOdt5ErcT+KOlr5Iv1qymJKY0AEvBxZ0wHX
6CP0OflUws9UdD/JgQH+QSYAORZOHWWbeabxhHlXh88U/slE8LpOvOuQshymogZj1m/iNPaSNaB3
EEapX6PrfDOaqFHlaSKGpMLMwpM4V04DxRtAr2LHrmrKv4+LbS5uW5vmI2Ox1Vyv/AphiF/U75dP
V9Y5BbnOWd7mI6i3fHHCoVir/u7d6XUr7lLQIpJlh5qn36kFXy+wjdqCOCnxs60lsiMXfWDCVYDN
90Q2WEbyIsZ6otdatQGgPor19iDs+rv7ry04iFX0x+ueU23B1Mgik1LLkjME8G225S3WhOP1zyxc
HFAXVRsdYNNf3jCZs075YIrWT8vCbyT7SbDJzztl+WcsuNTvHF0RLzThRPwn9pyKqOy4j+azhzye
mJkQe7o7M7k7SZI6UhFDNz9fuqmjNuTqyXNaf9jh3EaVXZPTiJQ//Ziyo2N6HV+eNDHaGdLwHxCE
qOR9BUf6BWCzD3K+25NKihewYwkcAbb94XMnpkgE/4ri5BCxxoOiKKwTnxdlPeZ0h4GpTtS/xepz
iLNVnVYOmd5kYXdSKArSKAJ5rPS8jQ2yBPHBple82/jE+iE1WRrIm+TQibbV8EB9mY7Cajk5YdMf
UzkT3GTkq7SUEarsi9lUFCX68kvzqtwO+gQt6PLiNevOIOcV7S0B5A6BmjuvTaBM+DjncBXtVmY3
YKAKefE8QM6HHuoKTpLaU7JCFR6LAZebl9U/BE5gVj3o4WRusyPd9O6z7CBxxaSrSbUBIJwUnTxD
D7at/AXiid6/S8ywAzBHcZoJIf6ulBO6shgRtDcczRny9Ec8RvThq/Wedm7jM80Unw/2xMKUVPf/
pinPGwonShCNqB6EpWTBSPHmCU3R48BVjeyzy7/H6iwQzP2qvLANimldzrnQ9LPpI2JSjiM9/6H+
2uZtfy8AiWZj9qdFpoHmi0HXgDJvVmpDylWM+BoixhYFv7kywR3VFEzKUvfBFirpQXaN+9+/frMJ
JLd4FwWYW5sLEUPfZ+rPHVOVGFYTxiOoP1tS6mv2TpsU/5X08pu5L0dX+5xTaE3eZiMS7dyQq6Fx
INpjRyQIpVr0sWeuZ6aPEOM8lDwBdoWmLKFMLPWtcTOZgzvPr2Mv2xKDqsTEWIDhA0MykfnsTJ+9
qdxRyfsSCGX9RQ8kxtRNRHxQkFDmBlmS/qy//bnZbdp2smSdyN5twjjPKzTvV5iAPTEBaCtIN6DS
hoAIgLBeU1pvtcZ6IxTnZAkkY8KI8XoiKYmcc4o+aRZt25549ZINvHJtVlU5xU4fHhA8J2bYPUMr
L/B+nrmXj7FZjHaaQK61Y+4s3/kzM3r9jj6I5HBmB15BlJpIGkfTvqsWvzRYQEgdROmEh7C+eqrd
RRIXPFmk+B5ogplCeU3rB/TkshQpcgY9kYOP2bI7hFNzvQyDi4H6a43UqF8XpXyQZY+5Id5VHwZI
vN3TmahQOO4uEqt33yXtTdESvfVXm5zSuN5rl/eTeBE93sDW6vv6Mx+1aH1Ep1gELXj3o2VR6wNv
4k+4lIiGkFeDRsKlQKbosaGKW7Aqii/y6ZNMr9nkl3hA6pmCAYRWGbaeiRUzXGrVxMG1goyO2Fnb
XHvNjfnkzaDJvAasePXpmN+QntJOBO5qpn+IKJqmQ8JltRYk+sG33gqz8xd2uAz4p/4hqTovdtcJ
MN6xDIAAQ9WDY8jR8Ss4udzGdp9KExtIIDcm+J6kpF73LZWk6XHnJhg1G+rWEwV/Zj53wFdD4/23
6zoibhxsE2FLxInfWJapMLOC5pxje9LFg6Ksns5yHZfXp1oe2eAOFcqG9mPf/2LKWk7KLPRwtech
8xngfN8JPwZl+kd0UzzdLIpjyHQQGZmB6UoryVNLYJHFtuTwMlTn7KI4w9+6XStCLGw1VHK4AsTL
d46ovLmFqJQDAYCLkejUDAnY4b8ZCDIq4HgNkMGbqd2bT6beKibhcK5HfGZsn85W1P5Juuja6y09
llhvrh++cVXI42e7uQtYfZzx84zpH5O0/5MA6C0Ojb4tfVmbfdnRY2j+0+uG0k94zrnAAYNnOSQT
oG79MozgWmy3LNkZMQfNLwTg73gZFFJ15w0WWLRYioGFoqVW8JBtmw/2Hr60Xug+ynii6OiEC1WO
FVfcOFqNWMHjIY3sjCEk3pULW6UzbdDtgyOeJ1JZpz7kfUD7IFad6bYCNUYmjZS2TdnqWrp1UzJi
B+ohM2Nxat8F3AxwnlQO/4QIvwUAA9pqY54OIDypBS4oLiK6wTlNQflW0dnzzu1fdNtquBEPap8E
aqKPle4WSkaJGIGGCVkFKkwS1ix0GCRYifyvrIqYZ1QTxHBZ17iT10T4+1KVCmIowExouexh6PEY
Dc+YLSbjreAe2uJ8Aep0F3PaNWm1YkH6KC0aBMttQCJwpNMNe9oJC92MMOp57zt1qCEqe9L0khBW
jEN/iRYTm65xbxAJTv0LjKkGiRBoV3PgDbKAXdLTYdx2+MOMvikCFbIiwKUzPQojS5zi+efSLqmq
ridxpQpT4TsmVQcweonaC4Pdssh1GhWvtBBcilOWi3Zu80TLch5zn85TnwbkqzVxJ/UnEWnajiBn
IvthvOeVR9kTN2Tq8rtohwWK1md+7z37Vm/WsOG0b0tiEuY+z+AB5h4QE63z/aCLTLMa37QiOanj
mp151zgdJ6VarNNS6wyWI19Pn0V6D7dr+t8xWLRgH/mVUOmHnctF9PPo0fJFiNCfcN8jnTwQ44/+
3acQGCUC7+cBDlgldEXDb3ZXsB2N8uuu/dJKBcCZm7+0svw4uY+kHbvqFR6ThnoF3ozL11D1HoeY
4yj2k1sbgrfWHDi+jGNDHYOMt+lCCvTzVL5KFZZ+2jBCMptCrsvoRllVYZTcdGUpZ7VHOCMYd64f
F5CFbwTBmpNAeyTVB3WjAOsKvxHFwuS5HJRHOsoFB6iab7i93jzzCM8+3NflthL8tuDYl5BYy2xm
Vrk8x+MAoGGt2uwiSptSWVZCL95DDQCJoMOBN1GRRobftbnOw5Uw/k2jhfXoQYii67zod5jF0MyQ
cSCrghnOQmhmbwWkmkDACzKJmk/Ik3RBKGCU31DrOt8nOQNRTxcQSxEmuyTkk7CbDpZjD0al1Ifd
phdCTOiIo9mL/BwUqHBZb786YCHPJUDP7v/HVDMm300A4svEJRBI7DRfddR63XWgiLDvYNNbhIBy
q4mdGehbb7Pbpx3ngm3h5/aMdGDKxMUvhKRf68R1VZwswy5eth+vXfkDG1KTERhiTwngHGTauusF
8sxOEMc96OZ8YrOFx+qAWBjslrL6lTK4/HDq0Z6UrryYX90ZpEZZC8ZA1ZwEemGdGsR1YMRAW1b9
maUX2y0G8sHdU6O9xPv5kvnD9HV1oQ7tamxQaonpfPZzSfvwz0ExWL8lglMVso1BZCgJcwJ2Gw3r
bOi2Al3xrz9c/Iflnob61fIBf79cdXOJ31pU5Sxxd7z7lcE6VPztR0PoUnJsHetsGxnORdFhKh4i
1h3Ckcoyerd6nAwBVjJ2iKrpy5BKYQYFgmYYp4XSo5+MVe9n0guFHiJqkUpC03JQmcCe/DG3+YTH
Dm0Ms+19KnT9KhDqOqUHlCpjfYNFZFIuq5DBSotECBUrN8W4fFRiJy91VWPE6F9RKrEsmDCIk82w
qJRNOr7fEzJxckMNW59Yr8q0dSHhM4VA4GgZn+kK8Qyr+hX8qyv5ajrCR25SXKr07Ol/YIq5oan8
WusJVyVRhq1IH/CpzpKbgylpd2AnGsmauOjwjhYCkCz06XLh3AOV0S7dB+kCTqh4JQXd8ggJ/tme
l6tX6TQl+zrwL2SvEEiIqAKdDiBDIW2739BA/xP+osCNwclFZM6TlFUHxDCZdGXp3/uVCnCe9sZ9
wPLLQ+T86TmYFpRI4P3lFKMEMb2C9/cDxYzzaXrKqiVxop+LhDbNvLfPVcxVK6DFGa14NNV76whg
Wq2rbgSYmUarwcSEg/0VtTums+MNire3ruqAO5Rfeiw/vtGEu7GToQi767AdBgJs4M3v+47Y0cI6
VmJAkmL4IraAJbpLoVU12wXwUfxVxgy0TbmtI0Dl0mS6Tea+gm5tV2yWP4JEoTfxLVHgRbVd4ZlW
rq9xPnlMCr6dScXN38cQfpQQN4MP0ZXmZ/oIS/UVDQ4bX1t0QXGpil6jTDekBJe1NZO3tyfSHarv
koNibMPQwZLFS+F8Fv7jheprBCL5XyC0bjV0XhGHOkaplYX7i0cLUc9B3wZwSXbmBte97B5zyHPH
W/NSGOjO6jLfT+Qi8THRXNP76jr4j1TIOXyQDv80vhLCoHtzyWGA2hyo3wgRU6/blK0u6jHgj4NP
KrFleQixBB3jvTh4XUfFa09YjmYwKxeuA2ixcF5tBJbo1ek1VxlBU0zn+CpwJAKMg5HTyabk0FIJ
jAMEXOWK/pcFYV+OeHslxhfOf0IYEeqs2ss9uD2dOJimCfvad76ilYDj3LbgYCIGW6NVr2m+Gfg4
vN/26BBdEHFoeGcuBEQGo4kkqo25v+Iz7Py5pWUCoGKfv8QHQNdWqpmhqz9lRAZJiEBh/eP8HryQ
pK+BQY1bBVVHEq0l2v3sE1ebyixE2qfK6KyhsH9KFUDPaxV6/bgwodXnttrpDHq/XMMybIv06udO
s1/z1OhblpxbHMYTzKUcZqPpXDSXR/FGSuX3nyrFx79JQJ0crDxW0bansS0pz0krIV69OdtfmKSW
RJsd35zXvIjWH8y3hCAl1bLesg+BPG6REyg3Pt/AmiCoayidlbzQ7hG62BtjZSJQMnvoCTnkVtw1
zgNDwoCh9eWQF/Gnu/RZodvPy2f0pi7vKOV4ZVPJZG8xfw3rrztZY9keDQs7gzLW6il06d+afllr
ALrFEawTsB/8IqXrZtv6mnZG0/IWqTGXsgvyuA1ieprTAqgdwrz6H5uX5RK0rIA46ttBN6cQTvIF
1glZG9AcarUMEnwiHwAif7pSrlDzKW2PaUmqvppU14q4gkmWNIeAaJZSIN8BvUxP3hTbYzjD4vBP
qsTgV3K9A1DAkZA/KBUwkS0evlvzhVA5HxM0Q29sr+F74HEHaPSrjsg73V+DO8HON9inJ2ge4SmP
Y3xj6/1dErafZ4B9USXhNj24Ijn862UknM8bqFaKBdJfSDOw/f4+mr9kD+nIuFUtweca8CbIeS+T
0hK42LyV/ZS6SCuwvt5axwEGSp4faGWGbgwyIx6E4TX+qQRt32EALWKDJHIOJ9SsO9ra+ZiLb6qA
FY2w56ZiR+wydPrpAPGQkHRjmyu2Egj9wpOIqaiicP/WEW42D9ZquG8Jd7wQSmOGTIMtE6zMXeJg
MGEO0BUnKC9aYfM9jTxU7T9kZnoZ/6cqLrrN+Bfwk+SyTs0o6vEOhUAt18htMK7AbRauyNfwnQTN
mvyTv8MTaeInk4rqawpRVUZb52pj2AqGfQ+XbWHPcQag0sctBcr7eH9uwVnKlX3nlhc/s7iVJGhT
jxIYxWzDS9KRsyOdGTJuUcpeRZyG7Bup5N1bPB/gISZFZgVcOqx3Q3/JWySWW/Hb8CEDg0NPYAGd
BXn+v+RL3QmRETEJbHcOqTL1e2q8kdQ8C4r6CCLXEq8eRV8HPPqATxpK4re87KEr/t6TrUI+AgVv
/uuxWJoC6FOo54ZrAdlerFFm6Xj8gizzR7tzA/nBz9L6Gt2KDn/L+Or5AAARE0sXORlrZc/98dc8
mPKYSfW5355qirl5s2RqrE2FSw8a3Tta8aC+jeCdJhxzRRxsIIGneS2Ad4zT1wXkH6WD0SsMIekN
ANoLkwIo1jaomhd4Zu/D2VgVjWEw7CbHuuPoSPSFgCL+s9zFQTAEWy/lefJUMA2vUWhix8R7lWjL
Xy13+VFB0/Qql/CL3ElTexsEiqJHp+InQ6y3VYu3TcCZ7Y4rV4ZOpKjwdvkzdn3jtZ+c2/ZcTmvI
DJU4pnRA5JNN48nioa/zj1YaRUIslAizM4ts/MTimlfxnOdR8NGE/QP+0gJWWoYw/GSzbsBwxWYv
mHGrLCapLSfv5awdAMmYJp67E+3bCyZlTe+b9LO8yZZ5zmvVP38rv5haVg5KIqiG63wW9GfA+213
/9tp3ChfLRzYwguzJehXIPVnO5RtzsaMeQ+4SPn8BdDLg/7VT6gPdcDEClLBEIkvorktpgShR9Mj
b5F4uiHEoob9qAOz/5aZOacZmgm5acXawV6RnueeYtHOyw29b6+BFPsIWrkIXe8vAzfjydrVv8mK
mCQYbXDFxtjFj/HsotUQwIyDUrj3Fg1hD4oCy8LgbpPWk6eeQO8j8OytzBjcNo4JLAqXzDS6GRNx
9v9xvkyLrNKTwGJ9lxgDWvy/LcUUQUpSkNg5I8rYMORKGAHuivzY7wxmJ4WWxaCyNEk/D0EYFeJb
nujBqTfdtPlV5FAm6iusXaGuFPUsLeDck8yq+f4xQlCPzwZtQZHEKn3QjuLPChCyyBVnTAAMGDY4
QAcwvIE6phidRrtTD1WAjPWxtD0soK2UcdEiNi+UdRUADVxZNUxvN4+l5wDRzaKUeZ6kf4pEiuro
b9rnlQ+8wJ3xFXPwaJRud3fH95fJtviL27v/B0agpamoyELTmmWHYlfBFzzRox0F8aP65w0fewcc
40A2Gz3rAIFkirTlqOAgLga3opCIEM9kJfHEJEUGL4oy/d3uURnkhKmMEVGi6bUjcRdlhzei0y/y
lqII+jB9kSI0E/R1UG9pmB5C9m1XSp0wO9TlfOK+eyFqg1uBwWfjzx+uQsDRtwFG7dyYI/ymBIpL
maXNIsaXQNw8fF2GV+XSLBWMK2VljtzK4sCpAODYhNA0eHJAxxzaRfqvMeF/kXw3xCHlKER0RaBc
XXAOjRM0gbU49PQnIgdCRjXy06ba8Dk4wBx5cPF34IK1v4fAepQ4+fzLmSEZLQ/ZatizZrKuW5Qa
djTgAhGktl691rPBzd7G0RsQu0KePyE5tztmAbyEwdmr5ZmZR5xbxVrGNh/x8LRWIhEh3OPT1DMq
vhWEeuHwV/YB8AT//Wkq6XVplEldTeXTXniys/GxlgjBA4FbUjMtPz9Ps/tG4G9kU+NiQU2XIOct
+ZtkNT1DnuDoRiYPx39Zwr102xDcdQ/LdIQJif6wqz+c6xDqvILwNaVmFpxhU6zEPU5IPJjQgO6A
lB0EV+nC8M3QvBa4df/TBOBI4F9LOkfKWS+Ztu97q4y6q9DIulq1F0pmfAn3WawgksuKdw62cCw1
4IalZaPrtX1VX+1Fq+B6iHzB47l1rn1Wnr3IxVXUlTptxOTnVYuttK+z2DxtkHlEDr+kFATyEJnS
tJm4ZefUnYpCl2J+hEvWAinrlX+jPjE2rDTeWT34Xj983xGAovPKQ1AUUuPAYmIISl8I/CcL+SkD
X/buO3jA8os1yqkDolGAKRvvwmFg8nwYPyd0geGIU8kyV7sEuHHFVv6AD2mng0izWzgHwarQsWLa
/xkqDt0fwNCMIBd0mfHpwd7Ryx++sCMXDh235BF+RE/a9YFe/wlmbTSfA2ZzlepTXNOa+pl/9GeJ
9ML9GnAMWBC5kF5M/7UsyfIRC8UP0wQNoWAJj75vO1o5GWLyT7KhpzSQbdcexG4i2PYm6C8AlewH
pyQQnfSq7mLWIGERrfbUXWJL36aEXn1U+aBQIIudB14OOIQ8yNnzEz5PNs67Jtic8pUDmzCnaQp5
IA/jexTThW/OG6dOYj3sKIiguAegd1p3PaTHMG4P+tTwdKc7K01m96X92jTjWWTk7DhUFwEuIxtD
HbiLHOqwUFeeV71G272p/9H/0y2VeceOiUjB15PyyZLiV8ggGyOSyX/vaJGPkBv0XdAE3rM2znnT
OH0d9OXsbT7nlLNi1iHENCtcPj0JZDoXMrCLPydCYZ1Smv77DLWjFDhOeZSBAWG6wexL5j+kABvl
/QAsKLMJpIh9QWTIQicJNEkxw2VDXywnpfKo8KMiyHmk4EB/UKxA9EQBo3WQ4gpvxZ5UKjp5yeT7
ZEE4DLLGsa4ClvJ2kMMZ3XzpvEtv9VVKrMdQ/OfuncxRsKFy6+KJxZgxXeQWpwtu9DE8UGl2+/GP
u+S3LZ245RnzTOcNN2PVYSmgSck1KA22lFMJu3wIvArkoOx54jL80qjGCyghJvmyIIbATXA9E3Mv
PVU+ttW03/rN5CED0eLrq/Aj/dKmClMN01wpaHI+IMRU4SnnXG+OlHkF2VlqxrjozHs0/E8s6Pkl
xT5bdrma+J0mfdF3LwAWqewZNiKjoIRDzGD7KC/YYhzNTSlcNUQMYFMZvsAZOM+l8DvIVTTxaoB8
lesDrldvUSy3pEO00W26si9NtSw5ECUUJ+4qoJRhqtGYfR4dUtEme+CRd7Ml5vDnHF1fr10/hapV
a4pnzZz5DscWjV/FyiGXqNdBVuQ/pyfepkWGarDwHZPJtQZW73H33xXg62SXGzmIG+0RgwZK74wv
LR1OAn4KXmYGFwiDCEMB3aaaz5JkcdeJr8BWxhf3nZnI8V87ktk+WoYuVH2MsI3D+ON3YjN5I7LA
1uYT0vTjWXtboBsORcGy2dHd2cM4R8X/3s9EdP90fZzd/gt+6N6BRd3ED1+bSeRcUW6cEO2zQFV8
VgmN2AHDefMK3o7GggJ8TTQKMIUv+/VXJb7pxGGLvmkspuMJJdmTF5whVNgZl/u6gh7H6/Rr/LD7
zoH2edPJql2khox67JTQAXMZzrSVsHJcL7nN8j6nHTMoRWRRnfIAnrQZgmIpvsqQ6hZJlBoJFCay
H5MyNGPhK9XDDV9UnM//Tz7G4BmF8z/fyh3mC4HrocKvB3Mpl3unhpmvGXNTcP4rJl9+1z99FYJG
Bnal+yfOXrDx61tumI3Q/PjWSfe4nr04k95B9/MDrwzV7cJeE3n24Qa5xzksltSF/XTidMmfT5L/
my8QOhxz8v+WB9yYFAFkhavko47ZpWaecYVTtS0h3b+ETILcd5aXiGurLRhGFJfggGx0W1OJC+XJ
Phos2dVH+mdGjkXkd+Bvb9TNTOULb9fyiCL6qeEdQn7OdeZenllp03L4FxK4No8C+KjiPT1Afp++
nZDlxzLhZ+8DYAndUdmifHCb6j0ofmLgaNLIeVoR/Uq+trZ7BgxJVzWTVT5diXS4m2dsV4CRMPPy
Wiz6+ruxLdO4y8QMiSwdC99+8Y5tFi1Yqfw0X2lgU0I4jf9jie6bq1HV6qBwRTTR2Y24iWr+m65O
NOGHcZXJqtZvOtsLqrfcYaSa4VZDDxXpS69TNVprhlnNG5brYkPgJvJk/rGKVN/Mf3HaaZJucvIB
WlJhxwFcuqMMUuT5yOY1bwBeG1OFa50ZbRHECazZG+AgYtIW96VOBn6uIhfZ2Gqe9WPBrdvDpEry
Erp8rGskLsGO++EZ0pFb9W5yjNGB3mSlORH364AC/cwzgI6KdrScBcN0KDOGS4HwKdOqwColqXLU
4XQofvJlu/UvV3SQQLPofL7kYVzpLSxUFVwoG3VmH8HSFHrv5oQ1QXE94HYSO1Rtu/sQmG9CNkez
D24xDWuctRni5LMqCHAOAl2tHElzuSlnDopFGupfu0ZzmrAfKbmfq/b30ht0NGXqJT7czpki1Pb8
WWvM0JC2U3wPCMaqJVQPShEV5iycxZTKXv4efCrUnXH7oyYsnNy94vXCLFLUQSK17uZzoffxauSa
XG0gQ8+/WjI/vJtXtUt6n3l+Jss0F0psCyRKpp9XW6mtNU8/Rb+dlRSDjDayn6wdQ+uxgyWQM5Tn
csL/hShmWgYUWi3wZzxva8mgSABrM9o3hqkcDLj67ni5VR2NCXh2I7e/esGEr8m3DRXVlyxA+goo
f3MLZi37iLtg95VloxwmvR9hKMiiYpYnSTVjZz+EHrYccfpxlO8c4and2CtVSmeijJsgkp2HMaD6
cFGCjW/edo7dobMINujsZ36rGGen5jUURGT68QeSkn/PJ66/lj5wAoIVhViHAlyXoW2KKX2QqVaJ
wQWlzlSAToavLqOHHjNcOABu5GVbkX44s57w4bmdEZiP4TMqTh+TXtoHjdSE+YqQsWqfuXnrSFwL
ZqG2mnF/vGUzkDQGpbAfy2Z5EjYufg1uWjQzMULHfs2CebkmFIQLlcBTM1+nhV9+6GgrcQhFxrZf
RXXhVbbAq+QtTmaFkbVR8Yg1JN3o1Qqd2DVJDRB1mIE+ojrL92/M39z78pwSrVFznYR/EiB23Pic
NKHVUujpUqGTMLXXsVqoX6dhaqIKQtxzA5S6kl8i0xJkzX0QS192ttX88mjWCov1EVCOfrWV6hZE
/AtdklX9fPfLPqOjUOI8reMCo/0pQEM8gf16M9szACli8AXmVvd3wCSogtjNNar3Gi00rnK/xmkg
1x7JgjnBeytaS357nQSz1+DqQ3EXnIfzAk8n9HmUVeFzQkq52XvntvRGd34UYno/fOv36FFCIYjM
Emf2bp3fotzrzlXEE80YBHeZFmdIgJbclj4p90vLiitSenJgTdSuzEECJ/412MRelr89kn4r9Nz0
9psdyNFJnmf2qxDtPkXCJuZbC2SQPm76xSpaNgjOok4nPNztOTTVQClFdU1fro+u7F3MtddOPA6b
2qEcc9fJZKtGe+mkzfVw8NWGQ3rPqeWcao8Cz9AKZuRkl5zsLoFY4gS2rq+BInNnks7MKpxIR4/O
sVFoCz3t7ut3c4oF8J3xJUquBDenDerTQLqSgrq5MJCx3DrnWUendwhakwGsfzeatju3BdmSf75r
Rov9xR8K9HTgSVy9m9JshtBwIaZswjYdEq90ETJ1jPbm1CaYp+MoG3DEnigKx6N7O13X9ZeVqysE
Gw8B3iIHPhTWwu809UvHdTD4jymW442sSJrwgO2Tticd7DQXxA2PhlQR8niu+sro5kEJ5mNq8vpP
da7pm03SEn4j9PSpGY+ajKZiEiOYAtyeJxv68B5pF4+I+3dWFR3hugA6qia6O0jsnSNDtXFsdvaG
nhzERjGuoMbvFkZJJO0I+mXHkMN0Q9BmeJdcB50Dec0b28Q4hsNEt2i/8VUBmXjSBXQ37fHH6b68
Rw6q6w3qIuQvuexefE09qu+l0qYmlLQJ5A2TFRFuPGHg7rgPTEkcO0Bi8I8ykPTb6C78RUkAi+go
/xyUKZ3FDWBaihGqoe3tGXfZFR96KIuhh3LQP9SJAlHaDsPYodnSIpY4Sc7tC3W8CU6Aucl3KC0F
Y2rdSYnnYz7fZ3tBnC88JAffRlhJ79r7ZYlo32We50HOrljeGRDFXHg/mfOIcCwkXMOy8nxnzU4O
fAVos7/9uzk9FJXMcE9KQw+DSQ9nLJt9io/rCoIiUuz9HWeBhhTGKJgvmatWoHSMeyPzRTS7yz4a
VxOZF74HKLAm2G9gX9ZcNWkT2SUEt/Bc2I7MrL1owvx1+Z7Hm1S8AulPqHkCXfzQPK/xstB/1PZX
K2VuiYUwYXcYVbF2iXZ1zZcvhPsDM62RZXmCu4EZmRAgl4Y/rcm6VXjTogCN2vqkr1DqbALe7057
QSsNKeL+fq8t6zRIf8msO4+athrRXFsV4ifZxhUhM98niGmOv5GZK+FE3lxiysaTEq+tCl3bdqs0
l83x7moj7sgN9RhlneAdazABX1v1rCJijjJEq9QT8j8VZFNx+tYrJWMekfWTlUj+I/8hJL6yXptD
DhnZ6pXCsgTuYUbZ9yJMLFoG5SGb6U/m+4kGYpoPWLB7ODwZS8aWKWV3L47IxJCKNFbbDbgJgQ8f
ieCdoAG1nDWtOKYjD2WR1OqGM1pXLSEPh1jaCrzeQ9ogPG1kwtK1qzhVX4VSGmObQK8gryShrfk/
Fc4GEWrmYSLuOhglP0VSoIuY+b/ypu3Z88AYY4AGs7dXjYGQq5oWwe4AYkWVEqhufGk/ZCpg/cIy
HjsKUmWGHWI3ZiBESCO7TexsK8ebZbf4h/lHli1co4GTz3oLQpC7z1hSgMts7U4teHY3/y/nCFsB
nCJOiuo28LVjAe0rp1nmt6iVJfgpoYTseov2yNZT+dNP8UBI7MjbCp/kzVwyyClbPmO1OAkgbPmD
M5HajCGqePOgCkwJTvrkU0fcKFQhJlGQFQVOwQMqvl8gIYJYNqFHtmWwYM4CfCB85DwDU0n8ULFB
dF6ghQqSmkUxN3jEyYd5PetSsaT9mNMvLZaTrJW/gv+1f/a2q9xTgl7gL6y1TKSfb7r4y1T/owoG
4zCW5SA3MmAg2Q2+9b6uL+l0cEti5C3VV/hTj5I+tc3S867GCrzvDtsy2qdCB/We6qUE8Y7nujLP
IAV+TiCHsO/28vag8XHZNFBLh1iF3cdQLYNNzcl2qHwV5t7OBbWqrCvBZoMGY4zj1BaLjruFDvjz
0rYqToaaklO65jab8piXv+I10GOAC52VvkgsrTk+nDTWpMtm62fhYXQc/0cANYRbZ5/Vpr5RM/Ky
hNdUfm2Nd8PslAMVzglQd0NB8tyTYn2fx05W8z+swQDJmTcgluJsukqA9CwJwr5J7eQOCNy0+vmG
GTRPE8XTuwugSrGk8h22CT8TuVJSLD0VV3hMByyB3yuRMHXuYVVjlAjiK1JsoK5Uz5UpoPtTHgFD
mxpqkpSgqjszoUi0I4MFSQDfzSTF+GJk3mUjaxxPq0Sa5b3nYAVt2HIfHLXS24fkfox6VnL5XkPU
M4BvzHONv6Rb46b9DY3djhXf3pcLCNuV4CsqMeKldyBEU1lLF8W99rdKdS3QPF2SvLMIPOxQdMAr
HRC0+ulWZ5v0BfelIvkYTtwz3ESZy+n6b9skQ9IjDUhXmaROXu+IKjbzGzkWDS30jSrieAYp392Y
iV90cLNVmtCIuei0O2Pu+/78PXDxwN6vIU0N7dY8CUJ11Qz7hi+KJRx1KO6OXV3DK88RUkRINZU5
rWQHT0wCN/TDuO+3aCucn1oUtsL5EGOsekSfwE/GCC5Mn/ymDZM2BiG1MBot7p1CzBzRgQfoBsuV
jaTcjkamFpnEBQr9bR5Rt7LbNnYlwvJKGgsirLTYG47tiJ7hZ+X9O8m1TuwMWhEPkiNxCGlD+ds2
nhFkP82Dt4u2zXlqhWLK2q0a0NWKxZSNYn5iNFPKhjjZ9moxLRTVdJ9oCuI/+v0OEQOuief/yA3F
QReQVgV2FBDN5oDai0/lOb3D7ZPieMp94r55mO3CJtipTZ+mgWWqz9E1uUcUAaL6qXF6LrZJKezQ
pbw64G4WD4y6syUxFZT2pLZ8p/JwEni59wMoo4UVyodry2ajC/x67KbUKocCC9+x//T2eOEI8kV6
KhtiMqzJ1dSvcW5Ql+j/kwQjFY1H+jYZCPY4M2LMwF57FIMIPCpotvlzOXihsmvKIP/lGhV6tuEU
bYpymE0q2rqfFCBBgwn/otwSWmpUr+tv0TvlMzQSye4INLs8NTIoZmn6MTra6Dw5+N6uK30ZgNQq
vfIH/iczZC06AIkWSK2vFcEo5WrKXhLv9xiSsR+BZPQ4+E97gzR7bQIP2uj8/Q17cLpOQNXUJ0sr
gFCgKAlwvIV2veqceCPyzsAp/t+9gd/2ZQ5pa5087/ijPEwAmnKgb2OmDi7KsHIWnwozS3w9BGu0
ZEscTb59+Ti1QrOxRb6Cx66CVxxjpryzyroE6PzN+vxGdmNxK0b85qj5JO7w7o79bQ7BGHXBe984
JPi6+6fRlq32D0AJr4c+q9xxtH/whNBQiy4TqScdOa6h76MDsnmJzpqE+AWH+gvVwKzfOmaybBaR
g8Dzgw150KE9xdDUJeTKK7WaG2OHSe1/+M5hXiEgUD6sXY4/PZ0NcrK3jbIi1KJwHtY8UV2mYESA
oVo4UvpaxAFp9GNASL8HLce2+87C/2ZgffLHZ403oQH41nT6aE8nlj+vHB4V/pOjH0U47+6xlvbr
fX7t/My15HWyl48bvgbEVi9Cz1j8m3ZzyMrGPdWOUpfivKCdJugojLguGoX9qKdACBriiU1KqBF2
RV+S+Ag8/4y9ofcPH4ufXMWJ0Xt0IADOs0AFh/vZf/JkLqepY9yOl8GspJepKq15E3CZfzj+MtyK
oU3n3evis0qByQ7IV9UoqEmUx1RC5WsetW5HB3UFWKXtZBBmn93Tgz/qTAagVIGGYVlSSNSdLU7M
FnN6qGj5cjGsY7hJBovp/s3qhqurmnllJmFKj3Go9pKA8Xd6R/ldpPZJoFOzo4tW2aNP/Hv9dSjH
tnaZf92FscWNk6/2zcUBABNl625zjy0Mof6Gw+VThDNwRX85gYBwLQxIGtOzws+wBhBVPYriHlmx
lbQFAJfUQj7h/Ke9LgWsfUYIUAODVGGtZ1J7B9xEEGoMx6jKIn2Z6+QM/Sdz4D5Kt+KFLdHLPDiF
dVf3tgWEb+aMdFP9b+oPHYVws20ztfU4rNys2G5ZEO76hlPb4lSe+/fOTMwjgmPLR/j6wfS/5yrL
7POw2XXhzpMS/6wTXJL8Go5lG2w/K5VeQrPbVvMvgfmlN9O4gKMaymQeOJT1nBtVLQAnndpCtSmE
+OBaEeYtjATG/2VwRr6BsSifH+s14nM22oei7ytTF4gQ6ENsscpPBpCdcwY1vQ7stoUHmI5bmIOR
sg0U9nihKxK28jTXsB0vov6O6FUXFnic6sJnAGTnmiAhnG7hXkaONMHOpaPK7ZsD/kTjCL98EuHt
zUuoWBSw+f7pGJjdqv+30Ch2M6MBK+v4ciXvAjGGXZNaq7GYTirfR2G50MjBtPOnUXVMNxOy+/dB
eoUm84hrDNzGCYaJCP4e05VFGDX6gYZbqeNiYJ4idfZ12BDJUQ3OZomX2MsdyiT33oAButkJcqOF
AAgTcu1+UO5m3M0hQcm+y5c9mXRbrX9ndxuuzyyWSoPOW9wNRXday7+uMfPVVlehMW7z927J+G0V
G2U7G/H3RcJdIsFgRW5AqZFNYT+64rVQJ3bUMG+AfS/1zxAF6wVSK6zSuS1QZDvr6LLdHE1uccsb
YuwDxKhlTBfcILkB9Zjl1QFdG/9iNe5pZFxp8OX4d+zTmtt/3rrQ7DPRbZhCOsTzQnDBKXIqmDG2
IVH11vUno0xDseA1L1yURTDxYmEapRJSRPSr2guCj2sRGPJC7LFVearYgV4c6zlDpVzgAGjkFVRi
UH3I+amasMNqgIHgily8Q0fHXyRgKiAZWV1qb1ltOOPaJiH6aObAwQ+vG6AaDPaGKKHa7FeiBmYm
BYIaoR04SELT6Dc1B6v/adHnZsbiz4YMKHZdSXoD1L8r2oaY0zP96nOiDZSFbTxCOrEEIuk2zAUt
/MiIafQPJIVsnY889cUr5fYrPHVglcwJ6WdEue2mPJ5t5pW9WcgaOA+yQVDDLjCR9fCWWZHG71qT
15XhAfkC30IUFYO2zB486JUvXkUTHE3aEraKwEpcxyNvBM1tmcHjr4WNidTumhWNkNl7cZq0gRHI
/3pQCWD+jEkPyuUj1aLfbR/tFjKeZq/9qfErfr35k9Rjf5sTo8BfKLWtRUVr8nGBV1mcAmV7KS0Y
+1NZY4RQCHiuHtlPQsDe49r1ySpFtuzI2p4JItr3kS7juebMNgHakRiafwJMmls/TL5JjUVpXG8Y
5z9R/WRM6+fjC3rYgrBqO6VVH2ryf9I8f2n/gWwssTcXgb0d6auIXDn/Qp6k8EydEJ1FfWi/wgaL
uILS/hOwp+5Gg4Sd+kMHeOFG38BPd4n9c/RJ/zPI4D9y2h+Bx3XIfbUl86A4wXRxJCMXr2vwsfUm
ZKn/26G4wBsP+Xxd1/tcrtqScuv02mATuLsED4I7IDzLO4ggMi8MuZK+MaognDhwdXOtTxYMdgS4
80oUeCkDfIstXCZS6hCEm61NtJPFeLzXcq6WyYzswbFBK7eCB410P72oWhRoe8VxyavK3QyAm+p4
7uI0Hspf+V37JmXxcl5U/iGJypHDjAgFvoryVW2vLqjvTRQDpqwcUiFeR4t99hukCHpYDJV0IwEW
s6jEOzQdl1eRuxCIgEAzXtEFMxHAMXkuzsE8ARkKKCndXtqWB6FuY/p+R9/9Ztpg3Eui6eE6YgdM
qwY2g/xwCDXaqXEsbl6C+g6JUljg+sHOzWTW/JgF3oL0RUv2EcJSJ/4WoIvmtiL91sBnV3a6uXRh
/XfIlooab4FOqZb5BGD+YoZiexdI5sAHexQOEYctRDJlubUUBq3Bjsu83h/MBCpFK+I1X3qN1wCJ
SugjXR3Mj/lG3nM+0yurSk4S3kfsWBJ5NqbREdH8xrCelVYb0JuCCtbDnYYnmPcXGxMOI1T92yLA
6FH11tUAFLcDjoJD7ZR5Lspuir8oHhu612/1GktnWwEAD7IafNQ8pEZjZyNtLEZJnZr5GD3YsSWQ
0pnAdaW5uJB/Io9Pn3DFJIWpjn74P+SsW2F0dgOMkgebW75Ix7Wrb/w57HO1qMT1XYs/OU4sQfPY
p5oS5mp/XqQqgofSvhZt9Ix8DYlo6SKuQT8T46L5LK2/ySQ+FyTwi+g6JT/uNUFFS2AVd2Crtjvn
bucq5TGuz5kGaKwVSR4VjJ6Y4SMuYUVLONuRJ8qC7SM97VWFof4cVgZnMOIbMmFUOkFmudRrYg7d
c0zeuKDOh7gQcKmRb/8tu+zdBMviWmFbM/OaGR1Jr3Ukb8mnMfbT7dxMIDcVrzpijYQVNxJ1mFg4
aWotKE2fJf4ApgLllDJ9wTi6Bj09HmLgmIfAFA5+rSH3tnhS06DtXce3TW28P2NTR914/O8pzjcZ
JBIA2x2EabW7Uac/Y6jfkYxu10Dq+D5O/nOLVPonhaO6cF3XxfFgmwBpy460v0SJtTWTKZBFaKj5
mcciAyaCI7mUdn/pvIcaQuSydMIHWajB5O9AJhEDZqWFU0pVgWa/lmc2K6bc+vXbOXAF4zSTzSHv
QMVvC7SHoA8eXv0AHz4OFzG516WpKhMrcDJl9UU+KclEMMeuY87LL2mh0TVrsycTLDAa0QO8wcbW
yjIzrxZl3QvB2ZjOZlromvDTlqS4+BoceiWfGpj7wCjiXxkQdXvWepSZ0oZkGLiA6Xs1C/XNTYi9
VOhyqQDF+f1zvrFN3k8abKIWZ3byHKmDwNN9txvJdGK2ly1C7cfU06YA4QLVWp3N/0q3RcLqzGMN
j053dxwYuQjnONmR7w9uMMW6LhZiEMjccRCjgrqUGAEvn2ulfwVPJx+UthlbiOX9086frdLOcxy0
sGAq35E7wAzWsMyH7RYayujH20Xkoqg+BNwM7lxnwOoG+oOGD0dq9ypcSkgNdPoopR95o8dPOp7k
RfhhUdU8LUpG0kIM6x37u77KjoI38QmGYbuBkVN1kV+UivWVvQHRpSLRM/wpkiZlC+Mwf0reWbhX
Cpio8B93WndRv+m09gY+wgN+BBfa5UpOL/rnPrq2P0/0iHqtbZOoqKiWgFLtApHJwZHTLNin935h
EGTn0auBUdk2cKlEkeynkzq1e/Gy4TTvQ2WwWWPR0kgItcUcTYQD0FOAOLwxLGTsd/2ohKGegs6T
fDSS//L4SKknQYOMytqoGi2pUmAz+7+x7sZrcUld0IFiNbbp/IfqCVuN7l8zurB9x970kkbvlNW0
uhRf5Rno9hxKZXq00OO2jLOMYUWYIlXs6+1qO8AZ3qK8qzAkz02k5Q30n6bRUI9cNcPuSFDGvOf2
D3T2+6FaI4tZwk6UW6EI44YdcpQSjwJ++snkwmisSklzxovDUpg4QGPGF+xJlUIkj7Fpr4Hm471L
vPfrmlRezcu08DtXv8ImHFpCFYJr5KEVuxYFUwxUJ9ONcNWnEsZ15V8YAZEKbkuOFb8kRQ0FDhQm
H7DyG13z39UlsAcwulwMD5YVmQTjmf6efl2IQgqEfdcMWb++jxliQOzBPBP9kuCAuUFHJDRJ4/s7
WU9F5jtZXVv/6tlzK16DyTh0kq5HZLxd/8TbeEwLf0B/ul019x+jv6REH3F9av82EJCv+CFlyp9y
76D8gAJ3ip9p8aow21AjFodxUINE3Md3/ujBxgnoPXUoFp2kamj4sKvzZPZGrIyO8NtHqfVPDVAy
GCLtApUzo8KdLQVtFy2t18YduWYXZP9zR3Mo+eG/ae37pxXJyT/NRXXx3fQinKGZYlGl7UUsR2fz
ZjeLObqry2pFebiCO0yA1KEAcknfL4SCLLDDz9zMUkk27hqw0W7RSdYM6716d2dSqoSDPYLTgaBy
/sPS4qv55tXJjO5Bi8vB2MvHXMayzGMjsActDHjouXeHDgKdm82WOFq020ApF85AhP7Mr1+a49DW
aGLlYf8C8UoENo7DKbT7myfqc2NeQ5PcVFG6D7ZHEA1gG7sgcskECfRBZU0WRPrZmeF3WJvIUviR
7aiUDN3CYA/XroTAzpDU+GipFPp4cjmHSlWcoCUdDky4XIN1MStut6I6Yt7CrNIYSHcOAhbHucI9
CNDyfMkyLcfBGPPG+xYWAdkqNPrCxXTOrO/zxtb5lxLQpLw0XUYIKm9ZhcrjuH30ZQxStnB6KYMl
XTzVgJuIv6+U0Uki6iCGWabpFCtJKZBY/ypJr82JWObzGswxeQ5QzeZSjBsyc1i+lWmmVp3dKkOe
0w7jCUmCz0vyfgUa94XAqlGMnz8xtpky6BjNTB5hRTkcM85QOYh0+VuAEpQ4VTaPf80c5P00nQsx
o8X6u1O9eAwXdLe2GlvBQLsKwaH5Z2D62G4LNCoyDWgrwtVreftjh4072/CW8KK/MzWSXoWYW/3w
mZl/M0cIfZKHjITghqNP3LngCMiRLPMkjQKSVJd5vUEzo5+P3BitiaUYEvI9F9j9ABpGfZQQRgve
S+OZ2a96YxNGwBHwmapvuj9fzMsXZddt9827BvxRIe81f6SfyzTa57o/7Gh9w7YnrURiKMXFPY2J
D061Cj760tpngO7U7KoWAKjxb1H81HBG2PceqOAl5P/q3GiGIwRqe5XRbGoPLlx67DSOAS8EYoV/
gYTuVOdtsyJ1GKKUMQWxewKyYbn0/UHAuhL9/Z7bVY7Fp0ZvepyfAsmZdMZkude0YvbC+0nLMcoU
8aOO9QchHy5w+m4eg+wkvm/Nw2BGsghgaNrDbbV1CDNdiBBZ56PC3uWlGpbBJzqUmz6OwLsNuQGw
r8WKwKR8dCzFg+alvGtrEfTZoOei+6W9QsAzlS8nH+TucW/dk34sSjaV1bTY5mIEEEWJ4OMht8st
NdlcfwAIzDvUHXSiTsgCUqzphPnVqIp/5ye9xHbbYtC/gW/geo7eiSjf0VaTn2SomaCuiGOrDu5j
e3jzc69bM70IKFqDuisgopgo7qxo2JF9ERU+zoNhRpNXpfxFwirJ7+sSDJ5WgactaNKjD2xgbxSp
RSeWAPVbcy9Yb2ICfRHgVZ9CyIPZvvX2ekiZnuA6xx5junqkPzGFCPQWfYKUsZNpHpnAohez4ewf
DVLbrNzHePnuW3/9tZm486ot23rBLfxphFTOSRGeZa6DkouVs594N17pJb71ZFPH+49enn4tm7We
aDm4G5wf1Eky7CDxCBZWQ8rUBGLls2ToQMtdw7V4KIrg8RDWuNu6anQHJju/nKC5hxiXRUKZIayr
oSxDQIBwdDJ+Thbca8xZgWoe1AokcPmMWmgXVgGrhuNZBzKi+onLf/dywa8CQy32ghdqz8Qz1gS8
sLpr4d1TT9PAT0JLNwPVCasrkydZox6hN4g1TMb9lmxau1DkVTnJSgnA5SieFBaV5Gx+C53fyc65
02Hvb6J302ZCdf8vOsm+/6aErqghO/nJSmid7cqgaWi0q1AZHa/KOorOLQQdRZ4kkdFcCuClNxrG
HS2IsR/5MRPA9h0HDJ67UVpbwn+y7WvXWrgTeiYLHgYNAzJ1tuffx4Iq5C9fCkZBnQuud98mm4sG
fVVFfEX/+LBqferRQLwVq9zuDAzTg5AAqL0jW4O2TEordKddk0CfSJjEx9obcNaCw/h4hoBBqTJQ
p26RErSM4irDLotL6ch6u+2OzFRXbYGWs4d7NFrc/31OAmUGGVufntf5kBsXBwYb0GQ1/0uLVcEU
e/qHPBWvlDZ6xitAx+pjR277fsCKk2GXMFPm3l016ygGnqB4CYUAV2H5Yv+yw4/HOsdMga8CDdbX
x62IXc+fN0wTGOAon84PiUVFT7Q1EwLyELsheIGoZH2IIXXVKVLbf89rNHGfTSNf/ccww7u08Sd+
lDJG/CIwMeB0Uegvd0Id9MQE5oW8dGXGXAA+8kI2U4G0bPxgGR0CG1LYO4MJaG1EdVtYsEiH7Phm
ybUFUtK/2CDeNvs6LtHi556/kw1UTawinJ2C8COi+u4afHcpHb1Tou9FI/vp/Z0m2DCrZXJHLB7z
kEfpz68/S0iCP9Wb3cEnluMMtenPQKWf0ITErt/eBYk3HWo/jtmlzvyXukxUMepyQdYxPqchMOmx
s1zrKJYqwclNPUIovLWZKr98G3TJc28Mkr3tUJ+ObE7rmivnbA7+nEBw1P3Aw8UhIwGKPpi4QcUF
qhzxq3U5grde0RDFTxGuLwL3aYfkUmuQ5cfUDHYr9htFovBDX1nf0PWQRuaBKwj3HxPftYzn3c8p
uWeBRflaPTlw52KDmiWvF8sCbm3mRT1/XZW5E5o/aiQdHZOMR/omzliVTYMmBKUzJbXX6ZdHO4oH
gK8Xk7IDJhN22oEccoKJ3s086gIU+PsgYHvRVVmdGLBF0cAP9Rw3yr+glpgNznm6AQyI0sXoL3nu
wCUoWmU29ubCLwqe8VFLkjyMcYaCWh1nj4YrVtlYjXyzTtmNcdVa51eIUgxqzujxDfft9MHpdxWb
7qDOgsDiukI6qH39PqEQug7PWlymKiQDqK7QLhnd3wEAVoKQsgOF8+TP8bel7RHgOrLZ1Nm3mTi/
Gyz48hMOUy9RlsGuR5+VnAWujW5CZWHt3t+SLatnt/qbDBgH3dpgR7uXlUJlfy4kxEqki5W8BfLO
1rLgqzLvtVDjc48GI0tNDlV1fNRhiVzDvdLjlF0LEPn2zVJFO52lVlgjCigmp1RQ5y0Rei1ezZiy
tSCC//GIexKbD9Bpk2xmVqapOCX1iiBHgupu9Uo7PJYfpCFS0M/4la9y5yXhBL2zD3cqUjwr9G4G
BceNWwnsZOv1GGnYFVhcWMdM3Ms11wFqn3MPyaStd3C8usd0I93pEdfj8dSHjbbLHYvPlzkI1Wc3
PufnmFrkxIxLWdryETQVxWVla4O5KrKWZIj7rjkl2Gw61eRDN6C3xNv0lytIEB4RpwLf68aCSni+
Vw12KKQgctMeHvyfo8/IduHHQ3jtKAJ/95B0X2w6fM0SvLz1nbzYTNp2PuBgg1xS4LR3BW0ruw0h
DJWZFzxALmldRmWH+T5gFoBPDSHBpDVImlZhT6r3i4rlTgVSpxnaMRBIet7scx/p4DlVhQGSuM+6
qQMc2QFvCN+0y67bS2BrGY+3dvLe1pfDNU9Xf5AXb59EmfGyEMgzg3JtRzMvcV33RIq+97k+htPe
iDHhAxx/qo+DziHb8lTAiNG+EN5lUXJDOHJvgnBeY9J/sv9qitrQFL9/1CU0tbODGscaeE0cumcN
6tKPp1YKO5U3hnHWxwS00yM12QgAls4l3ImeOyPcKNR+lWFN190AdkLZRsl3mxV+MzZf9r5Uh+uw
hF03/rWcYq0wRH77NPOgsfdAuoc8WbH8Csz39LuCrshCoz90wxXUpVO9seAI4O3NSS8NPLuZHj8l
cc7chLfsh/Z1tYwsasrIlT2Rh9suFHu0sQikKBpHNoP4mEYrw99zUiHPuNQCWuNCTus9g10/VcWI
VQLeU8Qbp6ELHZUMDh88d63VyyKBwIPU3A67lQcEnSGe6f5351AraXT2TIFMrfG/6RuA3Y0bySGd
s8O4MQQR/kle3J2GhrqABPkmM77YauYJuuiRKznw1XX51VRbrls4zeXgmZiTXXxHaUIsf0Vp3i7z
obF6qz7v6QrzyvLTdLRzDvdwrvMx5rNdEl4rsaz2BQBFPckFovU7KwKmuL1G2rzkucA/Z0AnAvIf
5Qzsqp1O6B/8JqIvbJFMl8WIUv5A8t3RVdIB+bLBq9eYlAWw4LnaOtoccgPZlZOdrAjvgtcpwb87
dGW8n3N6jmqZKgUXPsyTx3oqPBZz0ic2B/+dqK2Ye+Uj99wX7UPWFxamPMSblaABugfAFEjYVh6g
zFD9vOlK6BthLvPjEzPXfGdXsJGNzHWkWfYzSGW+MvGy2AK3gfwMTz982n7MgThu088Qx7kr/s1+
TqySkPRuPEAB7A7v2d703CGSDR/+qqRz15EvsKb2goh4aDW91J7BvEVLBPtVP1bcf+eMyAHO/6Zb
TUVK6kcYZVkq3tz4vJoHE3L0dhh3e03O2d+m2aAJAIzq4HWAnQOqTCuC25sf/bK/dFD4E3TKXyEQ
2nsLskXgA8ptRISivWzmlbV/UDscNXSksT3VKxD8AblDpxYUvlo+CrOO+yAlZb0s86DkyAhLlote
sDgiVrPmcD0CehvrURCZ4fP5p7a2ROnavafhRaY8Hb0UuNcxt+gFeVrijArhVunL2Dj5VsLgoEXm
+3Rgs8IiWlw1Pdjc9HpEmVwXKFVZ0J4+bfnBXqF2GOcZ3CC6sOcfujM2D/Qo91crbpFC0WDjQVy8
h6d/DplzPhqqGrTJsUtnPxlvrluGwj8f9qJwpDhWSjvaKCluukgWsgtvwz2pFyUXbjcD1guG/hc+
8V6HJ/ziLMc9rcphgIAwfjS27LLfHXWDF2+nE20PHlDdb0OJ4O24sGqXB1YpfkvCRY77KUCIgqhy
Ba78iuludUlxxcnJU0L3eLj0UIwgB1ewnVA1lL1+5eESIZkdpBkjOJPwtg1cljgaqr82kH0V+k/0
Pubbi1ltkv4piMV78Quacq/CStIF9mnVvPEcV+ICa1LFdy43IsG//o8OTFrsuRWmKunqGMWrLwNr
ChynhrJfMgW4stMqrP9mRXoNqNgxSUAUYJRWduTbgfv2HwVXu/ASjStbcAQ3c47rkllrUAPTZ16/
TgGIMPhFzpSoi5yxcivNA2wLlVCRtVx6hWCL6XtygTo1Ks3k6bhCwNu7stsu2lmJryRnAXcOKGX7
xl4XP7Fj/a42jze9rzFofhjI0mESRHA/LI0rWsm+tyxjjwg0VZoHlderihHd3rP7OF1LxqOQfbsv
ePxns5p6XUq7adNuOIOHNWHCDFtYctjDAPVfjl59nEQoPN+Y6kJLOtws5qW9c4pLKChRqEE8fZEZ
tryIFBe3OSgV4ap3G1EBhZYoXVvkAQCimvMuB+lQEa/yWVOj0cWKc9qQpVmYSaTQoiF1Cyafybd3
9B1nOMNqaESFOOXbd8/QgTd+MhRWxGz5YMUtp/RfkjtRO78fxgOqwoYYUZGimliAILvu9RRwUtfa
10gf7/FGOPBkhFBYYlEIJgVE9a47M+zauMGu7ZcZ3Sri2/s6S7BpFFuw+iXX0bcVEYGZHhB+hcrc
P3p7gTlhlfHNykE+diotuZCFXNBscPv62knil10NMzVZrdpB+OYN7Vn+viVoAcvUWgQGJehy+Iwg
m7AJ4SVSNfQo8x2djxXBmaUESzVyqMqkhs9FgiZtO51Q0pQRqhdZ3ur/5JyvG+wdmSTfHW7Tme98
ntV1bUteA3rGWXGRzVnVuWkFeFNl1ZP2duj/OLBoIK+uqndG9o962uW9ejIDMULS4EeKYVleLaSg
zBi0fKvYLJCSbH+BhYp/YR/ce1M8FMjrkd5EKuGz4XO6q/jVlbcREqP25s6V9j+OJDOer3WDrEeO
3CM8veGA5VVfqIo3Ncj8jyvm1j2/EiRVCWUaBQPIofW6taIumFxgtsO0dVmAUonvINOedddjLhhf
tVycfkvHaesUpvONfVlo1a4vZIl3WtmWhvGoO8BLqVWESpHw1GBWdJwd8+/UBdRLKbv7uimjJ3I/
jM9Zk6Q32gPWv5yrDqCclPl9ENWzb0ZznuYN38byYO/nrY4699byN83oYFa88qjZXduwSAwWt5JW
frZOzD02tt1+BVBcfuIvmFOJ1fbyE+Xi5HXCi5oE/CFc2UzZV5YSW6QTrw7JvaSLhZAdjtUEw8bt
Xjge9HN+TB5wJYGeigXgLZ72BFEU4kLYne6WeUz3Kob2O5a2cRkASW/p7N1RL2neT/czqvKDMeK8
Sn2JSnU2tshl518LyO236g/6qB4g3XHdAYbqXGL5uXzSHZQLjlNLYmpWtjj6l9veBPtl1YDN/hVi
t2+ki8aVViMZdMsJlNvMayDgNCJKVgkEP4zhOZgtL7Y1zEUpWttWWJYOwZzcAB9McgZ5GiYhQ38N
PcD7DvKMAava9VvhJmx91HBkwA5Cg5Y0T/DSJSj9tpsuPCipODGS3nPqSR8YYiNki4EaGucJKjdj
sZM0umMcRVFtl/OMn4O3PXLzBJt/36apBb+j1lQvnzCbvoJVKIuRoA3IuFl0OhHaApPYT/HJgtrc
w3ppIU3ZAxz/1see9SYFB2wXSi4vEHWoDoyZ2LtQJaouhmU5XnFVh4zw8oY3Vadi9FkUZU4EAKS6
FB0v21pG22Ynsn9Jj7yC2zn6CW4k8BZGrHghEs4wwGZG95Suo5Bqvlp2cE2547yNKq/dLcdx/MeT
8RhVXf4oTyDfArphbQtr7mnshxF4THvxrWpZmNFhuN2TsvnDJwaKetO1JJitzjMyLA/ffh5riNm0
hbHRd/dxpUzyr01LDMEdB0ar5iV0DeOA3p2nzZi/1R9m8yRK9kAmIOLJjBqZI81HmCh5BDv6XXV5
9xRf5+twHhNQm4aswNu4UozomzWWTn+dyaYIFsf4vShl3nAhhQRmfTUOsLESm4SsX0spwl0gGvY1
7DwIOnhOEmuaqYISjGBWNN3rk9b6gr+tNAA4INo4eQi8eg4E+UCaxdO+pZLN+RbmgXzKsQwJnvFo
kOv9MG92DMc50XufAL/Fv63TY4+NGCy+vBwa1Hq1SmWfWwdGN+V1xWettUQtU//my2h9z0KkaPbv
elrDB5HFDBUASY1ULgQZoNkHP2Dn2LANoCde8p2Cort9/r6YzWkAWyjcp0TG2bn2kMlwCVD/D3Cu
UKAYEdS/FRwa5v2ct9HNEUN3hAs2ySSOSyoZ0cQf/sSxjW2N+jMUqLZDio7vZeN/XjJMGrEVx4rw
jIdsy5IcKw4ZA4IJD8TeOfv3SlokJf5Lroo0hiZHEa5wPPFlZvwTbqgrmF4uQVQyc8n6/CTpft9W
Tl/qg0tKxZ/BqB223oBWoikY/qIIkdYf01+l7jMUTqy1K8CuW1tsx86CbuN9Uw7iJDJ0eYdlJIsg
flE/EHEmD0ZSnr8C09YngpLyLsLq4dQTWdO6YlkoTk6PIcUyCkvyx9qG0iALvBJkSsil8zcBcVrU
EnLtwnQJbtgN4nmEVwMIrzaHWMs6gxKgdYh+IHCZ9qGdDJL4mj/aLmaXjgFyvq5r0zvxDOmD/cIn
+32G7lPaOjHxIxFpx3vjrgQLqzmY0GsUP/geYRVbsq022+v//VUsnq89fML3ghwJLzTGbsQ/QsqM
7EVBzRQYuEisBVXZgLFT2gC1mTcbqVnSNwIQLNT2knQWPXBUHH2j9claNuR3LvRlFe8VloTD3xvX
gExUYbl7ioVzPB/7dUvTpPNREKI7JOa2rCn+WL3aK3TA4G44DvRUIOTi2JamtyncJx/RlFr6d7e/
JQ+RY6DbROcxMSkRXOuiblqz51+Nic31gXXmEPxFN8rOsuSqZaD8Ci7u5fgk+D5E1p/DK0Yx2Awi
3bLi4PIpFjbIkXTiZAMBucIOOwNgJid03A8demBeuD70SBFy0fBRXh4f35mTorteoHvnx/NSFSBd
3p+1fL+yoEhR5D3LZK0t20FCN9+uYl90MOn7nk8yt34L8iBpxyIjF/EvElyUVJTc9hrM1e8DQtfC
eBk+WKvGSTIeQCTrV8mskIFbyscXjqy2wL9fcbxospafr1TIrZycyaZtgQPLC3JnJpMQfZRqt49e
T99oq5t1n9r+xvqUWykqt1kJctoazWVP5JCTJV/CfYJIDTXM22qqJIX+qNj8evV6oBtpQOeWR10g
FCXddmSbGBMP+Dn0vDF025vsHh1o9PPKfm3pwTIF/MJbkV4SMvRa6hSCoMqUjykts2QkqUU2Z3cH
Tab+9LFxZJmK1mkZxyFxnUwn5K1IzGEh4b4m3G1CCBSNWYG5ONFpgoOyU0GVrOTwUG7GKJOAKpx6
2jxuJ7ogymkX570Znw/DqNhv3D0EDtU18tz8mYQctX74hrL5mlseAssLLPgiCJYGMk0FiGBZDfJa
Yr0IK73q/pDvadVqCKYUmTrYVaVyt29Tv+X7oQSqtVxKmakspStX5o0DKuoConIJIeCdAk1WWY0F
n+UURT8fnmqJquDMt+7dFpZzWOxthr3W9RWqybj6dp193N7kSNi7iBtkDkb7zdIvXTpbPa7UpeK3
k7LJlV2Rh9LmlQAlXJ4riCv4qc8Jbm0MxeJnggFWUOPmjI0ud6oc/KKvf/ESDmCNOPDvwb/3EmvD
skxmxZOdWdPr13rJWbIa5AydiWx0R1k06fWnGMKyu2fDx9xwaiyHa//2cDbmVSJLBcdzXWX+bh2+
kXN4Uj0McOFam4bqTg6WWXqOTBX+ye7lfRFKR0bnIUTYudlp9TbwNFnCUafLzh19rdHlCLlwlnUK
h5daMTIZLFwK/oWRhJTz3BLnWJbFWy5fyo+mSIYtNO+XYd6bL9xTgvxiaSfjLV2gkMit0Z1iSVCe
dBhuJepgpg7MNUIczYCHfrcJNkS6JByszOZJ68j/HRhY0ogb8cWZ1hLTFa/uDcJyk9vJEEJ1vUDA
4HJ7l0GEih+uhuUi/uQ0CGMfOTovvQPrzDvnekjmBB6XnX1IqHnbyC4L76PSq/PT3l7ZtPybZmZt
VvrnfkkT4sX4eNI3kXUjWgEzI8e/8OGlA0pgeMNsw7PexSFD2SZTj2TeMyyGyXHjzU9xvm0Lgb9K
3Os7Xbl2/4MkHxj010NuwnzmOJ/hoFYnwY4o7r3ORzELA8X+OeycuFxTmV4RkKE6TOCoEh6tlyG3
/0bKMKYc/pC6quvFFeCwof6BUho9n42klToSWBgcO80wBMA+GH1aSOzUlROM9Wjuvins528quklK
a5jTeG+3DHUO701Sesci5f1I8cwYBRW01yJn9ewf+bXNIf9RfZJVrpOKdFJCk5MR25hBWpMiRjQn
D1adzCdDyfeAUfPowGVdKq4JlwXfsoxihp2eYFttrDv5ZsCiODhKb4e42+t+uhOs540zAKyCpIdU
uAfMlzhXbzUSCCQPwcEP8ALDr5OfzLWq3KkH2wV3y1aJ8BVdkqEHj27Sxb3li5p/e4Rhp2UGzOxS
w1UNmkQdLdO2wMT9bL8SW+5ria925u5lORNk4nS5i7YEFI/EdJBznaz9ISBzAkzoG9m/druW3mVc
D9elHOyeklmLVs+ytnwGp+7aeW7xEEmitm8D7+02fbIF8aCHH+hwRYevqC1pzegF6VcRGb6hziG+
ND3xG/NDMmG0VOOGs2ftlezqY1l1Od6AUjTt4dE95uVxKIIr2Sn2Mhs/0zAXPn60idh0Jo8w0q7+
I46MQCWj1EccQSeFPi8Ud+lVSaiu6TvKtZol5RVH0yQryu7cqW+ih2VMhHceYg4GQg+xiJJIPh1y
HZJa234KMFf2GAAjZQIMLs26n9aZtiZuuAMLkon0XHX7ywvPUzZ2q8SbDMmREsuFMdxdhFxeQQua
wLnbRnoOnYIVN1qAGKvJIeqbg76d4q0ksZ5ii5plvsL5Jmsjhk0ctq3BhnbsYHlP75MzUfjuBCMI
67rKjb1yOfMF/kntR6vMgY5wgRbZqRcJKql06Q4SyQDayp2ZzbGy2gYZFJp8fxqjNsYiRpADrMTb
lAYTVuL54J2pkzOBwKO4JgK0/uhwE+B4NKwcf7eit1PmOHYRxlu5aNBuPHaIj3L24nnmK01AeQSr
mvKj1gX9q97NST2A3gNJKKsOKkO0GoJdXJrKoMpSZqeEIIzUttl6ArEwk/Xv/UgLthjsgnkt2I2P
0T+3oBSU6q4t6KIa55t0/juvSFdLzksoHc+f3FAltX1/Pm+yeEvGsd79lzgs+0kchwjUmLaUOrJ9
nNt0FWV7vvTUlUxk423zkOlj2iElJCOWqz6V7wKXN5AsBBcI6s/lyy3qLA62d1fpN7dbBNoYnn+h
Xrf7hOXn2eVtbGCWjpQoReVT1ivrcrJqctjZR0sS0YtBREGEFcXTMlJLXYpiSW7EF2O5jBGSCuTb
Z5Lxv0neDntr119wgkUWc700drWyDMIr09IVzpozhO1K+e+wCjhxgfwQQlZVy0Guh5hlRevVdrL2
E3lxfRJZ82toSV0ilEkzKkNEzwhRW8Uybn3YROTO40KFy7JD/53TTuBiyECnlHCQ1GQnVApNDjkB
/ByF1pja5Nd3X60ARcjoIlovyUvcQqApUUL2cczdgMhp+Pkq9vFFNCN9/40DO6ALsEGI+OkqY2bU
w4NrYCHoGJ4cULncz3rdOlt7qjimPavlpFt42LCszySjJhXjTjKTr7E2RVCWIDcGWAcAglmbN38J
AZ9Cjz97cy2Y3WA2a9RQCBC86f2aupY86VY6bXP+RpMHi4GQNvjn2y/WakAcyCuP/fcdYzgDP3Av
v//KhUIt1IyhVIlYEEjpDoRfL4kkPvsRkwwVKHoR3VPTYivPktRo3QbRT+EqzFN8nCuiorY//2id
kDaCQk8ikmJtLBGqCGL4YgrD6+5FNTkdCCoToznNSbYhqhYRgPHv1x4mEcmOP6Cb7Xp360vznsGk
/5bVhYNhNeWwaJdAFV9jILlkkermR6wQxQgPVAZjqNDgSIGBTBd89ck4vX/IOW7paH5+MC/pRjuW
AcybxTd5Gyl7nqmLLriMb5JkT0+OC2kVBikmK3Uyu3z5TkbIq6i69B4vhQkoiUfvqWofywVOvy16
pKseAA0kVWxLgXiWzhyfISS+a/64c237D3Q4dE+QmWdAxokWkbo1Jy1fS4SfLKd1SRNXy/ZlE5G8
eur5wVoY8nNilaRxjDxlyHEHtdZjjgpLQesFQmdu48AukOSUXEYRzovbfhixg/OJrSZ5eCKeEjUD
yjw0JBIGrMZPs/wU9smM5nFa319W8t6HpC8jeau4wxF4/se6NuGd9UZ+x/8cKVcrpa8P7Cg0j2c2
nEqkwTvOrFAf+RjCbi9o6JVUjketfxFikXhDwT9Mx0nleA0BYbCXrsiT1ZaIbmNTsDDPRZrXqhRC
3s4rkQI0q8NYMNfuvB/8Hyj1RR4wl6RfMJK+93lXMm4O82uZJGINBheS/o8A1kydEtvArSrJoRbz
YQPfAhdWx29D3XcumwJncKv7WbR68V2kgPfqosbiiHXQGfEFLtUf5rfEZJz0t1psGthrGHtMfBie
rZaJszDm10/7ae/Rp4KZcnqBC3cufMysYzb0gVpwZQbxhRwjFEgYeWpgrPkoGCq9KUHIfnjgdo6g
y721ZqRZIpYIkEZCbAciCdF0eN0vl3e7TLaBrOZYuEoyLftyoVq8rqqT2sC5ieV9D5j5OlTH6ICH
C4qfxVBn47sY6oQF33UmKjfnRoOC64mLst5PuQ3gmgnXTtL5PTMc1+8KspebMqNG0PqXKmn0OjQX
D/F4SW4Lu5jRm8xFIzDcBHhO4aA04tDeDAxVyTL5CSauFeRrNJ53izeh32jSFSH8e2IiL+/0dxK6
h3T4jogTs0gbmc9Q5QoqdUWHPwAUlnRVvysYIMwTFHqMgMsyQNLA27GPI9o1XIFRDTskId0NKAlV
noL5IJZ5uCtwg3bDMH5eVhST1hEVoytoaBfdZvIw+M3iJs2f1GAR+LV0C4v+fd+9v3Zw0lSMQXIE
QSuXKjAfh+s0Wpg1d0qqIGp7CNO3RdFuDtU7uivxzhy1IbNCmun9+86KINAqdrB2K9gZ9YmT3iKa
3hsfWOXVgqpfJpcavs7swmh/YsBWQ7m5OGNe8G/TC9Nh6WKQilvQb3PB6lQpg50Yt+/z2wE96dLN
ECKcFer8whHwXMNraRHC5yYh7o/Nup6eWRpscp1PY1+xjn4hi0iw25UTY1P8Rc11AlO2JzmJfc9/
KaS9F0sgJftAj6sshDx4szuRE7srM3Cp8Wt8GKaQYoLU+Eq1XRzJl58pO5a1sUSzJMkQvuR5wboN
Zm7dfR5VYdXxP8C+wTxU89AKjno8g1tmRHzo6ua43RafLIV1nWYM812OsrQCq0ouIEV8/HRC7ciy
C7VIxln0PC9hxNAbGeVJ8kPVFq4dM4NDtLtfVH2PrOcgiIju2dZMY1KWrwDqxyfxKkDVsfRK/45U
FaVXQoERt87QJUS1smhvc3bfjRkhM0oKlpGyRRbAYtWf8ns62T9bP7kjdBcubSzNRrRcyZ2fJUnH
leXGH0oErUk6Z9cD3M2rRGsI0xZ3/yGdq9yWQ7HQubUpEa+CZC+9zMt+6g1zaeCX/oTft4yE8WKQ
z6TIEyJw9KfIQ4NCI9N9A7pSJFDg4qZHLSvZEy/iPSsJw13lCkgRIak/W/rbgVphCKCqFkn6cQfp
Uo7MZIOdTunVRKQUB9tlgYuWGUwIMU5PIboj3RxgdVg//K6I3FWN/cT/BjRSHm+fx0+aHVtnRi+Z
WA325DOaTqK3MjmLEULAMZMgrRMFpemd+9IDc96mr2Aosb6pfUPhHJd9+U+OdXckPHFFKxBIBvGV
s5qlZ3s6OjU73MFFLwD7JZcfZDHjdqqEnMMQP3YASzggfuD+1T4ShaenFnPi5r1ixajFP7+95dJB
w1Iz2zshDS5nH024jhdU/xlr15dcw3b0P7jIil/eugxMSrl0t8RitZ+PQvBo5pqxYZ81eudcV7EZ
NWfmTa9hxv+p96NfAvy44JP1cxaQcJDPDagGIFx3gGqITNT14LOvGdDeBeOInrsnYznO9+a4rv7f
w8YGsDFCDhpFKb2U9jfh3vtRSWL1M9sim1O+z6H5rkH8eMPOU79xxSQE09el+oYIOsULiuE/1HJT
2CYF0WkfxLP2V2oUpRmEbsU9mbnS5GY9zQluM/O33LudFsjgPuigKgK0CKUTXO7QDZ/LUKmwMVcK
A0WpW7zSvXYc1RPgpWwp/3V3boS4qEjsG90WcHXD23BRkYBueySZiUCIM5xrrohM8EeeDu/8d2E0
9eEEBykKP7QIVUvWqz1yxYwyFYPTJw/C4iv6Ctk5n0lcBY50qYhK9aolkDlP1hBrtQ+kU0AjB/Vk
tq5TGoxJcnhIvS41rdT5Q/1/Zwd8LakUMNS0pe2TLepaTYwBpy5Agn0U6VclhY/ag3Sk1N9zUnm6
qvuF2jazqosi7ltAMDobHRDZOu/dYjAn5n5PoAI411eN64TebnLdqPk00YLkXdE3IVMP76wcgdvw
64e7QJ5FaCdmOA/K4W2VNKYiygS47ipmJB55rQM+cMTY2wiLittzw59x2gF7gjRyiucuT8m3ouaG
cUdTp/NoAiMBulTTiNvABsdVLubntO7iFZY85yL5hwooDboxUbXC93/OCNtflqtCi2Di4+JRBel3
jhJY7IR1dpbMpDtI7mLgHFdPKcYI+dMG4sUF5rtUcpSyoOQAUMFXUHl/gh9JYFYxhq4M8CO1cDvD
wmttc+DEV/1Jg86p1wM3I89JYowb/7M/xhIkhhwXGQd4yg8jds4F6OO6D6vWfY2hwY4ctN7jkEBg
DynXGA/Lz3febx6v8wjofyvMA/xk6NM6hRk6FEHumg==
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
