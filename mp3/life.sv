module life #(
    parameter INIT_FILE = ""
)(
    input  logic         clk,
    input  logic         advance,
    input  logic         reseed,
    output logic [63:0]  grid
);

    logic [7:0] seed_rows [0:7];
    initial if (INIT_FILE) begin
        $readmemh(INIT_FILE, seed_rows);
    end

    logic [63:0] seed;
    always_comb begin
        for (int r = 0; r < 8; r++) begin
            seed[r*8 +: 8] = seed_rows[r];
        end
    end

    // Each cell's alive neighbor count (0-8)
    logic [255:0] neighbors;

    // Count each cell's 8 nearest neighbors, wrapping row/col indices
    always_comb begin
        for (int r = 0; r < 8; r++) begin
            for (int c = 0; c < 8; c++) begin
                neighbors[(r*8+c)*4 +: 4] =
                    grid[((r+7)%8)*8 + ((c+7)%8)] + grid[((r+7)%8)*8 + c] + grid[((r+7)%8)*8 + ((c+1)%8)] +
                    grid[r*8         + ((c+7)%8)]                        + grid[r*8         + ((c+1)%8)] +
                    grid[((r+1)%8)*8 + ((c+7)%8)] + grid[((r+1)%8)*8 + c] + grid[((r+1)%8)*8 + ((c+1)%8)];
            end
        end
    end

    logic [63:0] next_grid;

    // succession rules, applied to every cell in parallel.
    always_comb begin
        for (int r = 0; r < 8; r++) begin
            for (int c = 0; c < 8; c++) begin
                next_grid[r*8+c] = (neighbors[(r*8+c)*4 +: 4] == 4'd3) ||
                                     (grid[r*8+c] && (neighbors[(r*8+c)*4 +: 4] == 4'd2));
            end
        end
    end

    logic loaded = 1'b0;

    always_ff @(posedge clk) begin
        if (!loaded || reseed) begin
            grid <= seed;
            loaded <= 1'b1;
        end
        else if (advance) begin
            grid <= next_grid;
        end
    end

endmodule
