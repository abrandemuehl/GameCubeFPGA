//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------

module  ball ( input Reset, frame_clk, input logic [7:0] xstick, input logic [7:0] ystick,
    output logic [9:0]  BallX, BallY, BallS);

logic [9:0] Ball_X_Pos, Ball_Y_Pos, Ball_Size;
logic signed [9:0] Ball_X_Motion, Ball_Y_Motion;

parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis

logic signed [9:0] xmotion, ymotion;
assign Ball_Size = 4;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
always_comb begin
	if(xstick[7:5] - 3'b011 <= 3'b100) begin
		// Positive number
		xmotion[2:0] = xstick[7:5] - 3'b011;
		xmotion[9:3] = '0;
	end else begin
		xmotion = xstick[7:5] - 3'b011;
		xmotion[9:3] = '1;
	end
	if(ystick[7:5] - 3'b100 <= 3'b011) begin
		ymotion[2:0] = ystick[7:5] - 3'b100;
		ymotion[9:3] = '0;
	end else begin
		ymotion[2:0] = ystick[7:5] - 3'b100;
		ymotion[9:3] = '1;
	end
	ymotion = (~ymotion) + 1;
end

always_ff @ (posedge Reset or posedge frame_clk )
begin: Move_Ball
	if (Reset)  // Asynchronous Reset
	begin
		Ball_Y_Pos <= Ball_Y_Center;
		Ball_X_Pos <= Ball_X_Center;
	end else begin
		Ball_X_Pos <= Ball_X_Pos + xmotion;
		Ball_Y_Pos <= Ball_Y_Pos + ymotion;
	end
end

assign BallX = Ball_X_Pos;
assign BallY = Ball_Y_Pos;
assign BallS = Ball_Size;

endmodule
