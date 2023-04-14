`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:48:18 11/14/2021 
// Design Name: 
// Module Name:    EXT 
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
module EXT(
    input [15:0] Imm,
    input [1:0] EXTop,
    output [31:0] Imm_Ext
    );

	assign Imm_Ext = (EXTop == 2'b10)? {Imm, {16{1'b0}}}:
						  (EXTop == 2'b01)? {{16{1'b0}}, Imm}:
												  {{16{Imm[15]}}, Imm};

endmodule
