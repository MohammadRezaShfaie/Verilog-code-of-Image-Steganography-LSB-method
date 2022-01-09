`timescale 1ns / 1ps
module Extracting_tb();

	reg clk,HRESETn;
	wire [7:0] output_message;
	

	Extracting DUT (clk,HRESETn,output_message);
		
		initial
		begin
			clk<=0;
			HRESETn<=0;
		end
		
		always #5 clk<=~clk;
		
		initial 
		begin
			#10
			HRESETn<=1;
		end
			
endmodule

