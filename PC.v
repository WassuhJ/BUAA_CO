`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:16:59 11/14/2021 
// Design Name: 
// Module Name:    PC 
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
module PC(
	 input Req,
	 input eretD,
	 input [31:0] EPC,
	 output AdEL,		//ȡָ�쳣
	
    input clk,
    input reset,
	 input Stall,
    input [31:0] PCnext,
    output [31:0] PCF
    );
	 
	parameter init_IAddr = 32'h0000_3000;
	
	reg [31:0] tmp_PCF;
	assign PCF = (eretD === 1'b1)? {EPC[31:2], 2'b00}: tmp_PCF;
	
	assign AdEL = (PCF[1:0] != 2'b0 || !(PCF >= 32'h3000 && PCF <= 32'h6ffc)) ? 1'b1: 1'b0;
	
	always @(posedge clk) begin
		if(reset) 
			tmp_PCF <= init_IAddr;
		else if(!Stall | (Req === 1'b1)) begin
			tmp_PCF <= PCnext; 
		end
	end

endmodule
