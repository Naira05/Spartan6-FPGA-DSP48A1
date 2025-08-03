module DSP48A1_tb;

    reg [17:0] A, B, D;
    reg [47:0] C, PCIN;
    reg clk;
    reg carryIn;
    reg [7:0] OPMODE;
    reg RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCarryIn, RST_OPMODE;
    reg CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CE_OPMODE;

    wire [17:0] Bcout, Pcout;
    wire [47:0] P;
    wire [35:0] M;
    wire CarryOut, CarryOutF;

    // DUT Instantiation
    DSP48A1 DUT (
        .A(A), .B(B), .D(D), .C(C), .clk(clk),
        .carryIn(carryIn), .OPMODE(OPMODE), .Bcin(B),
        .RSTA(RSTA), .RSTB(RSTB), .RSTM(RSTM), .RSTP(RSTP),
        .RSTC(RSTC), .RSTD(RSTD), .RSTCarryIn(RSTCarryIn),
        .RST_OPMODE(RST_OPMODE),
        .CEA(CEA), .CEB(CEB), .CEM(CEM), .CEP(CEP),
        .CEC(CEC), .CED(CED), .CECarryIn(CECARRYIN), .CE_OPMODE(CE_OPMODE),
        .PCIN(PCIN),
        .Bcout(Bcout), .Pcout(Pcout), .P(P), .M(M),
        .CarryOut(CarryOut), .CarryOutF(CarryOutF)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Initialization
        {RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCarryIn, RST_OPMODE} = 8'b1111_1111;
        {CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CE_OPMODE} = 8'b1111_1111;
        {A, B, D, C, carryIn, OPMODE, PCIN} = 0;

        repeat (2) @(negedge clk);
        {RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCarryIn, RST_OPMODE} = 8'b0000_0000;

        // Test Case 1
        A = 9;
        B = 4;
        C = 5;
        D = 1;
        OPMODE = 8'b00111101;
        carryIn = 1'b1;
        repeat (4) @(negedge clk);

        // Test Case 2
        A = 3;
        B = 8;
        C = 10;
        D = 20;
        OPMODE = 8'b11010111;
        PCIN = 48'h00f0000f0000;
        repeat (4) @(negedge clk);

        // Test Case 3
        A = 6;
        B = 1;
        C = 7;
        D = 13;
        OPMODE = 8'b01001010;
        repeat (4) @(negedge clk);

        // Test Case 4
        A = 6;
        B = 3;
        C = 9;
        D = 15;
        OPMODE = 8'b10000000;
        repeat (4) @(negedge clk);

        $stop;
    end

endmodule
