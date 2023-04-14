`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:06:12 11/15/2021 
// Design Name: 
// Module Name:    Controller 
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
module Controller(
	 input [31:0] IR,
	 /*input [5:0] Opcode,
    input [5:0] Funct,
	 input [4:0] RtD,*/
    output [2:0] MemtoReg,				
    output MemWrite,
    output MemRead,
    output [1:0] RegDst,
    output Branch,
    output [1:0] ALUASrc,
	 output [1:0] ALUBSrc,
    output j_addr,
    output RegWrite,
	 output j_r,
    output [1:0] EXTop,
	 output [2:0] BEop,
	 output [3:0] ALU_Ctrl,
	 //output [3:0] Byte_En,
	 output [2:0] B_type,
	 output [3:0] DM_type,
	 output [3:0] HILO_type,
	 
	 output eret,
	 output CP0Write,
	 output MayAdE,
	 output MayOv,
	 output RI
    );
	 
	 wire [5:0] Opcode, Funct;
	 wire [4:0] Rs, Rt, Rd;
	
	assign 	Opcode	= 	IR[31:26];
	assign 	Rs			=	IR[25:21];
	assign 	Rt			=	IR[20:16];
	assign 	Rd			=	IR[15:11];
	assign	shamt		=	IR[10:6];
	assign	Funct		= 	IR[5:0];

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
	assign	eret 		=	(IR == 32'h42000018)? 1'b1: 1'b0;
	
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
	
	//assign 	nop		=	(IR == 32'b0) ? 1'b1: 1'b0;
	
	// Exc and newInstr
	assign	CP0Write	=	mtc0;
	assign 	RI 		= 	!(	mfc0 | mtc0 | eret |
									load | store | Branch |
									calc_r | calc_i | md | mt | mf |
								   j_r | j_addr | j_l );
	assign 	MayOv		=	add | addi | sub;
	assign	MayAdE	=	load | store;
	
	// D
	// Branch, j_addr, j_r: NPC's signal
	assign 	EXTop			= 	(addi | addiu | slti | sltiu | load | store)? 2'b00:
									(lui)? 2'b10: 2'b01;
	assign 	B_type		= 	beq?	3'd0:
									bne?	3'd1:
									blez?	3'd2:
									bgez?	3'd3:
									bltz?	3'd4:
									bgtz?	3'd5:
											3'd0;
	// E
	assign 	ALU_Ctrl		= 	lui? 								4'd1:	// lui
									(sub | subu)?					4'd3:	// sub
									(andi | And)? 					4'd4:	// and
									(ori | Or)?						4'd5:	// or
									(Xor | xori)?					4'd6: // xor
									(Nor)?							4'd7:	// nor
									(sll | sllv)?					4'd8:	// sll
									(srl | srlv)? 					4'd9: // srl
									(sra | srav)?					4'd10:// sra
									(slt | slti)?					4'd11:// slt
									(sltu | sltiu)?				4'd12:// sltu
																		4'd2;
																		
	assign 	ALUASrc		=	(shiftS | shiftV)? 1'b1: 1'b0;	// 1: rt; 0: rs
	assign 	ALUBSrc		= 	(calc_r & !(shiftV | shiftS))	? 	2'd0:	// rt
									(calc_i | load | store)			? 	2'd1:	// ext_imm				
									shiftS								?	2'd2:	// shamt
									shiftV								? 	2'd3:	// (GPR[rs])[4:0]
																				2'd0;
									//ori | lui | sw | lw;
	assign 	HILO_type	=  mult	? 	4'd1:
									multu	?	4'd2:
									div	? 	4'd3:
									divu	? 	4'd4:
									mflo 	? 	4'd5:
									mfhi 	? 	4'd6:
									mtlo 	? 	4'd7:
									mthi 	? 	4'd8:
												4'd0;		// do nothing
	// M
	assign 	MemWrite 	=	store;
	assign	MemRead		=	load;
	assign 	BEop			=	(lbu)	? 	3'b001:
									(lb)	?	3'b010:
									(lhu)	?	3'b011:
									(lh)	?	3'b100:
												3'b000;
	assign 	DM_type		=	(lw)	?	1:
									(sw)	? 	2:
									(lh)	? 	3:
									(sh)	? 	4:
									(lhu)	?	5:
									(lb)	?	6:
									(sb)	?	7:
									(lbu)	?	8:
												0;
	// W
	assign 	RegDst		=	(calc_r | jalr | mf)			? 	2'b01: 	// rd
									(calc_i | load | mfc0)		?	2'b00:	// rt
									jal								? 	2'b10:	// 5'd31
																			2'b11;								
	assign 	MemtoReg		=	load	?	1:	// MDW						//{jal, lw};
									j_l	?	2:	// PCW + 8
									mf		?	3:	// mflo | mfhi	
									mfc0	?	4:	// mfc0
												0;	// AOW
	assign 	RegWrite		=	calc_r | calc_i | load | j_l | mf | mfc0;	 

endmodule
