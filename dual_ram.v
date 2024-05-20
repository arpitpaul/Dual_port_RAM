`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.05.2024 14:25:17
// Design Name: 
// Module Name: dual_ram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dual_ram(

input clk, rst, we,           /////Synchronous 8-bit Dual Port RAM
input [7:0] din1,             //////// Data port : 8 bit
input [7:0] din2,             ////////// Address port : 8 bit
input [7:0] addr,
output reg [8:0] dout
    );
    
    
    reg [8:0] mem [0:255];
    
    integer i;
    
    always @ (posedge clk)
    begin
     if(rst)
      begin
       dout <= 10'd0;
        for(i=0; i<256; i=i+1)
            mem[i] <= 8'd0;
      end
      
      
      else
       begin
         if(we==1'b1)
         begin
          mem[addr] <= din1+din2;
         end
       
           else
            begin
             dout <= mem[addr];
            end
       end
    end
endmodule
