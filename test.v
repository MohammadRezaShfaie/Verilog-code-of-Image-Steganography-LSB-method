`timescale 1ns / 1ps
module test();

reg [7:0] num [15:0] ;

integer i , fd;

initial 
begin
	#10
	fd = $fopen("C:\\Users\\dell\\Desktop\\output_v.txt","w");	
	
	for(i=16 ; i<26 ; i=i+1)
	begin 
		
		$fwrite(fd , "%h\n" ,i);
	end
	
	#10
	
	$fclose(fd);
	
end


endmodule
