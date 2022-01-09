`timescale 1ns / 1ps
module Embedding_and_Writing(
	input clk,write_enable,HRESETn,
	input [7:0] Secret_message,
	output full_flag	
    );
parameter WIDTH =500;
parameter HEIGHT=332;	 


parameter sizeOfWidth = 8;   
parameter sizeOfLengthReal = HEIGHT*WIDTH*3; 
parameter Receiving=2'b00 , Packing=2'b01 , embedding=2'b10 , writing=2'b11 ;
parameter lengthOfmessage = 6;

reg full_flag_r;

reg [1:0] status;

reg [7:0] memory [0:sizeOfLengthReal-1];

reg [7:0] Message[0:lengthOfmessage-1];
reg 		 Message_1bit[0:(lengthOfmessage*8)-1];
reg [2:0] Message_3bit[0:((lengthOfmessage*8)/3)-1];

reg [7:0] temp_BMP  	  [0 : WIDTH*HEIGHT*3 - 1];   
reg [7:0] org_R 		  [0 : WIDTH*HEIGHT - 1]; // temporary storage for R component
reg [7:0] org_G  	  	  [0 : WIDTH*HEIGHT - 1]; // temporary storage for G component
reg [7:0] org_B 		  [0 : WIDTH*HEIGHT - 1]; // temporary storage for B component

reg [7:0] picture	 [0 : WIDTH*HEIGHT*3 - 1];


// counting variables
integer i,j,x,count;
integer fd;


//////////////////////////Initialization\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\	 

assign full_flag=full_flag_r;

//////////////////////////Initialization\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\	 

initial begin
    fd = $fopen("C:\\Users\\dell\\Desktop\\final licsens project\\verilog code\\matlab-verilog\\imageOftiger_with_message.txt", "w");
end

initial 
begin
	
	full_flag_r=0;
	
   $readmemh("C:\\Users\\dell\\Desktop\\final licsens project\\verilog code\\matlab-verilog\\hexOftiger.hex",memory,0,sizeOfLengthReal-1);

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
		picture [i*3] =  org_R[i] ; 
		picture [(i*3)+1] =  org_G[i] ; 
		picture [(i*3)+2] =  org_B[i] ; 
		end
	count=0;
end

//////////////////////////Mian Part\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\	
always@(posedge clk) 
begin
    if(!HRESETn) begin
		full_flag_r=0;
		for(i=0;i<lengthOfmessage;i=i+1) begin
		Message[i]=0;
		end 
    end 
	 else begin
    if( write_enable == 1'b1) begin
		if(full_flag_r==1'b0)	begin
		status=Receiving ;
		end
	 end
	 
	 case (status)
	 Receiving:
		begin
			Message[count]=Secret_message;
			count=count+1;
			if(count==lengthOfmessage) begin
				status=Packing;
				full_flag_r=1;
				end		
		end

//////////////////////////Message packing\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\	
		
	Packing:
	begin
		for (x=0;x<lengthOfmessage;x=x+1)
		begin
			Message_1bit[x*8]=Message[x][0];
			Message_1bit[(x*8)+1]=Message[x][1];
			Message_1bit[(x*8)+2]=Message[x][2];
			Message_1bit[(x*8)+3]=Message[x][3];
			Message_1bit[(x*8)+4]=Message[x][4];
			Message_1bit[(x*8)+5]=Message[x][5];
			Message_1bit[(x*8)+6]=Message[x][6];
			Message_1bit[(x*8)+7]=Message[x][7];
		end
		for (x=0;x<((lengthOfmessage*8)/3);x=x+1)
		begin 
			Message_3bit[x]={Message_1bit[(3*x)+2],Message_1bit[(3*x)+1],Message_1bit[3*x]};
		end 
		
		status=embedding;
		
	end
	
//////////////////////////Message embedding\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\				
		
	 embedding:
	 begin

			for (count=0 ; count <((lengthOfmessage*8)/3) ; count=count+1) begin 
					picture[count]={picture[count][7:3],Message_3bit[count]};
			end

			status=writing;
						
	 end
	 
//////////////////////////changing Image to odd and even\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\	
	
	writing:
		begin
				
				for(i=0; i<WIDTH*HEIGHT*3; i=i+1) begin
					// write RBG and R1B1G1 (3 bytes) in a loop
					$fwrite(fd, "%d\n", picture[i][7:0]);
				end
				
				$fclose(fd);
				
		full_flag_r=0;
		
		end // Writing end	

	 endcase
	 end // else of if for Reset
end //always 

endmodule
