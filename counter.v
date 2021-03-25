`timescale 1ns / 1ps

module counter_timer (clk, rst, start, done); //2s
    input clk;
    input rst;
    input start;
    output reg done;
    reg [30-1:0] count, next_count;
    always@(posedge clk) begin
        if (rst) begin
            count = 1'b0;
        end
        else begin
            count <= next_count;
        end
    end

    always@(*) begin
        next_count = count;
        if (start) begin
            if (count == 30'd2_0000_0000) begin
                next_count = 30'b0;
                done = 1'b1;
            end
            else begin
                next_count = count + 30'b1;
                done = 1'b0;
            end
        end
        else begin
            next_count = 30'b0;
            done = 1'b0;
        end
    end
endmodule

//

module counter_music (clk, rst, start, done); //0.25s
    input clk;
    input rst;
    input start;
    output reg done;
    reg [30-1:0] count, next_count;
    reg next_done;
    always@(posedge clk) begin
        if (rst) begin
            done <= 1'b0;
            count <= 30'b0;
        end
        else begin
            done <= next_done;
            count <= next_count;
        end
    end

    always@(*) begin
        if (start) begin
            next_done = 1'b1;
            next_count = 30'b0;
        end
        else begin
            if (done) begin
                if(count < 30'd2500_0000) begin
                    next_done = 1'b1;
                    next_count = count + 30'b1;
                end
                else begin
                    next_done = 1'b0;
                    next_count = 30'b0;
                end
            end
            else begin
                next_done = 1'b0;
                next_count = 30'b0;
            end
        end
    end
endmodule
