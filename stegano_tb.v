`timescale 1ns / 1ps
module stegano_tb();

	reg clk,write_enable,HRESETn;
	reg [7:0] Secret_message;
	wire full_flag;
		
		Embedding_and_Writing DUT (clk,write_enable,HRESETn,Secret_message,full_flag);
		
		initial
		begin
			clk<=0;
			write_enable<=0;
		end
		
		always #5 clk<=~clk;
		
		initial 
		begin
			#10
			write_enable<=1;
			Secret_message<=8'b01001000;
			#10
			Secret_message<=8'b01100101;
			#10
			Secret_message<=8'b01101100;
			#10
			Secret_message<=8'b01101100;
			#10
			Secret_message<=8'b01101111;
			#10
			Secret_message<=8'b01101111;
			#1
			write_enable<=0;
		end
			
endmodule
