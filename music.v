module music (
    input clk,
    input reset,
    input tone, //piano keys
	output pmod_1,	//AIN
	output pmod_2,	//GAIN
	output pmod_4	//SHUTDOWN_N
);
	
wire [31:0] freq;
assign pmod_2 = 1'd1;	//no gain(6dB)
assign pmod_4 = 1'd1;	//turn-on
	
Decoder decoder00 (
	.tone(tone),
	.freq(freq)
);

PWM_gen pwm_0 ( 
	.clk(clk), 
	.reset(reset), 
	.freq(freq),
	.duty(10'd512), 
	.PWM(pmod_1)
);

endmodule

//

module Decoder (
	input tone,
	output reg [31:0] freq 
);

always @(*) begin
	case (tone)
		1'b1: freq = 32'd262 << 2;	//C6
		default : freq = 32'd20000;	//Do-dummy
	endcase
end

endmodule

//

module PWM_gen (
    input wire clk,
    input wire reset,
	input [31:0] freq,
    input [9:0] duty,
    output reg PWM
);

wire [31:0] count_max = 100_000_000 / freq;
wire [31:0] count_duty = count_max * duty / 1024;
reg [31:0] count;
    
always @(posedge clk, posedge reset) begin
    if (reset) begin
        count <= 0;
        PWM <= 0;
    end else if (count < count_max) begin
        count <= count + 1;
		if(count < count_duty)
            PWM <= 1;
        else
            PWM <= 0;
    end else begin
        count <= 0;
        PWM <= 0;
    end
end

endmodule