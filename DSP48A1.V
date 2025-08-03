module DSP48A1(A,B,D,C,clk,carryIn,OPMODE,Bcin,RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCarryIn,RST_OPMODE,CEA,CEB,CEM,CEP,CEC,CED,CECarryIn,CE_OPMODE,PCIN,Bcout,Pcout,P,M,CarryOut,CarryOutF);

parameter A0REG = 0;
parameter A1REG = 1;
parameter B0REG = 0;
parameter B1REG = 1;
parameter CREG = 1;
parameter DREG = 1;
parameter MREG = 1;
parameter PREG = 1;
parameter CarryInReg = 1;
parameter CarryOutReg = 1;
parameter OPMODE_Reg = 1;
parameter CarryInSel = "OPMODE5";
parameter B_input = "DIRECT";
parameter RSTTYPE = "SYNC";

input [17:0] A,B,D;
input [47:0] C,PCIN;
input clk,carryIn,Bcin,RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCarryIn,RST_OPMODE,CEA,CEB,CEM,CEP,CEC,CED,CECarryIn,CE_OPMODE;
output [17:0] Bcout,Pcout;
output [47:0] P;
output [35:0] M;
output CarryOut,CarryOutF;

wire [17:0] d_reg_out, a0_reg_out, b0_reg_out, b1_reg_out,a1_reg_out;
wire [47:0] c_reg_out, p_reg_out;
wire [35:0] m_reg_out;
wire carryin_reg_out, carryout_reg_out;

wire [17:0] preadder_out;
wire [17:0] b_mux_out;
wire [35:0] multiplier_out;
wire [47:0] x_mux_out, z_mux_out;
wire [47:0] postadder_out;
wire postadder_carryin, postadder_carryout;

//D register
Reg_Mux #(.RST_TYPE(RSTTYPE), .size(18)) D_reg (
    .rst(RSTA), .clk(clk), .sel(1'b1), .enable(CEA),
    .in(D), .out(d_reg_out)
);
//A0 register
Reg_Mux #(.RST_TYPE(RSTTYPE), .size(18)) A0_reg (
    .rst(RSTA), .clk(clk), .sel(1'b1), .enable(CEA),
    .in(A), .out(a0_reg_out)
); 


