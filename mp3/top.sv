`include "life.sv"
`include "hsv2rgb.sv"
`include "scan_controller.sv"
`include "ws2812b.sv"

module top #(
    parameter GEN_INTERVAL = 24'd6_000_000,
    parameter HUE_INTERVAL = 18'd150_000 
)(
    input logic     clk,
    input logic     SW,
    input logic     BOOT,
    output logic    _48b,
    output logic    _45a
);

    logic [5:0] pixel;
    logic [63:0] grid;

    logic [23:0] gen_count = 24'd0;
    logic advance = 1'b0;

    logic [17:0] hue_count = 18'd0;
    logic [7:0] hue = 8'd0;

    logic [7:0] cell_r, cell_g, cell_b;
    logic alive;

    logic [23:0] shift_reg = 24'd0;
    logic load_sreg;
    logic transmit_pixel;
    logic shift;
    logic ws2812b_out;

    // synchronizes SW and turns a press into a one-cycle reseed pulse
    logic [1:0] sw_sync = 2'b11;
    logic sw_prev = 1'b1;
    logic reseed;

    always_ff @(posedge clk) begin
        sw_sync <= { sw_sync[0], SW };
        sw_prev <= sw_sync[1];
    end

    assign reseed = sw_prev && ~sw_sync[1];

    // generation timer advances the game-of-life grid once every GEN_INTERVAL clock cycles.
    always_ff @(posedge clk) begin
        if (gen_count == GEN_INTERVAL - 1) begin
            gen_count <= 24'd0;
            advance <= 1'b1;
        end
        else begin
            gen_count <= gen_count + 1;
            advance <= 1'b0;
        end
    end

    always_ff @(posedge clk) begin
        if (hue_count == HUE_INTERVAL - 1) begin
            hue_count <= 18'd0;
            hue <= hue + 1;
        end
        else begin
            hue_count <= hue_count + 1;
        end
    end

    // game of life grid
    life #(
        .INIT_FILE      ("seed.mem")
    ) u1 (
        .clk            (clk),
        .advance        (advance),
        .reseed         (reseed),
        .grid           (grid)
    );

    // hue to RGB color wheel converter
    hsv2rgb u2 (
        .hue            (hue),
        .r              (cell_r),
        .g              (cell_g),
        .b              (cell_b)
    );

    // pixel-scan controller
    scan_controller u3 (
        .clk            (clk),
        .load_sreg      (load_sreg),
        .transmit_pixel (transmit_pixel),
        .pixel          (pixel)
    );

    // WS2812B output driver
    ws2812b u4 (
        .clk            (clk),
        .serial_in      (shift_reg[23]),
        .transmit       (transmit_pixel),
        .ws2812b_out    (ws2812b_out),
        .shift          (shift)
    );

    assign alive = grid[pixel];

    always_ff @(posedge clk) begin
        if (load_sreg) begin
            shift_reg <= alive ? { cell_g, cell_r, cell_b } : 24'd0;
        end
        else if (shift) begin
            shift_reg <= { shift_reg[22:0], 1'b0 };
        end
    end

    assign _48b = ws2812b_out;
    assign _45a = ~ws2812b_out;

endmodule
