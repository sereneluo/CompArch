`timescale 10ns/10ns
`include "life.sv"

module seed_tb;

    logic clk = 1'b0;
    logic advance = 1'b0;
    logic [63:0] grid;

    logic [7:0] row0, row1, row2, row3, row4, row5, row6, row7;
    assign row0 = grid[0*8 +: 8];
    assign row1 = grid[1*8 +: 8];
    assign row2 = grid[2*8 +: 8];
    assign row3 = grid[3*8 +: 8];
    assign row4 = grid[4*8 +: 8];
    assign row5 = grid[5*8 +: 8];
    assign row6 = grid[6*8 +: 8];
    assign row7 = grid[7*8 +: 8];

    life #(.INIT_FILE("seed.mem")) dut (
        .clk (clk), .advance (advance), .reseed (1'b0), .grid (grid)
    );

    always begin
        #4 clk = ~clk;
    end

    initial begin
        $dumpfile("seed.vcd");
        $dumpvars(0, seed_tb);

        @(posedge clk);
        #1;

        for (int gen = 1; gen <= 40; gen++) begin
            @(negedge clk);
            advance = 1'b1;
            @(negedge clk);
            advance = 1'b0;
            #1;
        end

        $finish;
    end

endmodule
