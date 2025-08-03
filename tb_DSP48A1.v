module DSP48A1_tb;

    parameter A0REG       = 0;
    parameter A1REG       = 1;
    parameter B0REG       = 0;
    parameter B1REG       = 1;
    parameter CREG        = 1;
    parameter DREG        = 1;
    parameter MREG        = 1;
    parameter PREG        = 1;
    parameter CARRYINREG  = 1;
    parameter CARRYOUTREG = 1;
    parameter OPMODEREG   = 1;
    parameter CARRYINSEL  = "OPMODE5";
    parameter B_INPUT     = "DIRECT";
    parameter RSTTYPE     = "SYNC";

    reg [17:0] A, B, BCIN, D;
    reg [47:0] C, PCIN;
    reg CARRYIN;
    reg [7:0] OPMODE;
    reg CLK;
    reg CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP;
    reg RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP;

    wire [35:0] M;
    wire [47:0] P;
    wire CARRYOUT, CARRYOUTF;
    wire [17:0] BCOUT;
    wire [47:0] PCOUT;

    DSP48A1 #(
        .A0REG(A0REG), .A1REG(A1REG), .B0REG(B0REG), .B1REG(B1REG),
        .CREG(CREG), .DREG(DREG), .MREG(MREG), .PREG(PREG),
        .CARRYINREG(CARRYINREG), .CARRYOUTREG(CARRYOUTREG), .OPMODEREG(OPMODEREG),
        .CARRYINSEL(CARRYINSEL), .B_INPUT(B_INPUT), .RSTTYPE(RSTTYPE)
    ) dut (
        .A(A), .B(B), .BCIN(BCIN), .C(C), .D(D), .CARRYIN(CARRYIN),
        .M(M), .P(P), .CARRYOUT(CARRYOUT), .CARRYOUTF(CARRYOUTF),
        .OPMODE(OPMODE), .CLK(CLK),
        .CEA(CEA), .CEB(CEB), .CEC(CEC), .CECARRYIN(CECARRYIN),
        .CED(CED), .CEM(CEM), .CEOPMODE(CEOPMODE), .CEP(CEP),
        .RSTA(RSTA), .RSTB(RSTB), .RSTC(RSTC), .RSTCARRYIN(RSTCARRYIN),
        .RSTD(RSTD), .RSTM(RSTM), .RSTOPMODE(RSTOPMODE), .RSTP(RSTP),
        .BCOUT(BCOUT), .PCIN(PCIN), .PCOUT(PCOUT)
    );

    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    initial begin
        CEA = 1; CEB = 1; CEC = 1; CECARRYIN = 1;
        CED = 1; CEM = 1; CEOPMODE = 1; CEP = 1;
        
        RSTA = 0; RSTB = 0; RSTC = 0; RSTCARRYIN = 0;
        RSTD = 0; RSTM = 0; RSTOPMODE = 0; RSTP = 0;
        
        A = 0; B = 0; BCIN = 0; C = 0; D = 0; PCIN = 0; CARRYIN = 0; OPMODE = 0;
    end

    initial begin
        $display("Starting Testbench");
      

        repeat(2) @(negedge CLK);

        RSTA = 0; RSTB = 0; RSTC = 0; RSTCARRYIN = 0;
        RSTD = 0; RSTM = 0; RSTOPMODE = 0; RSTP = 0;

        $display("\nTest 2: DSP Path 1");
        
        A = 20; B = 10; C = 350; D = 25;
        OPMODE = 8'b11011101;
        BCIN = 555; PCIN = 777; CARRYIN = 0;
        
        repeat(4) @(negedge CLK);
        $display("A=%d, B=%d, C=%d, D=%d , BCOUT = %h , M = %h , P = %h", A, B, C, D , BCOUT, M, P);
       
        if (BCOUT == 18'hf && M == 36'h12c && P == 48'h32)
            $display("PASS: Expected BCOUT=0xF, M=0x12C, P=0x32");
        else
            $display("FAIL: Expected BCOUT=0xF, M=0x12C, P=0x32");

        $display("\nTest 3: DSP Path 2");
        
        A = 20; B = 10; C = 350; D = 25;
        OPMODE = 8'b00010000;
        BCIN = 333; PCIN = 444; CARRYIN = 1;
        
        repeat(3) @(negedge CLK);
        
      $display("A=%d, B=%d, C=%d, D=%d , BCOUT = %h , M = %h , P = %h", A, B, C, D , BCOUT, M, P);


        if (BCOUT == 18'h23 && M == 36'h2bc && P == 48'h0)
            $display("PASS: Expected BCOUT=0x23, M=0x2BC, P=0x0");
        else
            $display("FAIL: Expected BCOUT=0x23, M=0x2BC, P=0x0");

        $display("\nTest 4: DSP Path 3");
        
        A = 20; B = 10; C = 350; D = 25;
        OPMODE = 8'b00001010;
        BCIN = 111; PCIN = 222; CARRYIN = 0;
        
        repeat(3) @(negedge CLK);
        
        $display("A=%d, B=%d, C=%d, D=%d , BCOUT = %h , M = %h , P = %h", A, B, C, D , BCOUT, M, P);
        
        if (BCOUT == 18'ha && M == 36'hc8)
            $display("PASS: Expected BCOUT=0xA, M=0xC8");
        else
            $display("FAIL: Expected BCOUT=0xA, M=0xC8");

        $display("\nTest 5: DSP Path 4");
        
        A = 5; B = 6; C = 350; D = 25; PCIN = 3000;
        OPMODE = 8'b10100111;
        BCIN = 999; CARRYIN = 1;
        
        repeat(3) @(negedge CLK);
        
       $display("A=%d, B=%d, C=%d, D=%d , BCOUT = %h , M = %h , P = %h", A, B, C, D , BCOUT, M, P);

        if (BCOUT == 18'h6 && M == 36'h1e && P == 48'hfe6fffec0bb1 && CARRYOUT == 1)
            $display("PASS: Expected BCOUT=0x6, M=0x1E, P=0xFE6FFFEC0BB1, CARRYOUT=1");
        else
            $display("FAIL: Expected BCOUT=0x6, M=0x1E, P=0xFE6FFFEC0BB1, CARRYOUT=1");

        repeat(5) @(negedge CLK);
        
        $display("Testbench Complete");
       
        $finish;
    end

endmodule