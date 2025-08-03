module DSP48A1_tb;

    reg [17:0] A, B, D, Bcin;
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
    DSP48A1 #(.B_input("CASCADE"),      
        .CarryInSel("CARRYIN")) DUT (
        .A(A), .B(B), .D(D), .C(C), .clk(clk),
        .carryIn(carryIn), .OPMODE(OPMODE), .Bcin(Bcin),
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
        {A, B, D, C, Bcin, carryIn, OPMODE, PCIN} = 0;

        repeat (2) @(negedge clk);
        {RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCarryIn, RST_OPMODE} = 8'b0000_0000;

        // Test Case 1
        A = 9;
        B = 4;
        Bcin = 18'h0001;
        C = 5;
        D = 1;
        OPMODE = 8'b00111101;
        carryIn = 1'b1;
        repeat (4) @(negedge clk);

        // Test Case 2
        A = 2;
        B = 5;
        Bcin = 18'h0002;
        C = 7;
        D = 15;
        OPMODE = 8'b11010111;
        PCIN = 48'h00f0000f0000;
        carryIn = 1'b0;
        repeat (4) @(negedge clk);

        // Test Case 3
        A = 10;
        B = 1;
        Bcin = 18'h0003;
        C = 7;
        D = 20;
        OPMODE = 8'b01001010;
        carryIn = 1'b0;
        repeat (4) @(negedge clk);

        // Test Case 4
        A = 6;
        B = 3;
        Bcin = 18'h0004;
        C = 9;
        D = 15;
        OPMODE = 8'b10000000;
        carryIn = 1'b0;
        repeat (4) @(negedge clk);

        $stop;
    end

endmodule
