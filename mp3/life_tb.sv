`timescale 10ns/10ns
`include "life.sv"

module life_tb;

    logic clk = 1'b0;

    logic advance_blinker = 1'b0;
    logic advance_block    = 1'b0;
    logic advance_lone     = 1'b0;
    logic advance_plus     = 1'b0;
    logic advance_wrap     = 1'b0;

    logic [63:0] grid_blinker;
    logic [63:0] grid_block;
    logic [63:0] grid_lone;
    logic [63:0] grid_plus;
    logic [63:0] grid_wrap;

    int errors = 0;

    //cheking that a horizontal blinker oscillates with period 2
    life #(.INIT_FILE("test_blinker.mem")) dut_blinker (
        .clk (clk), .advance (advance_blinker), .reseed (1'b0), .grid (grid_blinker)
    );

    // checking a 2x2 block is a still life (every cell has exactly 3 neighbors)
    life #(.INIT_FILE("test_block.mem")) dut_block (
        .clk (clk), .advance (advance_block), .reseed (1'b0), .grid (grid_block)
    );

    // checking that an isolated cell dies of underpopulation
    life #(.INIT_FILE("test_lone.mem")) dut_lone (
        .clk (clk), .advance (advance_lone), .reseed (1'b0), .grid (grid_lone)
    );

    // checking that a plus shape's center cell is overpopulated and dies, while four new cells are born around it
    life #(.INIT_FILE("test_plus.mem")) dut_plus (
        .clk (clk), .advance (advance_plus), .reseed (1'b0), .grid (grid_plus)
    );

    // checking that a cyclic boundary exists and that cells wrap around the edge of the matrix
    life #(.INIT_FILE("test_wrap.mem")) dut_wrap (
        .clk (clk), .advance (advance_wrap), .reseed (1'b0), .grid (grid_wrap)
    );

    always begin
        #4 clk = ~clk;
    end

    task automatic check_row(input logic [7:0] actual, input logic [7:0] expected,
                              input int r, input string label);
        if (actual !== expected) begin
            $display("FAIL [%s] row %0d: expected %08b got %08b", label, r, expected, actual);
            errors = errors + 1;
        end
        else begin
            $display("PASS [%s] row %0d: %08b", label, r, actual);
        end
    endtask

    initial begin
        $dumpfile("life.vcd");
        $dumpvars(0, life_tb);

        @(posedge clk);
        #1;

        // generation 1 for every scenario
        @(negedge clk);
        advance_blinker = 1'b1; advance_block = 1'b1; advance_lone = 1'b1;
        advance_plus = 1'b1; advance_wrap = 1'b1;
        @(negedge clk);
        advance_blinker = 1'b0; advance_block = 1'b0; advance_lone = 1'b0;
        advance_plus = 1'b0; advance_wrap = 1'b0;
        #1;

        $display("-- blinker (rules 1, 2, 4) --");
        check_row(grid_blinker[2*8 +: 8], 8'b00001000, 2, "blinker gen1 (born)");
        check_row(grid_blinker[3*8 +: 8], 8'b00001000, 3, "blinker gen1 (survives)");
        check_row(grid_blinker[4*8 +: 8], 8'b00001000, 4, "blinker gen1 (born)");

        $display("-- block, still life (rule 2) --");
        check_row(grid_block[1*8 +: 8], 8'b00000110, 1, "block gen1 unchanged");
        check_row(grid_block[2*8 +: 8], 8'b00000110, 2, "block gen1 unchanged");

        $display("-- lone cell (rule 1) --");
        check_row(grid_lone[3*8 +: 8], 8'h00, 3, "lone cell dies (0 neighbors)");

        $display("-- plus pentomino (rules 3, 4) --");
        check_row(grid_plus[2*8 +: 8], 8'h38, 2, "plus gen1 (two births)");
        check_row(grid_plus[3*8 +: 8], 8'h28, 3, "plus gen1 (center dies, two survive)");
        check_row(grid_plus[4*8 +: 8], 8'h38, 4, "plus gen1 (two births)");

        $display("-- cyclic boundary wraparound (rule 4 across the edge) --");
        check_row(grid_wrap[0*8 +: 8], 8'b10000001, 0, "wraparound gen1 (seeded corners survive)");
        check_row(grid_wrap[7*8 +: 8], 8'b10000001, 7, "wraparound gen1 ((7,7) born via wraparound)");

        // generation 2 for the blinker: should return to horizontal
        @(negedge clk);
        advance_blinker = 1'b1;
        @(negedge clk);
        advance_blinker = 1'b0;
        #1;

        $display("-- blinker generation 2 --");
        check_row(grid_blinker[2*8 +: 8], 8'h00, 2, "blinker gen2 (dies, underpopulation)");
        check_row(grid_blinker[3*8 +: 8], 8'b00011100, 3, "blinker gen2 (back to horizontal)");
        check_row(grid_blinker[4*8 +: 8], 8'h00, 4, "blinker gen2 (dies, underpopulation)");

        if (errors == 0) begin
            $display("ALL TESTS PASSED");
        end
        else begin
            $display("%0d TEST(S) FAILED", errors);
        end

        $finish;
    end

endmodule
