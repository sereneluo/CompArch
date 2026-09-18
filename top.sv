module top(
    input logic clk,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);

    parameter COLOR_INTERVAL = 2000000;

    logic [$clog2(COLOR_INTERVAL) - 1:0] count = 0;
    logic [2:0] color_index = 0;
    always_ff @(posedge clk) begin
        if (count == COLOR_INTERVAL - 1) begin
            count <= 0;
            color_index <= (color_index == 3'd5) ? 3'd0 : color_index + 3'd1;
        end
        else begin
            count <= count + 1;
        end
    end

    logic r, g, b;
    always_comb begin
        case (color_index)
            3'd0: begin r = 1'b1; g = 1'b0; b = 1'b0; end//red
            3'd1: begin r = 1'b1; g = 1'b1; b = 1'b0; end//yellow
            3'd2: begin r = 1'b0; g = 1'b1; b = 1'b0; end//greeh
            3'd3: begin r = 1'b0; g = 1'b1; b = 1'b1; end//cyan
            3'd4: begin r = 1'b0; g = 1'b0; b = 1'b1; end//blue
            3'd5: begin r = 1'b1; g = 1'b0; b = 1'b1; end//magenta
            default: begin r = 1'b0; g = 1'b0; b = 1'b0; end
        endcase
    end

    assign RGB_R = ~r;
    assign RGB_G = ~g;
    assign RGB_B = ~b;

endmodule