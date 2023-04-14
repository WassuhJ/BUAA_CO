`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:39:21 11/21/2021 
// Design Name: 
// Module Name:    RegD 
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
module RegD(
	 input Req,
	 
	 input [4:0] ExcCodeF,
	 output reg [4:0] ExcCodeD,
	 
	 input BDF,
	 output reg BDD,
	
    input [31:0] PCF,
    input [31:0] IRF,
	 input clk,
	 input reset,
	 input Stall,
	 //input clear 				clear = !zeroD && bonall
    output reg [31:0] PCD,
    output reg [31:0] IRD
    );	
	
	always @(posedge clk) begin
		if(reset |(Req === 1'b1)) begin						
			PCD <= (Req === 1'b1) ? 32'h0000_4180: 0;	//32'h0000_3000;
			IRD <= 0;
			ExcCodeD <= 0;
			BDD <= 0;
		end
		else if(!Stall) begin
			PCD <= PCF;
			IRD <= IRF;
			ExcCodeD <= ExcCodeF;
			BDD <= BDF;
		end
	end
	
endmodule

/* || ((!Stall) && clear)*/