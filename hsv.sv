// Hue Wheel Color Generator
//
// Divides one 360-degree hue cycle into six 60-degree sectors and produces
// the R, G, and B PWM duty-cycle values for the current point in the cycle,
// following the RGB-vs-hue waveforms of the HSV color wheel.

module hsv #(
    parameter INC_DEC_INTERVAL = 2000,     // CLK frequency is 12MHz, so 2,000 cycles is ~166.7us
    parameter INC_DEC_MAX = 1000,          // 1,000 increments per 60-degree sector (~166.7ms), 6 sectors = 1s
    parameter PWM_INTERVAL = 1000,         // number of PWM duty-cycle levels
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX
)(
    input logic clk,
    output logic [$clog2(PWM_INTERVAL) - 1:0] r_value,
    output logic [$clog2(PWM_INTERVAL) - 1:0] g_value,
    output logic [$clog2(PWM_INTERVAL) - 1:0] b_value
);

    // Define state variable values for the six 60-degree sectors of the hue wheel
    localparam SECTOR0 = 3'd0;      // 0   - 60  degrees: red -> yellow
    localparam SECTOR1 = 3'd1;      // 60  - 120 degrees: yellow -> green
    localparam SECTOR2 = 3'd2;      // 120 - 180 degrees: green -> cyan
    localparam SECTOR3 = 3'd3;      // 180 - 240 degrees: cyan -> blue
    localparam SECTOR4 = 3'd4;      // 240 - 300 degrees: blue -> magenta
    localparam SECTOR5 = 3'd5;      // 300 - 360 degrees: magenta -> red

    // Declare state variables
    logic [2:0] current_sector = SECTOR0;
    logic [2:0] next_sector;

    // Declare variables for timing sector transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    initial begin
        r_value = PWM_INTERVAL;
        g_value = 0;
        b_value = 0;
    end

    // Register the next sector of the FSM
    always_ff @(posedge time_to_transition)
        current_sector <= next_sector;

    // Compute the next sector of the FSM (wraps from SECTOR5 back to SECTOR0)
    always_comb begin
        next_sector = 3'bxxx;
        case (current_sector)
            SECTOR0: next_sector = SECTOR1;
            SECTOR1: next_sector = SECTOR2;
            SECTOR2: next_sector = SECTOR3;
            SECTOR3: next_sector = SECTOR4;
            SECTOR4: next_sector = SECTOR5;
            SECTOR5: next_sector = SECTOR0;
        endcase
    end

    // Implement counter for timing increments/decrements of the R, G, B values
    always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL - 1) begin
            count <= 0;
            time_to_inc_dec <= 1'b1;
        end
        else begin
            count <= count + 1;
            time_to_inc_dec <= 1'b0;
        end
    end

    // Update the R value: held high in sectors 5 & 0, falling in sector 1,
    // held low in sectors 2 & 3, rising in sector 4
    always_ff @(posedge time_to_inc_dec) begin
        case (current_sector)
            SECTOR0: r_value <= r_value;
            SECTOR1: r_value <= r_value - INC_DEC_VAL;
            SECTOR2: r_value <= r_value;
            SECTOR3: r_value <= r_value;
            SECTOR4: r_value <= r_value + INC_DEC_VAL;
            SECTOR5: r_value <= r_value;
        endcase
    end

    // Update the G value: rising in sector 0, held high in sectors 1 & 2,
    // falling in sector 3, held low in sectors 4 & 5
    always_ff @(posedge time_to_inc_dec) begin
        case (current_sector)
            SECTOR0: g_value <= g_value + INC_DEC_VAL;
            SECTOR1: g_value <= g_value;
            SECTOR2: g_value <= g_value;
            SECTOR3: g_value <= g_value - INC_DEC_VAL;
            SECTOR4: g_value <= g_value;
            SECTOR5: g_value <= g_value;
        endcase
    end

    // Update the B value: held low in sectors 0 & 1, rising in sector 2,
    // held high in sectors 3 & 4, falling in sector 5
    always_ff @(posedge time_to_inc_dec) begin
        case (current_sector)
            SECTOR0: b_value <= b_value;
            SECTOR1: b_value <= b_value;
            SECTOR2: b_value <= b_value + INC_DEC_VAL;
            SECTOR3: b_value <= b_value;
            SECTOR4: b_value <= b_value;
            SECTOR5: b_value <= b_value - INC_DEC_VAL;
        endcase
    end

    // Implement counter for timing sector transitions
    always_ff @(posedge time_to_inc_dec) begin
        if (inc_dec_count == INC_DEC_MAX - 1) begin
            inc_dec_count <= 0;
            time_to_transition <= 1'b1;
        end
        else begin
            inc_dec_count <= inc_dec_count + 1;
            time_to_transition <= 1'b0;
        end
    end

endmodule
