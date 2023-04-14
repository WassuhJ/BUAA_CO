`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:27:45 11/22/2021 
// Design Name: 
// Module Name:    SCtrl 
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
module SCtrl(
	input [5:0] Opcode,
	input [5:0] Funct,
	input [4:0] Rs,
	input [4:0] Rt,
	output [1:0] Tuse_rsD,
	output [1:0] Tuse_rtD,
	output [1:0] TnewD
    );

	assign 	R_type	=	(Opcode == 6'b000000)? 1'b1: 1'b0;

	// load
	assign	lb			= 	(Opcode == 6'b100000)? 1'b1: 1'b0;
	assign	lbu		= 	(Opcode == 6'b100100)? 1'b1: 1'b0;
	assign	lh			= 	(Opcode == 6'b100001)? 1'b1: 1'b0;
	assign	lhu		= 	(Opcode == 6'b100101)? 1'b1: 1'b0;
	assign 	lw 		= 	(Opcode == 6'b100011)? 1'b1: 1'b0;
	
	// store
	assign	sb			=	(Opcode == 6'b101000)? 1'b1: 1'b0;
	assign	sh			=	(Opcode == 6'b101001)? 1'b1: 1'b0;
	assign 	sw			= 	(Opcode == 6'b101011)? 1'b1: 1'b0;
	
	// add
	assign 	add		= 	(R_type == 1'b1 && Funct == 6'b100000)? 1'b1: 1'b0;
	assign 	addu		= 	(R_type == 1'b1 && Funct == 6'b100001)? 1'b1: 1'b0;
	assign 	addi		= 	(Opcode == 6'b001000)? 1'b1: 1'b0;
	assign 	addiu		= 	(Opcode == 6'b001001)? 1'b1: 1'b0;
	
	// sub
	assign	sub		= 	(R_type == 1'b1 && Funct == 6'b100010)? 1'b1: 1'b0;
	assign	subu		= 	(R_type == 1'b1 && Funct == 6'b100011)? 1'b1: 1'b0;
	
	// md
	assign 	mult		= 	(R_type == 1'b1 && Funct == 6'b011000)? 1'b1: 1'b0;
	assign 	multu		= 	(R_type == 1'b1 && Funct == 6'b011001)? 1'b1: 1'b0;
	assign 	div		= 	(R_type == 1'b1 && Funct == 6'b011010)? 1'b1: 1'b0;
	assign 	divu		= 	(R_type == 1'b1 && Funct == 6'b011011)? 1'b1: 1'b0;
	
	// shiftS
	assign 	sll		= 	(R_type == 1'b1 && Funct == 6'b000000)? 1'b1: 1'b0;
	assign 	sra		= 	(R_type == 1'b1 && Funct == 6'b000011)? 1'b1: 1'b0;
	assign 	srl		= 	(R_type == 1'b1 && Funct == 6'b000010)? 1'b1: 1'b0;
	
	// shiftV
	assign 	sllv		= 	(R_type == 1'b1 && Funct == 6'b000100)? 1'b1: 1'b0;
	assign 	srav		= 	(R_type == 1'b1 && Funct == 6'b000111)? 1'b1: 1'b0;
	assign 	srlv		= 	(R_type == 1'b1 && Funct == 6'b000110)? 1'b1: 1'b0;
	
	// logic calc
	assign 	And		= 	(R_type == 1'b1 && Funct == 6'b100100)? 1'b1: 1'b0;
	assign 	Or			= 	(R_type == 1'b1 && Funct == 6'b100101)? 1'b1: 1'b0;
	assign 	Xor		= 	(R_type == 1'b1 && Funct == 6'b100110)? 1'b1: 1'b0;
	assign 	Nor		= 	(R_type == 1'b1 && Funct == 6'b100111)? 1'b1: 1'b0;
	assign 	andi		= 	(Opcode == 6'b001100)? 1'b1: 1'b0;
	assign 	ori		= 	(Opcode == 6'b001101)? 1'b1: 1'b0;
	assign 	xori		= 	(Opcode == 6'b001110)? 1'b1: 1'b0;
	
	// lui
	assign 	lui		= 	(Opcode == 6'b001111)? 1'b1: 1'b0;
	
	// set
	assign	slt		=	(R_type == 1'b1 && Funct == 6'b101010)? 1'b1: 1'b0;
	assign	sltu		=	(R_type == 1'b1 && Funct == 6'b101011)? 1'b1: 1'b0;
	assign	slti		=	(Opcode == 6'b001010)? 1'b1: 1'b0;
	assign	sltiu		=	(Opcode == 6'b001011)? 1'b1: 1'b0;
	
	// Branch
	assign 	beq 		= 	(Opcode == 6'b000100)? 1'b1: 1'b0;
	assign 	bne 		= 	(Opcode == 6'b000101)? 1'b1: 1'b0;
	assign 	blez 		= 	(Opcode == 6'b000110)? 1'b1: 1'b0;
	assign 	bgtz 		= 	(Opcode == 6'b000111)? 1'b1: 1'b0;
	assign 	bltz 		= 	(Opcode == 6'b000001 && Rt == 5'd0)? 1'b1: 1'b0;
	assign 	bgez 		= 	(Opcode == 6'b000001 && Rt == 5'd1)? 1'b1: 1'b0;
	
	// Jump
	assign 	j			= 	(Opcode == 6'b000010)? 1'b1: 1'b0;
	assign 	jal		= 	(Opcode == 6'b000011)? 1'b1: 1'b0;
	assign 	jr			= 	(R_type == 1'b1 && Funct == 6'b001000)? 1'b1: 1'b0;
	assign 	jalr		= 	(R_type == 1'b1 && Funct == 6'b001001)? 1'b1: 1'b0;
	
	// mf & mt
	assign	mfhi		=	(R_type == 1'b1 && Funct == 6'b010000)? 1'b1: 1'b0;
	assign	mthi		=	(R_type == 1'b1 && Funct == 6'b010001)? 1'b1: 1'b0;
	assign	mflo		=	(R_type == 1'b1 && Funct == 6'b010010)? 1'b1: 1'b0;
	assign	mtlo		=	(R_type == 1'b1 && Funct == 6'b010011)? 1'b1: 1'b0;
	
	// Exc & Int
	assign	mfc0		=	(Opcode == 6'b010000 && Rs == 5'b00000)? 1'b1: 1'b0;
	assign 	mtc0		=	(Opcode == 6'b010000 && Rs == 5'b00100)? 1'b1: 1'b0;
	assign	eret 		=	(Opcode == 6'b010000 && Funct == 6'b011000)? 1'b1: 1'b0;
	
	assign	load		= 	lw | lh | lhu | lbu | lb;
	assign	store		=	sw | sh | sb;
	assign 	Branch	= 	beq | bne | blez | bgtz | bgez | bltz;
	assign 	calc_r	= 	add | addu | sub | subu | slt | sltu |
								sll | sllv | srl | srlv | sra | srav |
								And | Or | Xor | Nor;
	assign	calc_i	= 	addi | addiu | andi | ori | xori | slti | sltiu | lui;
	assign 	md			= 	mult | multu | div | divu;
	assign 	mt 		= 	mtlo | mthi;
	assign	mf			= 	mflo | mfhi;
	assign 	shiftS	= 	sll | srl | sra;
	assign 	shiftV	= 	sllv | srlv | srav;
	assign 	j_r		= 	jr | jalr;
	assign 	j_addr 	=	j | jal;
	assign 	j_l		= 	jal | jalr;

	assign 	TnewD 	= 	(calc_r | calc_i | mf)			?	1:
								(load | mfc0)						?	2:
																			0;
								//(Branch | store | j_r | j_l)	? 	0:

	assign 	Tuse_rsD =	((calc_r & !shiftS) | calc_i | store | load | md | mt | mfc0 | mtc0)	?	1: 
								(Branch | j_r)	?  0:	3;
	
	assign 	Tuse_rtD	= 	(calc_r | md)	? 	1:
								(store | mtc0)	?	2:
								(Branch)			?  0:
														3;
	
endmodule
