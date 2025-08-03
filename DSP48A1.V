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
input [7:0] OPMODE;
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
wire [7:0] OPMODE_reg_out;

//D register
Reg_Mux #(.RST_TYPE(RSTTYPE), .size(18)) D_reg (
    .rst(RSTD), .clk(clk), .sel(1'b1), .enable(CEA),
    .in(D), .out(d_reg_out)
);
//A0 register
Reg_Mux #(.RST_TYPE(RSTTYPE), .size(18)) A0_reg (
    .rst(RSTA), .clk(clk), .sel(1'b1), .enable(CEA),
    .in(A), .out(a0_reg_out)
); 

//A1 register
Reg_Mux #(.RST_TYPE(RSTTYPE), .size(18)) A1_reg (
    .rst(RSTA), .clk(clk), .sel(1'b1), .enable(CEA),
    .in(a0_reg_out), .out(a1_reg_out)
);

//B MUX selection based on B_input
assign b_mux_out = (B_input == "DIRECT") ? B : (B_input == "CASCADE") ? Bcin : 18'b0;

//B0 register
Reg_Mux #(.RST_TYPE(RSTTYPE), .size(18)) B0_reg (
    .rst(RSTB), .clk(clk), .sel(1'b1), .enable(CEB),
    .in(b_mux_out), .out(b0_reg_out)
);

// OPMODE register
Reg_Mux #(.RST_TYPE(RSTTYPE), .size(8)) OPMODE_reg (
    .rst(RST_OPMODE), .clk(clk), .sel(1'b1), .enable(CE_OPMODE),
    .in(OPMODE), .out(OPMODE_reg_out)
);

// Pre-adder 
assign preadder_out = (OPMODE_reg_out[6]) ? (d_reg_out - b0_reg_out) : (d_reg_out + b0_reg_out);

// B1 register
Reg_Mux #(.RST_TYPE(RSTTYPE), .size(18)) B1_reg (
    .rst(RSTB), .clk(clk), .sel(1'b1), .enable(CEB),
    .in((OPMODE_reg_out[4]) ? preadder_out : b0_reg_out),
    .out(b1_reg_out)
);

// Multiplier
assign multiplier_out = a1_reg_out * b1_reg_out;

// M register
Reg_Mux #(.RST_TYPE(RSTTYPE), .size(36)) M_reg (
    .rst(RSTM), .clk(clk), .sel(1'b1), .enable(CEM),
    .in(multiplier_out), .out(m_reg_out)
);

// C register
Reg_Mux #(.RST_TYPE(RSTTYPE), .size(48)) C_reg (
    .rst(RSTC), .clk(clk), .sel(1'b1), .enable(CEC),
    .in(C), .out(c_reg_out)
);

// CarryIn logic
assign postadder_carryin = (CarryInSel == "OPMODE5") ? OPMODE_reg_out[5] :
                           (CarryInSel == "CARRYIN") ? carryIn : 1'b0;

// CarryIn register
Reg_Mux #(.RST_TYPE(RSTTYPE), .size(1)) CarryIn_reg (
    .rst(RSTCarryIn), .clk(clk), .sel(1'b1), .enable(CECarryIn),
    .in(postadder_carryin), .out(carryin_reg_out)
);

// X Mux logic
assign x_mux_out = (OPMODE_reg_out[1:0] == 2'b00) ? 48'd0 :
                   (OPMODE_reg_out[1:0] == 2'b01) ? {12'd0, m_reg_out} :
                   (OPMODE_reg_out[1:0] == 2'b10) ? Pcout :
                   {d_reg_out[11:0], a1_reg_out, b1_reg_out}; 

// Z Mux logic
assign z_mux_out = (OPMODE_reg_out[3:2] == 2'b00) ? 48'd0 :
                   (OPMODE_reg_out[3:2] == 2'b01) ? PCIN :
                   (OPMODE_reg_out[3:2] == 2'b10) ? P :
                   c_reg_out;

// Post-adder
assign {postadder_carryout, postadder_out} = (OPMODE_reg_out[7]) ? 
                                              (z_mux_out - (x_mux_out + carryin_reg_out)) :
                                              (z_mux_out + x_mux_out + carryin_reg_out);

// CarryOut register
Reg_Mux #(.RST_TYPE(RSTTYPE), .size(1)) CarryOut_reg (
    .rst(RSTCarryIn), .clk(clk), .sel(1'b1), .enable(CECarryIn),
    .in(postadder_carryout), .out(carryout_reg_out)
);

// P register
Reg_Mux #(.RST_TYPE(RSTTYPE), .size(48)) P_reg (
    .rst(RSTP), .clk(clk), .sel(1'b1), .enable(CEP),
    .in(postadder_out), .out(p_reg_out)
);

// Output
assign Bcout = b1_reg_out;
assign Pcout = p_reg_out[17:0];
assign P = p_reg_out;
assign M = m_reg_out;
assign CarryOut = carryout_reg_out;
assign CarryOutF = CarryOut;

endmodule



