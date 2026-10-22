`timescale 1ns/1ps

// Common self-checking testbench for all three 32-bit adders.
// Required RTL modules and ports:
// ripple_carry_32, brent_kung_32, kogge_stone_32
// Ports: A[31:0], B[31:0], Cin, Sum[31:0], Cout
module tb_all_adders;
    reg  [31:0] A;
    reg  [31:0] B;
    reg         Cin;

    wire [31:0] sum_rca, sum_bk, sum_ks;
    wire        cout_rca, cout_bk, cout_ks;

    reg  [32:0] expected;
    integer i;
    integer errors_rca, errors_bk, errors_ks;
    integer total_tests;

    ripple_carry_32 u_rca (
        .A(A), .B(B), .Cin(Cin), .Sum(sum_rca), .Cout(cout_rca)
    );

    brent_kung_32 u_bk (
        .A(A), .B(B), .Cin(Cin), .Sum(sum_bk), .Cout(cout_bk)
    );

    kogge_stone_32 u_ks (
        .A(A), .B(B), .Cin(Cin), .Sum(sum_ks), .Cout(cout_ks)
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
        end
    endtask

    initial begin
        $dumpfile("sim/all_adders.vcd");
        $dumpvars(0, tb_all_adders);

        A = 0; B = 0; Cin = 0;
        errors_rca = 0; errors_bk = 0; errors_ks = 0;
        total_tests = 0;

        // Directed tests: basic cases, carry propagation, and bit patterns.
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

        // Reproducible pseudo-random regression.
        // $random is deterministic for a given simulator/seed.
        for (i = 0; i < 100000; i = i + 1) begin
            A = {$random, $random};
            B = {$random, $random};
            Cin = $random;
            check_all;
        end

        $display("");
        $display("========== ADDER REGRESSION SUMMARY ==========");
        $display("Total vectors checked: %0d", total_tests);
        $display("RCA errors: %0d", errors_rca);
        $display("Brent-Kung errors: %0d", errors_bk);
        $display("Kogge-Stone errors: %0d", errors_ks);

        if ((errors_rca == 0) && (errors_bk == 0) && (errors_ks == 0))
            $display("PASS: All three adders match the 33-bit reference.");
        else
            $display("FAIL: One or more adder implementations failed.");

        $finish;
    end
endmodule
