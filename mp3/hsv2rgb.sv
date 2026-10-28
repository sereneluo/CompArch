
module hsv2rgb (
    input  logic [7:0] hue,
    output logic [7:0] r,
    output logic [7:0] g,
    output logic [7:0] b
);

    logic [7:0] pos;

    assign pos = 8'd255 - hue;

    always_comb begin
        if (pos < 8'd85) begin
            r = 8'd255 - pos * 3;
            g = 8'd0;
            b = pos * 3;
        end
        else if (pos < 8'd170) begin
            r = 8'd0;
            g = (pos - 8'd85) * 3;
            b = 8'd255 - (pos - 8'd85) * 3;
        end
        else begin
            r = (pos - 8'd170) * 3;
            g = 8'd255 - (pos - 8'd170) * 3;
            b = 8'd0;
        end
    end

endmodule
