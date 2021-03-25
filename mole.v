`timescale 1ns / 1ps

// rise and hit
module mole(
    input rst, clk,
    input button,
    input rise,
    output reg hit,
    output reg enable // control electromagnet
);

parameter DOWN = 1'b0;
parameter UP = 1'b1;

reg state, next_state;
reg next_hit;

always @(posedge clk) begin
    if(rst) begin
        state <= DOWN;
        hit <= 1'b0;
    end
    else begin
        state <= next_state;
        hit <= next_hit;
    end
end

always @(*) begin
    case(state)
        DOWN: begin
            enable = 1'b1;
            if(rise) begin
                next_state = UP;
                next_hit = 1'b0;
            end
            else begin
                next_state = DOWN;
                next_hit = 1'b0;
            end
        end
        UP: begin
            enable = 1'b0;
            if(button) begin
                next_state = DOWN;
                next_hit = 1'b1;
            end
            else begin
                next_state = UP;
                next_hit = 1'b0;
            end
        end
        default: begin
            enable = 1'b0;
            next_state = DOWN;
            next_hit = 1'b0;
        end
    endcase
end

endmodule

//

module Score(
    input rst, clk,
    input [3-1:0] hit,
    output done,
    output reg [10-1:0] score,
    output reg [7-1:0] timer
);

wire [7-1:0] next_timer;
reg start;
reg [10-1:0] next_score;

always @(posedge clk) begin
    if(rst) begin
        timer <= 7'b0;
        score <= 10'b0;
    end
    else begin;
        timer <= next_timer;
        score <= next_score;
    end
end

// timer (add 1 every 2 sec)
counter_timer cnt_0 (.clk (clk), .rst (rst), .start (start), .done (done));
assign next_timer = timer + done;

// start (2 min game)
// score (add 1 point when hit a mole)
always @(*) begin
    if(timer < 7'd60) begin
        start = 1'b1;
        next_score = score + hit[0] + hit[1] + hit[2];
    end
    else begin // finish
        start = 1'b0;
        next_score = score;
    end
end

endmodule

//

module risemole(
    input rst, clk,
    input [7-1:0] timer,
    input done,
    input [10-1:0] score,
    output reg [2-1:0] level, 
    output reg [3-1:0] rise
);

reg [2-1:0] next_level; 
reg [3-1:0] next_rise;
wire [2-1:0] selectmole;
    
always @(posedge clk) begin
    if(rst) begin
        level <= 2'd1;
        rise <= 3'b0;
    end
    else begin
        level <= next_level;
        rise <= next_rise;
    end
end

// select (decided by timer)
assign selectmole = (timer/3 + (timer%5) * (timer%5)) % 4;

// level (decided by score)
// rise (rise some moles every 2 sec randomly)
always @(*) begin
    if(score < 10'd20) begin
        next_level = 2'd1;
        if(done) begin // every 2 sec
            case(selectmole)
                2'd0: next_rise = 3'b001;
                2'd1: next_rise = 3'b010;
                2'd2: next_rise = 3'b100;
                default: next_rise = 3'b000;
            endcase
        end
        else begin
            next_rise = 3'b000;
        end
    end
    else if(score < 10'd50) begin
        next_level = 2'd2;
        if(done) begin
            case(selectmole)
                2'd0: next_rise = 3'b110;
                2'd1: next_rise = 3'b101;
                2'd2: next_rise = 3'b011;
                default: next_rise = 3'b000;
            endcase
        end
        else begin
            next_rise = 3'b000;
        end
    end
    else begin
        next_level = 2'd3;
        if(done) begin
            case(selectmole)
                2'd0: next_rise = 3'b110;
                2'd1: next_rise = 3'b101;
                2'd2: next_rise = 3'b011;
                default: next_rise = 3'b111;
            endcase
        end
        else begin
            next_rise = 3'b000;
        end
    end
end

endmodule

//

module allmole(
    input rst, clk,
    input [3-1:0] bt_mole,
    output [10-1:0] score,
    output [2-1:0] level, 
    output [3-1:0] mole_en,
    output hit_music,
    output [7-1:0] timer
);

wire [3-1:0] hit;
wire done;
wire [3-1:0] rise;

mole mole0(
    .rst (rst),
    .clk (clk),
    .button (bt_mole[0]),
    .rise (rise[0]),
    .hit (hit[0]),
    .enable (mole_en[0])
);

mole mole1(
    .rst (rst),
    .clk (clk),
    .button (bt_mole[1]),
    .rise (rise[1]),
    .hit (hit[1]),
    .enable (mole_en[1])
);

mole mole2(
    .rst (rst),
    .clk (clk),
    .button (bt_mole[2]),
    .rise (rise[2]),
    .hit (hit[2]),
    .enable (mole_en[2])
);

// decide score by hit
Score sc0(.rst(rst), .clk(clk), .hit(hit), .done(done), .score(score), .timer(timer));

// decide level by score / decide which mole to rise by timer 
risemole rm0 (.rst(rst), .clk(clk), .timer(timer), .done(done), .score(score), .level(level), .rise(rise));

// music (when hit, keep hit_music 0.25 sec)
counter_music cm0 (.clk(clk), .rst(rst), .start(|hit), .done(hit_music));

endmodule