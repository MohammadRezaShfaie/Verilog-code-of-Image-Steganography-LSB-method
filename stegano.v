`timescale 1ns / 1ps
module Embedding(
	input clk,write_enable,write_Done,HRESETn,
	input [7:0] input_message,
	output full_flag,hsync,
	output reg[7:0] org_R_O,  
	output reg[7:0] org_R_E,  
	output reg[7:0] org_G_O,  
	output reg[7:0] org_G_E,   
	output reg[7:0] org_B_O,  
	output reg[7:0] org_B_E  	
    );

parameter WIDTH=25;
parameter HEIGHT=16;
parameter sizeOfWidth = 8;   
parameter sizeOfLengthReal = HEIGHT*WIDTH*3; 
parameter Receiving=2'b00 , Packing=2'b01 , embedding=2'b10 , finished=2'b11 ;
parameter lengthOfmessage = 3;

reg full_flag_r,hsync_r;

reg [1:0] status;

reg [7:0] memory [0:sizeOfLengthReal-1];

reg [7:0] Message[0:lengthOfmessage-1];
reg 		 Message_1bit[0:(lengthOfmessage*8)-1];
reg [2:0] Message_3bit[0:((lengthOfmessage*8)/3)-1];

reg [7:0] temp_BMP  	  [0 : WIDTH*HEIGHT*3 - 1];   
reg [7:0] org_R 		  [0 : WIDTH*HEIGHT - 1]; // temporary storage for R component
reg [7:0] org_G  	  	  [0 : WIDTH*HEIGHT - 1]; // temporary storage for G component
reg [7:0] org_B 		  [0 : WIDTH*HEIGHT - 1]; // temporary storage for B component
reg [7:0] org_R_O_reg  [0 : ((WIDTH*HEIGHT - 1)/2)]; // temporary storage for Odd  data R 
reg [7:0] org_R_E_reg  [0 : ((WIDTH*HEIGHT - 1)/2)]; // temporary storage for Even data R 
reg [7:0] org_G_O_reg  [0 : ((WIDTH*HEIGHT - 1)/2)]; // temporary storage for Odd  data R 
reg [7:0] org_G_E_reg  [0 : ((WIDTH*HEIGHT - 1)/2)]; // temporary storage for Even data R 
reg [7:0] org_B_O_reg  [0 : ((WIDTH*HEIGHT - 1)/2)]; // temporary storage for Odd  data R 
reg [7:0] org_B_E_reg  [0 : ((WIDTH*HEIGHT - 1)/2)]; // temporary storage for Even data R 
reg [7:0] org_R_M	 	  [0 : ((WIDTH*HEIGHT - 1)/2)]; // temporary storage for R component with Message
reg [7:0] org_G_M  	  [0 : ((WIDTH*HEIGHT - 1)/2)]; // temporary storage for G component with Message
reg [7:0] org_B_M  	  [0 : ((WIDTH*HEIGHT - 1)/2)]; // temporary storage for B component with Message


reg [7:0] picture	 [0 : WIDTH*HEIGHT*3 - 1];


// counting variables
reg [7:0] counter;
integer i,j,x,count;


////////////////////////////Assigments\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\	 

assign  full_flag=full_flag_r;
assign  hsync=hsync_r;	

//////////////////////////Initialization\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\	 
initial 
begin
	
	full_flag_r=0;
	
   $readmemh("C:\\Users\\dell\\Desktop\\final licsens project\\matlab codes\\hexOfcoverimage.hex",memory,0,sizeOfLengthReal-1);

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
	counter=0;
end


//////////////////////////Mian Part\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\	

always@(posedge clk) 
begin
    if(!HRESETn) begin
		full_flag_r=0;
		hsync_r=0;
		for(i=0;i<lengthOfmessage;i=i+1) begin
		Message[i]=0;
		end 
    end 
	 else begin
	 if(write_Done==1'b1) begin
	 hsync_r=1'b0;
	 end
    if( write_enable == 1'b1) begin
		if(full_flag_r==1'b0)	begin
		status=Receiving ;
		end
	 end
	 case (status)
	 Receiving:
		begin
			Message[count]=input_message;
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

			for (count=0 ; count <((lengthOfmessage*8)/3); count=count+1 ) begin 
					picture[count]={picture[count][7:3],(picture[count][2:0] ^ Message_3bit[count])};

			end
			full_flag_r=0;
			for(i=0; i<HEIGHT; i=i+1) begin
				for(j=0; j<WIDTH; j=j+1) begin
					org_R_M[i+j] = picture[((i+j)*3)]; 
					org_G_M[i+j] = picture[((i+j)*3)+1];
					org_B_M[i+j] = picture[((i+j)*3)+2];
				end
			end
			status=finished;
			full_flag_r=0;
						
	 end
	 
//////////////////////////changing Image to odd and even\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\	
	
	finished:
		begin
		
		for (i=0 ; i<HEIGHT ; i=i+1) begin
			for (j=0 ; j<WIDTH ; j=j+1) begin
				if (i==(HEIGHT-1)) begin
				hsync_r=1'b1; 
				end
				if (((i+j)%2)==1) begin
				// saving Odd datas 
					org_R_O[i+j] = org_R_M[i+j]; 
					org_G_O[i+j] = org_G_M[i+j];
					org_B_O[i+j] = org_B_M[i+j];
					end
				else begin
					// saving Even datas 
					org_R_E[i+j] = org_R_M[i+j]; 
					org_G_E[i+j] = org_G_M[i+j];
					org_B_E[i+j] = org_B_M[i+j];
					end
			end
		end
		end	

	 endcase
	 end
end

endmodule
