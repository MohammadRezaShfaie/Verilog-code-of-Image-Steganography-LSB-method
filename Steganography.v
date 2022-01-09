`timescale 1ns / 1ps
module Steganography(
	input clk,write_enable,HRESETn,
	input [7:0] input_message,
	output 	reg Write_Done,full_flag
    );
	 
	 
	 wire 		w_w_Done,w_hsync;
	 wire [7:0] w_R_E,w_R_O,w_G_E,w_G_O,w_B_E,w_B_O;
	 
	 Embedding			Embedding_module		(clk,write_enable,w_w_Done,HRESETn,input_message,full_flag,w_hsync,w_R_O,w_R_E,w_G_O,w_G_E,w_B_O,w_B_E);
	 image_write		image_write_module	(clk,HRESETn,w_hsync,w_R_O,w_G_O,w_B_O,w_R_O,w_R_E,w_G_E,w_B_E,w_w_Done);
		
endmodule
