`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:23:54 11/14/2021 
// Design Name: 
// Module Name:    GRF 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module GRF(
    input [4:0] RA1,
    input [4:0] RA2,
    input [4:0] WA,
    input [31:0] WD,
	 input [31:0] PC,
    input RegWrite,
    input clk,
    input reset,
    output [31:0] RD1,
    output [31:0] RD2
    );
	 
	 reg [31:0] grf[0:31];
	 integer i;
	 
	 
	 assign RD1 = ((WA == RA1) && (WA != 0) && (RegWrite == 1'b1)) ? WD : grf[RA1];
    assign RD2 = ((WA == RA2) && (WA != 0) && (RegWrite == 1'b1)) ? WD : grf[RA2];
	 
	 initial begin
		for(i = 0; i < 32; i = i + 1) grf[i] <= 32'd0;
	 end
	 
	 always @(posedge clk) begin
		if(reset) begin
			for(i = 0; i < 32; i = i + 1) grf[i] <= 32'd0;
		end
		else begin
			if((RegWrite == 1'b1) && (WA != 5'd0)) begin
				grf[WA] <= WD;	
				//$dis_play("%d@%h: $%d <= %h", $time, PC, WA, WD);
			end
		end
	 end
	 
	 /*assign RD1 = grf[RA1];
	 assign RD2 = grf[RA2];*/

endmodule
