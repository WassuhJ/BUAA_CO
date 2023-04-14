`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:25:34 11/26/2021 
// Design Name: 
// Module Name:    CMP 
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
module CMP(
	input [31:0] R1D,
	input	[31:0] R2D,
	input [2:0] B_type,
	output reg zeroD
    );
	 
	 always @* begin
		case(B_type)
			3'd0: zeroD = (R1D == R2D)? 1'b1: 1'b0;						// beq
			3'd1: zeroD = (R1D != R2D)? 1'b1: 1'b0;						// bne
			3'd2:	begin																// blez
				if($signed(R1D) <= $signed(0)) zeroD = 1'b1;
				else zeroD = 1'b0;
				//zeroD = ($signed(R1D) <= $signed(0))? 1'b1: 1'b0;
			end
			3'd3:	begin																// bgez
				if($signed(R1D) >= $signed(0)) zeroD = 1'b1;
				else zeroD = 1'b0;
				//zeroD = ($signed(R1D) > $signed(0))? 1'b1: 1'b0;
			end
			3'd4:	begin 															// bltz
				if($signed(R1D) < $signed(0)) zeroD = 1'b1;
				else zeroD = 1'b0;
				//zeroD = ($signed(R1D) < $signed(0))? 1'b1: 1'b0;
			end
			3'd5:	begin																// bgtz
				if($signed(R1D) > $signed(0)) zeroD = 1'b1;
				else zeroD = 1'b0;
				//zeroD = ($signed(R1D) >= $signed(0))? 1'b1: 1'b0;
			end
			default: zeroD = 1'b0;
		endcase
	 end

endmodule

	 /*
	 // Branch
	assign 	beq 		= 	(Opcode == 6'b000100)? 1'b1: 1'b0;
	assign 	bne 		= 	(Opcode == 6'b000101)? 1'b1: 1'b0;
	assign 	blez 		= 	(Opcode == 6'b000110)? 1'b1: 1'b0;
	assign 	bgtz 		= 	(Opcode == 6'b000111)? 1'b1: 1'b0;
	assign 	bltz 		= 	(Opcode == 6'b000001 && RtD == 5'd0)? 1'b1: 1'b0;
	assign 	bgez 		= 	(Opcode == 6'b000001 && RtD == 5'd1)? 1'b1: 1'b0;
	 */
