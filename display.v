`timescale 1ns / 1ps

module Num_To_Seg(num, seg);
input [10-1:0] num;
output reg [7-1:0] seg;

always @(*) begin
    case(num)
        10'd0: seg = 7'b1000000;
        10'd1: seg = 7'b1111001;
        10'd2: seg = 7'b0100100;
        10'd3: seg = 7'b0110000;
        10'd4: seg = 7'b0011001;
        10'd5: seg = 7'b0010010;
        10'd6: seg = 7'b0000010;
        10'd7: seg = 7'b1111000;
        10'd8: seg = 7'b0000000;
        10'd9: seg = 7'b0010000;
        default: seg = 7'b0111111;
    endcase
end
endmodule

//

module Clock_Divider_17 (rst, clk, clk_17);
    input rst, clk;
    output reg clk_17;
    reg [17-1:0] cnt;
    wire next_clk_17;
    
    assign next_clk_17 = (cnt == 17'b0) ? 1'b1 : 1'b0;
    
    always @(posedge clk) begin
        if(rst) begin
            cnt <= 17'b0;
            clk_17 <= 1'b0;
        end
        else begin
            cnt <= cnt + 1'b1;
            clk_17 <= next_clk_17;
        end
    end
endmodule

//

module Display(rst, clk, score, level, an, seg);
input rst, clk;
input [10-1:0] score;
input [2-1:0] level;
output [4-1:0] an;
output [7-1:0] seg;

wire clk_17;
wire [7-1:0] seg3, seg2, seg1, seg0;
reg [1:0] cnt;
reg [4-1:0] an, next_an;
reg [7-1:0] seg, next_seg;

Clock_Divider_17 (.rst(rst), .clk(clk), .clk_17(clk_17));
Num_To_Seg n2s_0 (.num (score%10), .seg (seg0));
Num_To_Seg n2s_1 (.num (score/10), .seg (seg1));
Num_To_Seg n2s_3 (.num (level), .seg (seg3));

always @(posedge clk) begin
    if(rst) begin
        cnt <= 1'b0;
        an <= 4'b1110;
        seg <= seg0;
    end
    else begin
        if(clk_17) begin
            cnt <= cnt + 1'b1;
            an <= next_an;
            seg <= next_seg;
        end
        else begin
            cnt <= cnt;
            an <= an;
            seg <= seg;
        end
    end
end

always @(*) begin
    case(cnt)
        2'd0: begin
            next_an = 4'b1110;
            next_seg = seg0;
        end
        2'd1: begin
            next_an = 4'b1101;
            next_seg = seg1;
        end
        2'd2: begin
            next_an = 4'b1111;
            next_seg = seg2;
        end
        2'd3: begin
            next_an = 4'b0111;
            next_seg = seg3;
        end
    endcase
end
endmodule

//

module Countdown(timer, countdown);
input [7-1:0] timer;
output reg [12-1:0] countdown;

always @(*) begin
    case(timer/7'd5)
        7'd0: countdown = 12'b111111111111;
        7'd1: countdown = 12'b011111111111;
        7'd2: countdown = 12'b001111111111;
        7'd3: countdown = 12'b000111111111;
        7'd4: countdown = 12'b000011111111;
        7'd5: countdown = 12'b000001111111;
        7'd6: countdown = 12'b000000111111;
        7'd7: countdown = 12'b000000011111;
        7'd8: countdown = 12'b000000001111;
        7'd9: countdown = 12'b000000000111;
        7'd10: countdown = 12'b000000000011;
        7'd11: countdown = 12'b000000000001;
        default: countdown = 12'b000000000000;
    endcase
end
endmodule
