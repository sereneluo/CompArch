module hsv #(
    parameter INC_DEC_INTERVAL = 2000, //clk frequency is 12MHz, so 2 000 cycles is  around 166.7us
    parameter INC_DEC_MAX = 1000, //1000 increments per 60 degree sector, 6 sectors = 1s
    parameter PWM_INTERVAL = 1000, //number of PWM duty-cycle levels
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX
)(
    input logic clk,
    output logic [$clog2(PWM_INTERVAL) - 1:0] r_value,
    output logic [$clog2(PWM_INTERVAL) - 1:0] g_value,
    output logic [$clog2(PWM_INTERVAL) - 1:0] b_value
);


    localparam SECTOR0 = 3'd0; //0 - 60 degrees: red to yellow
    localparam SECTOR1 = 3'd1; //60 - 120 degrees: yellow to green
    localparam SECTOR2 = 3'd2; //120 - 180 degrees: green to cyan
    localparam SECTOR3 = 3'd3; //180 - 240 degrees: cyan to blue
    localparam SECTOR4 = 3'd4; //240 - 300 degrees: blue to magenta
    localparam SECTOR5 = 3'd5; //300 - 360 degrees: magenta to red

    logic [2:0] current_sector = SECTOR0;
    logic [2:0] next_sector;

    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    initial begin
        r_value = PWM_INTERVAL;
        g_value = 0;
        b_value = 0;
    end

    always_ff @(posedge time_to_transition)
        current_sector <= next_sector;

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
