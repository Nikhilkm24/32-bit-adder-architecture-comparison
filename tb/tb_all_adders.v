`timescale 1ns/1ps

// Common self-checking testbench for all four 32-bit adder architectures:
// 1. Ripple-Carry Adder (RCA)
// 2. Brent-Kung Parallel-Prefix Adder (BKA)
// 3. Kogge-Stone Parallel-Prefix Adder (KSA)
// 4. Han-Carlson Hybrid Parallel-Prefix Adder (HCA)
//
// Ports under test: A[31:0], B[31:0], Cin, Sum[31:0], Cout
// Reference: 33-bit arithmetic result {1'b0, A} + {1'b0, B} + Cin
module tb_all_adders;
    reg  [31:0] A;
    reg  [31:0] B;
    reg         Cin;

    wire [31:0] sum_rca, sum_bk, sum_ks, sum_hc;
    wire        cout_rca, cout_bk, cout_ks, cout_hc;

    reg  [32:0] expected;
    integer i;
    integer errors_rca, errors_bk, errors_ks, errors_hc;
    integer total_tests;

    // Device Under Test (DUT) Instantiations
    ripple_carry_32 u_rca (
        .A(A), .B(B), .Cin(Cin), .Sum(sum_rca), .Cout(cout_rca)
    );

    brent_kung_32 u_bk (
        .A(A), .B(B), .Cin(Cin), .Sum(sum_bk), .Cout(cout_bk)
    );

    kogge_stone_32 u_ks (
        .A(A), .B(B), .Cin(Cin), .Sum(sum_ks), .Cout(cout_ks)
    );

    han_carlson_32 u_hc (
        .A(A), .B(B), .Cin(Cin), .Sum(sum_hc), .Cout(cout_hc)
    );

    task check_all;
        begin
            expected = {1'b0, A} + {1'b0, B} + Cin;
            #1;
            total_tests = total_tests + 1;

            if ({cout_rca, sum_rca} !== expected) begin
                errors_rca = errors_rca + 1;
                $display("RCA ERROR: A=%h B=%h Cin=%b got=%h expected=%h",
                         A, B, Cin, {cout_rca, sum_rca}, expected);
            end
            if ({cout_bk, sum_bk} !== expected) begin
                errors_bk = errors_bk + 1;
                $display("BK ERROR: A=%h B=%h Cin=%b got=%h expected=%h",
                         A, B, Cin, {cout_bk, sum_bk}, expected);
            end
            if ({cout_ks, sum_ks} !== expected) begin
                errors_ks = errors_ks + 1;
                $display("KS ERROR: A=%h B=%h Cin=%b got=%h expected=%h",
                         A, B, Cin, {cout_ks, sum_ks}, expected);
            end
            if ({cout_hc, sum_hc} !== expected) begin
                errors_hc = errors_hc + 1;
                $display("HC ERROR: A=%h B=%h Cin=%b got=%h expected=%h",
                         A, B, Cin, {cout_hc, sum_hc}, expected);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/all_adders.vcd");
        $dumpvars(0, tb_all_adders);

        A = 0; B = 0; Cin = 0;
        errors_rca = 0; errors_bk = 0; errors_ks = 0; errors_hc = 0;
        total_tests = 0;

        // Directed Corner Cases: basic cases, carry propagation, and bit patterns.
        A = 32'h00000000; B = 32'h00000000; Cin = 0; check_all;
        A = 32'h00000001; B = 32'h00000001; Cin = 0; check_all;
        A = 32'hFFFFFFFF; B = 32'h00000001; Cin = 0; check_all;
        A = 32'hFFFFFFFF; B = 32'hFFFFFFFF; Cin = 0; check_all;
        A = 32'hFFFFFFFF; B = 32'hFFFFFFFF; Cin = 1; check_all;
        A = 32'hAAAAAAAA; B = 32'h55555555; Cin = 0; check_all;
        A = 32'h55555555; B = 32'h55555555; Cin = 1; check_all;
        A = 32'h0000FFFF; B = 32'h00000001; Cin = 0; check_all;
        A = 32'h7FFFFFFF; B = 32'h00000001; Cin = 0; check_all;
        A = 32'h80000000; B = 32'h80000000; Cin = 0; check_all;

        // Waveform capture for inspection (first 100 random vectors)
        for (i = 0; i < 100; i = i + 1) begin
            A = {$random, $random};
            B = {$random, $random};
            Cin = $random & 1'b1;
            check_all;
        end
        $dumpoff; // Stop dumping to avoid I/O bottlenecks for remaining regression

        // Complete 100,000 pseudo-random regression suite
        for (i = 100; i < 100000; i = i + 1) begin
            A = {$random, $random};
            B = {$random, $random};
            Cin = $random & 1'b1;
            check_all;
        end

        $display("");
        $display("================== ADDER REGRESSION SUMMARY ==================");
        $display("Total vectors checked: %0d", total_tests);
        $display("Ripple-Carry (RCA) errors : %0d", errors_rca);
        $display("Brent-Kung   (BKA) errors : %0d", errors_bk);
        $display("Kogge-Stone  (KSA) errors : %0d", errors_ks);
        $display("Han-Carlson  (HCA) errors : %0d", errors_hc);

        if ((errors_rca == 0) && (errors_bk == 0) && (errors_ks == 0) && (errors_hc == 0))
            $display("PASS: All four adders match the 33-bit reference with 0 errors.");
        else
            $display("FAIL: One or more adder architectures failed verification.");

        $finish;
    end
endmodule
