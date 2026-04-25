`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.10.2025 07:49:23
// Design Name: 
// Module Name: passwd
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module passwd(
    input wire clk, // 100 MHz system clock
    input wire [15:0] sw, // 16 switches for 4 digits
    input wire btn_enter, // BTNC - Enter
    input wire btn_reset, // BTND - Reset
    input wire btn_change, // BTNR - Change password
    output reg [6:0] seg, // 7-segment segments a-g (active low)
    output reg [3:0] an // 4-digit anode control (active low)
);
    // ---------------- PASSWORD SETUP ----------------
    // Default password: 1 2 3 4 (4-bit each)
    reg [3:0] pass0 = 4'd1;
    reg [3:0] pass1 = 4'd2;
    reg [3:0] pass2 = 4'd3;
    reg [3:0] pass3 = 4'd4;

    // Split switches into 4 digits
    wire [3:0] d0 = sw[15:12];
    wire [3:0] d1 = sw[11:8];
    wire [3:0] d2 = sw[7:4];
    wire [3:0] d3 = sw[3:0];

    // ---------------- STATE MACHINE ----------------
    localparam IDLE = 2'b00;
    localparam CHECK = 2'b01;
    localparam CHANGE = 2'b10;

    reg [1:0] state = IDLE;
    reg match = 1'b0;
    reg show_result = 1'b0;
    reg changed = 1'b0; // tracks if password was just changed
    
    // 7-Segment Patterns (Active-High: {g,f,e,d,c,b,a})
    // 
    localparam BLANK = 7'b0000000;
    localparam P_SEG = 7'b1110011; // P
    localparam A_SEG = 7'b1110111; // A
    localparam S_SEG = 7'b1101101; // S
    localparam F_SEG = 7'b1110001; // F
    localparam I_SEG = 7'b0000110; // I (or 1)
    localparam L_SEG = 7'b0111000; // L
    localparam D_SEG = 7'b1011110; // d (lowercase)
    localparam O_SEG = 7'b1011100; // o (lowercase)
    localparam N_SEG = 7'b1010100; // n (lowercase)
    localparam E_SEG = 7'b1111001; // E

    // ---------------- BUTTON DEBOUNCE ----------------
    // Basic synchronization and edge detection
    reg [2:0] enter_sync, reset_sync, change_sync;
    always @(posedge clk) begin
        enter_sync <= {enter_sync[1:0], btn_enter};
        reset_sync <= {reset_sync[1:0], btn_reset};
        change_sync <= {change_sync[1:0], btn_change};
    end

    wire enter_pos = (enter_sync[2:1] == 2'b01);
    wire reset_pos = (reset_sync[2:1] == 2'b01);
    wire change_pos = (change_sync[2:1] == 2'b01);

    // ---------------- MAIN LOGIC ----------------
    always @(posedge clk) begin
        if (reset_pos) begin
            state <= IDLE;
            show_result <= 1'b0;
            match <= 1'b0;
            changed <= 1'b0;
        end
        else if (change_pos) begin
            state <= CHANGE;
            show_result <= 1'b0;
            changed <= 1'b0;
        end
        else if (enter_pos) begin
            case (state)
                IDLE: begin
                    // Check entered password
                    show_result <= 1'b1;
                    changed <= 1'b0;
                    if ((d0 == pass0) && (d1 == pass1) && (d2 == pass2) && (d3 == pass3))
                        match <= 1'b1; // Correct
                    else
                        match <= 1'b0; // Incorrect
                end
                CHANGE: begin
                    // Update stored password
                    pass0 <= d0; pass1 <= d1; pass2 <= d2; pass3 <= d3;
                    match <= 1'b1;
                    show_result <= 1'b1;
                    changed <= 1'b1; // Show "DONE"
                    state <= IDLE;
                end
            endcase
        end
    end

    // ---------------- DISPLAY CONTROL (CORRECTED) ----------------
    reg [15:0] refresh_counter = 0;
    wire [1:0] digit_select; // Changed to wire
    reg [6:0] seg_data = 7'b1111111; // Will be immediately set by always @(*)

    // This is a simple, free-running counter
    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
    end

    // Use the top 2 bits of the counter to combinatorially select the digit
    // 2^14 cycles (~164us) are given to each digit.
    // This gives a total refresh rate of ~1.5 kHz, which is perfect.
    assign digit_select = refresh_counter[15:14];

    // ---- NEW DISPLAY LOGIC ----
    always @(*) begin
        // Select which digit is active (active low)
        case (digit_select)
            2'b00: an = 4'b1110; // Digit 0 (right-most)
            2'b01: an = 4'b1101; // Digit 1
            2'b10: an = 4'b1011; // Digit 2
            2'b11: an = 4'b0111; // Digit 3 (left-most)
        endcase

        seg_data = BLANK; // Blank by default (all segments off)

        if (show_result) begin
            if (changed) begin
                // Display "DONE" (D-O-N-E)
                case (digit_select)
                    2'b00: seg_data = E_SEG;
                    2'b01: seg_data = N_SEG;
                    2'b10: seg_data = O_SEG;
                    2'b11: seg_data = D_SEG;
                endcase
            end
            else if (match) begin
                // Display "PASS" (P-A-S-S)
                case (digit_select)
                    2'b00: seg_data = S_SEG;
                    2'b01: seg_data = S_SEG;
                    2'b10: seg_data = A_SEG;
                    2'b11: seg_data = P_SEG;
                endcase
            end
            else begin
                // Display "FAIL" (F-A-I-L)
                case (digit_select)
                    2'b00: seg_data = L_SEG;
                    2'b01: seg_data = I_SEG;
                    2'b10: seg_data = A_SEG;
                    2'b11: seg_data = F_SEG;
                endcase
            end
        end
    end

    // Basys 3 segments are active LOW
    always @(*) seg = ~seg_data;

endmodule
