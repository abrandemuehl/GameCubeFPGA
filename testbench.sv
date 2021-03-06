module testbench();


timeunit 10ns;
timeprecision 1ns;

wire [35:0] GPIO;
logic [17:0] LEDR;
logic [8:0] LEDG;
logic CLOCK_50;
logic gp;
logic[3:0] KEY;
logic [17:0] SW;
wire [6:0] EXT_IO;

logic [7:0] VGA_R;
logic [7:0] VGA_G;
logic [7:0] VGA_B;
logic VGA_CLK;
logic VGA_SYNC_N;
logic VGA_BLANK_N;
logic VGA_VS;
logic VGA_HS;

Gamecube gc(.*);



always begin : CLOCK_GENERATION
#1 CLOCK_50 = ~CLOCK_50;
end

initial begin: CLOCK_INITIALIZATION
    CLOCK_50 = 0;
end


initial begin: TEST_VECTORS
	KEY[1] = '0;
	#50 KEY[1] = '1;


end
endmodule