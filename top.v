`timescale 1ns / 1ps

module top(
    input rst, clk,
    // button
    input [3-1:0] bt_mole,
    // electromagnet
    output [3-1:0] mole_en,
    // 7 seg
    output [4-1:0] an,
    output [7-1:0] seg,
    // countdown
    output [12-1:0] countdown,
    // music
    output pmod_1, pmod_2, pmod_4
    , output on
);

assign on = 1'b1;

wire rst_db, rst_op;
wire [3-1:0] bt_db, bt_op;
wire [10-1:0] score;
wire [2-1:0] level;
wire [7-1:0] timer;
wire hit_music;

//  button debounce/onepulse
debounce db_0 (.pb_debounced (rst_db), .pb (rst), .clk (clk));
onepulse op_0 (.PB_debounced (rst_db), .clk (clk), .PB_one_pulse (rst_op));
debounce db_1 [3-1:0] (.pb_debounced (bt_db), .pb (bt_mole), .clk (clk));
onepulse op_1 [3-1:0] (.PB_debounced (bt_db), .clk (clk), .PB_one_pulse (bt_op));

// display (7 seg)
Display dis_0 (.rst(rst_op), .clk(clk), .score(score), .level(level), .an(an), .seg(seg));

//countdown (LED)
Countdown cntdn(.timer(timer), .countdown(countdown));

// music
music m0 (.clk(clk), .reset(rst_op), .tone(hit_music), .pmod_1(pmod_1), .pmod_2(pmod_2), .pmod_4(pmod_4));

// mole
allmole allmole_0 (
    .rst (rst_op),
    .clk (clk),
    .bt_mole (bt_op),
    .score (score),
    .level (level),
    .mole_en (mole_en),
    .hit_music(hit_music),
    .timer(timer)
);

endmodule

//

module debounce (pb_debounced, pb, clk);
    output pb_debounced; 
    input pb;
    input clk;
    reg [4:0] DFF;
    
    always @(posedge clk) begin
        DFF[4:1] <= DFF[3:0];
        DFF[0] <= pb; 
    end
    assign pb_debounced = (&(DFF)); 
endmodule

//

module onepulse (PB_debounced, clk, PB_one_pulse);
    input PB_debounced;
    input clk;
    output reg PB_one_pulse;
    reg PB_debounced_delay;

    always @(posedge clk) begin
        PB_one_pulse <= PB_debounced & (! PB_debounced_delay);
        PB_debounced_delay <= PB_debounced;
    end 
endmodule

//
