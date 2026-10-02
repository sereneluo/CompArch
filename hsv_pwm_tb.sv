`timescale 10ns/10ns
`include "hsv_pwm.sv"

module hsv_pwm_tb;

    parameter PWM_INTERVAL = 1000;

    logic clk = 0;
    logic RGB_R, RGB_G, RGB_B;

    top #(
        .PWM_INTERVAL (PWM_INTERVAL)
    ) u0 (
        .clk (clk),
        .RGB_R (RGB_R),
        .RGB_G (RGB_G),
        .RGB_B (RGB_B)
    );

    initial begin
        $dumpfile("hsv_pwm.vcd");
        $dumpvars(0, hsv_pwm_tb);
        #100000000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule
