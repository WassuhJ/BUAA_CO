`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:10:14 11/14/2021 
// Design Name: 
// Module Name:    NPC 
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
//`default_nettype none
module NPC(
	 input Req,
	 input eretD,
	 input [31:0] EPC,
	
    input [31:0] PCF,
	 input [31:0] PCD,
    input [25:0] Imm26,
	 input [15:0] Imm16,
	 input [31:0] ret_Addr,						// jr $ra?
    input PCSrc,
    input Jump,
    input J_return,
    output [31:0] next_PC
    );
	 
	 wire [31:0] PC_Jump;
	 wire [31:0] PC_Branch;
	 wire [31:0] PC_plus4;
	 assign PC_plus4 = PCF + 32'd4;
	 
	 /*wire [31:0] PC_plus8;
	 assign PC_plus8 = PCF + 32'd8;*/
	 
	 assign PC_Jump = {PCD[31:28], Imm26, 2'b00};
	 assign PC_Branch = PCD + 32'd4 + {{14{Imm16[15]}}, Imm16, 2'b00};
						
	 assign next_PC = (Req === 1'b1)			?	32'h0000_4180:
							(eretD === 1'b1)		?	{EPC[31:2] + 1, 2'b00}:			// ????
							(J_return == 1'b1)	? 	ret_Addr:
							(Jump == 1'b1)			?	PC_Jump:
							(PCSrc == 1'b1)		?	PC_Branch:
															PC_plus4;

endmodule
