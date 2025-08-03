module DSP48A1(
    A, B, D, C, CLK, CARRYIN, OPMODE, BCIN,
    RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE,
    CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE,
    PCIN, BCOUT, PCOUT, P, M, CARRYOUT, CARRYOUTF
);

    parameter A0REG = 0;
    parameter A1REG = 1;
    parameter B0REG = 0;
    parameter B1REG = 1;
    parameter CREG = 1;
    parameter DREG = 1;
    parameter MREG = 1;
    parameter PREG = 1;
    parameter CARRYINREG = 1;
    parameter CARRYOUTREG = 1;
    parameter OPMODEREG = 1;
    parameter CARRYINSEL = "OPMODE5";
    parameter B_INPUT = "DIRECT";
    parameter RSTTYPE = "SYNC";

    input [17:0] A, B, D, BCIN;
    input [47:0] C, PCIN;
    input [7:0] OPMODE;
    input CLK, CARRYIN, RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE;
    input CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE;
    output [17:0] BCOUT;
    output [17:0] PCOUT;
    output [47:0] P;
    output [35:0] M;
    output CARRYOUT, CARRYOUTF;

    wire [17:0] d_reg_out, a0_reg_out, b0_reg_out, b1_reg_out, a1_reg_out;
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

    // break combinational loop for a problem with PCOUT output
    reg [17:0] pcout_feedback_reg;
    always @(posedge CLK) begin
        if (RSTP) 
            pcout_feedback_reg <= 0;
        else if (CEP) 
            pcout_feedback_reg <= p_reg_out[17:0];
    end

    Reg_Mux #(.RST_TYPE(RSTTYPE), .size(18)) D_reg (
        .rst(RSTD), .clk(CLK), .sel(1'b1), .enable(CED),
        .in(D), .out(d_reg_out)
    );

    Reg_Mux #(.RST_TYPE(RSTTYPE), .size(18)) A0_reg (
        .rst(RSTA), .clk(CLK), .sel(1'b1), .enable(CEA),
        .in(A), .out(a0_reg_out)
    );

    Reg_Mux #(.RST_TYPE(RSTTYPE), .size(18)) A1_reg (
        .rst(RSTA), .clk(CLK), .sel(1'b1), .enable(CEA),
        .in(a0_reg_out), .out(a1_reg_out)
    );

    assign b_mux_out = (B_INPUT == "DIRECT") ? B : (B_INPUT == "CASCADE") ? BCIN : 18'b0;

    Reg_Mux #(.RST_TYPE(RSTTYPE), .size(18)) B0_reg (
        .rst(RSTB), .clk(CLK), .sel(1'b1), .enable(CEB),
        .in(b_mux_out), .out(b0_reg_out)
    );

    Reg_Mux #(.RST_TYPE(RSTTYPE), .size(8)) OPMODE_reg (
        .rst(RSTOPMODE), .clk(CLK), .sel(1'b1), .enable(CEOPMODE),
        .in(OPMODE), .out(OPMODE_reg_out)
    );

    assign preadder_out = (OPMODE_reg_out[6]) ? (d_reg_out - b0_reg_out) : (d_reg_out + b0_reg_out);

    Reg_Mux #(.RST_TYPE(RSTTYPE), .size(18)) B1_reg (
        .rst(RSTB), .clk(CLK), .sel(1'b1), .enable(CEB),
        .in((OPMODE_reg_out[4]) ? preadder_out : b0_reg_out),
        .out(b1_reg_out)
    );

    assign multiplier_out = a1_reg_out * b1_reg_out;

    Reg_Mux #(.RST_TYPE(RSTTYPE), .size(36)) M_reg (
        .rst(RSTM), .clk(CLK), .sel(1'b1), .enable(CEM),
        .in(multiplier_out), .out(m_reg_out)
    );

    Reg_Mux #(.RST_TYPE(RSTTYPE), .size(48)) C_reg (
        .rst(RSTC), .clk(CLK), .sel(1'b1), .enable(CEC),
        .in(C), .out(c_reg_out)
    );

    assign postadder_carryin = (CARRYINSEL == "OPMODE5") ? OPMODE_reg_out[5] :
                            (CARRYINSEL == "CARRYIN") ? CARRYIN : 1'b0;

    Reg_Mux #(.RST_TYPE(RSTTYPE), .size(1)) CarryIn_reg (
        .rst(RSTCARRYIN), .clk(CLK), .sel(1'b1), .enable(CECARRYIN),
        .in(postadder_carryin), .out(carryin_reg_out)
    );

    assign x_mux_out = (OPMODE_reg_out[1:0] == 2'b00) ? 48'd0 :
                    (OPMODE_reg_out[1:0] == 2'b01) ? {12'd0, m_reg_out} :
                    (OPMODE_reg_out[1:0] == 2'b10) ? {30'd0, pcout_feedback_reg} : // Use registered feedback
                    {d_reg_out[11:0], a1_reg_out, b1_reg_out};

    assign z_mux_out = (OPMODE_reg_out[3:2] == 2'b00) ? 48'd0 :
                    (OPMODE_reg_out[3:2] == 2'b01) ? PCIN :
                    (OPMODE_reg_out[3:2] == 2'b10) ? P :
                    c_reg_out;

    assign {postadder_carryout, postadder_out} = (OPMODE_reg_out[7]) ?
                                              (z_mux_out - (x_mux_out + carryin_reg_out)) :
                                              (z_mux_out + x_mux_out + carryin_reg_out);

    Reg_Mux #(.RST_TYPE(RSTTYPE), .size(1)) CarryOut_reg (
        .rst(RSTCARRYIN), .clk(CLK), .sel(1'b1), .enable(CECARRYIN),
        .in(postadder_carryout), .out(carryout_reg_out)
    );

    Reg_Mux #(.RST_TYPE(RSTTYPE), .size(48)) P_reg (
        .rst(RSTP), .clk(CLK), .sel(1'b1), .enable(CEP),
        .in(postadder_out), .out(p_reg_out)
    );

    assign BCOUT = b1_reg_out;
    assign PCOUT = p_reg_out[17:0];
    assign P = p_reg_out;
    assign M = m_reg_out;
    assign CARRYOUT = carryout_reg_out;
    assign CARRYOUTF = CARRYOUT;

endmodule