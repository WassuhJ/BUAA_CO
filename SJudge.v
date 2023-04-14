`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:46:20 11/23/2021 
// Design Name: 
// Module Name:    SJudge 
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
module SJudge(
	input eretD,
	input CP0WriteE,
	input CP0WriteM,
	input [4:0] RdE,
	input [4:0] RdM,
	
	input [4:0] Rs,
	input [4:0] Rt,
	input [4:0] WAE,
	input [4:0] WAM,
	input HILO_busy,
	input [3:0] HILO_typeD,
	input RegWriteE,
	input RegWriteM,
	input [1:0] TnewE,
	input [1:0] TnewM,
	input [1:0] Tuse_rs,
	input [1:0] Tuse_rt,
	output Stall
    );

	wire Stall_Rs_E, Stall_Rs_M;
	wire Stall_Rt_E, Stall_Rt_M;
	wire Stall_Rs, Stall_Rt;
	
	assign Stall_Rs_E = (Tuse_rs < TnewE) && (Rs != 0) && (Rs == WAE) && RegWriteE;
	assign Stall_Rs_M = (Tuse_rs < TnewM) && (Rs != 0) && (Rs == WAM) && RegWriteM;
	assign Stall_Rs = Stall_Rs_E | Stall_Rs_M;
	
	assign Stall_Rt_E = (Tuse_rt < TnewE) && (Rt != 0) && (Rt == WAE) && RegWriteE;
	assign Stall_Rt_M = (Tuse_rt < TnewM) && (Rt != 0) && (Rt == WAM) && RegWriteM;
	assign Stall_Rt = Stall_Rt_E | Stall_Rt_M;
	
	assign Stall_HILO = (HILO_busy == 1'b1) && (HILO_typeD != 0);
	assign Stall_eret = eretD & ((CP0WriteE & (RdE == 5'd14)) || (CP0WriteM & (RdM == 5'd14)));
	// eret Ç°£¬mtc0 Ð´Èë EPC_reg
	
	assign Stall = Stall_Rs | Stall_Rt | Stall_HILO | Stall_eret;
	
endmodule
