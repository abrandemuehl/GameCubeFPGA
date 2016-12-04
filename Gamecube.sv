module Gamecube(input logic CLOCK_50,
					 inout [35:0] GPIO,
					 inout [6:0] EXT_IO,
                input logic [17:0] SW,
					 input logic [3:0] KEY,
					 output logic [17:0] LEDR,
					 output logic [8:0] LEDG,
					 output logic [7:0] VGA_R, VGA_G, VGA_B,
					 output logic VGA_CLK, 
					              VGA_SYNC_N,
									  VGA_BLANK_N,
									  VGA_VS, 
									  VGA_HS,
					 output logic gp);
					 
	assign gp = EXT_IO[3];// == 'z ? '1 : GPIO[26];

	logic ioClk;
	logic poll;
	ClockDivider div0(.Clk50(CLOCK_50), .Compare(32'd24), .Period(32'd49), .Reset('0), .Output(ioClk));
	ClockDivider div2(.Clk50(CLOCK_50), .Compare(32'd50), .Period(32'd300000), .Reset('0), .Output(poll));

	assign EXT_IO[0] = ioClk;
	logic Reset;
	logic Poll;
	logic Rumble;
	logic START;
	logic Y;
	logic X;
	logic B;
	logic A;
	logic L;
	logic R;
	logic Z;
	logic dUP;
	logic dDOWN;
	logic dRIGHT;
	logic dLEFT;
	logic [7:0] joyX;
	logic [7:0] joyY;
	logic [7:0] cstickX;
	logic [7:0] cstickY;
	logic [7:0] lButton;
	logic [7:0] rButton;
	logic [7:0] BallR, BallG, BallB;
	assign Reset = ~KEY[0];
	assign LEDR[0] = Y;
	assign LEDR[1] = X;
	assign LEDR[2] = B;
	assign LEDR[3] = A;
	assign LEDR[4] = L;
	assign LEDR[5] = R;
	assign LEDR[6] = dLEFT;
	assign LEDR[7] = dUP;
	assign LEDR[8] = dDOWN;
	assign LEDR[9] = dRIGHT;
	assign LEDR[10] = Z;
	assign LEDR[11] = START;
	logic vssig;
	logic [9:0] drawxsig, drawysig, ballxsig, ballysig, ballsizesig;
	vga_controller vgasync_instance(.Clk(CLOCK_50), .Reset(Reset), .hs(VGA_HS), .vs(VGA_VS), .pixel_clk(VGA_CLK), 
											  .blank(VGA_BLANK_N), .sync(VGA_SYNC_N), .DrawX(drawxsig), .DrawY(drawysig));

	ball ball_instance(.*, .Reset(Reset), .frame_clk(VGA_VS), .xstick(joyX), .ystick(joyY), .BallX(ballxsig), .BallY(ballysig), .BallS(ballsizesig));
	always_ff @ (posedge CLOCK_50) begin
		if(Y) begin
			BallR = 8'haa;
			BallG = 8'haa;
			BallB = 8'haa;
		end else if(X) begin
			BallR = 8'h55;
			BallG = 8'h55;
			BallB = 8'h55;
		end else if(B) begin
			BallR = 8'hff;
			BallG = 8'h00;
			BallB = 8'h00;
		end else if(A) begin
			BallR = 8'h00;
			BallG = 8'hff;
			BallB = 8'h00;
		end else if(Z) begin
			BallR = 8'hff;
			BallG = 8'h00;
			BallB = 8'hff;
		end else begin
			BallR = 8'hff;
			BallG = 8'hff;
			BallB = 8'hff;
		end
	end
	color_mapper color_instance(.BallX(ballxsig), .BallY(ballysig), .DrawX(drawxsig), .DrawY(drawysig), .Ball_size(ballsizesig), .R(BallR), .G(BallG), .B(BallB), .Red(VGA_R), .Green(VGA_G), .Blue(VGA_B));
	GameCubeIO gc0(.*, .usClock(ioClk), .Reset(~KEY[0]), .Poll(poll), .Rumble(Rumble), .GPIO(EXT_IO[3]), .extra(EXT_IO[2]));

endmodule
