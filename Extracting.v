`timescale 1ns / 1ps

module Extracting(
		
		input 	   clk,HRESETn,
		output reg  [7:0]output_message
    );
	 
parameter WIDTH=500;
parameter HEIGHT=332;
parameter sizeOfWidth = 8;   
parameter sizeOfLengthReal = HEIGHT*WIDTH*3; 
parameter Receiving=1'b0 , Packing=1'b1 ;
parameter lengthOfmessage = 6;	 

reg 		 status;

	 
reg [7:0] Message[0:lengthOfmessage-1];
reg 		 Message_1bit[0:(lengthOfmessage*8)-1];
reg [2:0] Message_3bit[0:((lengthOfmessage*8)/3)-1];

reg [7:0] memory [0:sizeOfLengthReal-1];

reg [7:0] temp_BMP  	  [0 : WIDTH*HEIGHT*3 - 1];   
reg [7:0] org_R 		  [0 : WIDTH*HEIGHT - 1]; // temporary storage for R component
reg [7:0] org_G  	  	  [0 : WIDTH*HEIGHT - 1]; // temporary storage for G component
reg [7:0] org_B 		  [0 : WIDTH*HEIGHT - 1]; // temporary storage for B component

reg [7:0] picture	 [0 : WIDTH*HEIGHT*3 - 1];



integer i,j,count,fd,x,y;


initial 
begin

	status=Receiving;
	count=0;
	y=0;
		
   $readmemh("C:\\Users\\dell\\Desktop\\final licsens project\\verilog code\\matlab-verilog\\hexOftiger_with_message.hex",memory,0,sizeOfLengthReal-1);
   
	fd = $fopen("C:\\Users\\dell\\Desktop\\final licsens project\\verilog code\\matlab-verilog\\message.txt", "wb+");
   
	for(i=0; i<WIDTH*HEIGHT*3 ; i=i+1) begin
      temp_BMP[i] = memory[i+0][7:0]; 
   end
        
   for(i=0; i<HEIGHT; i=i+1) begin
       for(j=0; j<WIDTH; j=j+1) begin
     // Matlab code writes image from the last row to the first row
     // Verilog code does the same in reading to correctly save image pixels into 3 separate RGB mem
        org_R[WIDTH*i+j]   = temp_BMP[WIDTH*3*(HEIGHT-i-1)+3*j+0]; // save Red component
        org_G[WIDTH*i+j]   = temp_BMP[WIDTH*3*(HEIGHT-i-1)+3*j+1];// save Green component
        org_B[WIDTH*i+j]   = temp_BMP[WIDTH*3*(HEIGHT-i-1)+3*j+2];// save Blue component

       end
   end
		for (i=0; i<WIDTH*HEIGHT;i=i+1)
		begin
		picture [(i*3)  ] =  org_R[i] ; 
		picture [(i*3)+1] =  org_G[i] ; 
		picture [(i*3)+2] =  org_B[i] ; 
		end
end	
	 
	 always @ (posedge clk)
	 begin
	 
	 if(!HRESETn) begin
		for(i=0;i<lengthOfmessage;i=i+1) begin
		Message[i]=0;
		end 
    end 
	 else begin
		case(status)
		
//////////////////////////Message Receiving\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\	
				Receiving:
				begin
				
						for(count=0 ; count<WIDTH*HEIGHT*3 ; count=count+1) begin
						Message_3bit[count] = picture[count][2:0];// save Red component
							if (count==((lengthOfmessage*8)/3)) begin
								status=Packing;	
							end						
						end
				
				end
				
//////////////////////////Message packing and writing\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\	
				Packing:
				begin
						for (x=0;x<((lengthOfmessage*8)/3);x=x+1)
						begin
							Message_1bit[(x*3)  ]=Message_3bit[x][0];
							Message_1bit[(x*3)+1]=Message_3bit[x][1];
							Message_1bit[(x*3)+2]=Message_3bit[x][2];
						end
						
						for (x=0;x<lengthOfmessage;x=x+1)
						begin 
							Message[x]={Message_1bit[(8*x)+7],Message_1bit[(8*x)+6],
											Message_1bit[(8*x)+5],Message_1bit[(8*x)+4],
											Message_1bit[(8*x)+3],Message_1bit[(8*x)+2],
											Message_1bit[(8*x)+1],Message_1bit[(8*x)]};
						end 
						
						for(i=0; i<lengthOfmessage; i=i+1) 
						begin
							$fwrite(fd, "%c", Message[i][7:0]);
						end
						output_message<=Message[y][7:0];
						y=y+1;
				
				$fclose(fd);
							
				end
		endcase

		end // if of reset
	 end // always

endmodule
