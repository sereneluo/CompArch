`include "hsv.sv"
`include "pwm.sv"

module top #(
    parameter PWM_INTERVAL = 1000 //number of pwm duty cycle levels
)(
    input logic clk,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);

    logic [$clog2(PWM_INTERVAL) - 1:0] r_value, g_value, b_value;
    logic pwm_out_r, pwm_out_g, pwm_out_b;

    hsv #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u1 (
        .clk (clk),
        .r_value (r_value),
        .g_value (g_value),
        .b_value (b_value)
    );

    pwm #(
        .PWM_INTERVAL (PWM_INTERVAL)
    ) u2 (
        .clk (clk),
        .pwm_value (r_value),
        .pwm_out (pwm_out_r)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u3 (
        .clk (clk),
        .pwm_value (g_value),
        .pwm_out (pwm_out_g)
    );

    pwm #(
        .PWM_INTERVAL (PWM_INTERVAL)
    ) u4 (
        .clk (clk),
        .pwm_value (b_value),
        .pwm_out (pwm_out_b)
    );

    assign RGB_R = ~pwm_out_r;
    assign RGB_G = ~pwm_out_g;
    assign RGB_B = ~pwm_out_b;

endmodule
