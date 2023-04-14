`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:58:21 11/21/2021 
// Design Name: 
// Module Name:    mips 
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
/*
	1.添加指令时 SCtrl 和 Ctrler 均要添加，要画图考虑全面
	2.清空延迟槽注意 RegD_WE == 1，即 Stall == 0，否则 bonall 等会错误清空延迟槽
		if bonall 
			true_reset = reset || (!Stall && !zeroD)
		else = reset
	3.注意各级流水线寄存器的信号流水，Ctrler 指令外接，多用 MUX 逻辑
*/
//`default_nettype none
module CPU(
    input wire clk,
    input wire reset,
	 input wire [5:0] HWInt,
	 input wire [31:0] i_inst_rdata,
    input wire [31:0] m_data_rdata,
    output wire [31:0] i_inst_addr,
    output wire [31:0] m_data_addr,
    output wire [31:0] m_data_wdata,
    output wire [3:0] m_data_byteen,
    output wire [31:0] m_inst_addr,
    output wire w_grf_we,
    output wire [4:0] w_grf_addr,
    output wire [31:0] w_grf_wdata,
    output wire [31:0] w_inst_addr,
	 
	// input wire [31:0] PrRD,
	 //output wire PrWE,
	 
	 output wire IntFromOut
	);
	
	wire eretD, eretE, eretM;
	wire CP0WriteD, CP0WriteE, CP0WriteM;
	wire MayOvD, MayOvE;
	wire MayAdED, MayAdEE;
	
	wire [31:0] CP0_DOutM, CP0_DOutW;
	wire [31:0] EPC;
	wire BDF, BDD, BDE, BDM;
	wire Req;
	wire [4:0] ExcCodeF, ExcCodeD, ExcCodeE, ExcCodeM;
	wire [4:0] ExcCodeD0, ExcCodeE0, ExcCodeM0;
	wire OvE;
	wire AdEE, AdEM;
	wire AdELF;
	wire RID, RIE;
	
	// pipeline regs'
	wire [31:0] PCF, PCD, PCE, PCM, PCW;
	wire [31:0] AOE, AOM, AOW;
	wire [31:0] IRF, IRD;
	wire [31:0] IMD, IME;
	wire [4:0] WAE, WAM, WAW;
	wire [31:0] WDE, WDM;		
	wire [31:0] MDM, MDW;
	wire [4:0] RsD, RtD, RdD, RsE, RtE, RdE, RdM;
	wire [31:0] R1D, R2D, R1E, R2E;
	
	// Ctrl Signal
	wire [2:0] MemtoRegD, MemtoRegE, MemtoRegM, MemtoRegW;	
	wire RegWriteD, RegWriteE, RegWriteM, RegWriteW;
	wire MemWriteD, MemWriteE, MemWriteM;
	wire MemReadD, MemReadE, MemReadM;
	wire BranchD;
	wire [1:0] ALUASrcD, ALUASrcE, ALUBSrcD, ALUBSrcE;
	wire [3:0] ALUCtrlD, ALUCtrlE;
	wire [1:0] RegDstD, RegDstE;
	wire [1:0] EXTop;
	wire PCSrcD;
	wire zeroD, zeroE;
	wire j_addrD, j_rD;
	wire [2:0] B_typeD;
	wire [3:0] Byte_EnM;
	wire [3:0] DM_typeD, DM_typeE, DM_typeM;
	wire [3:0] HILO_typeD, HILO_typeE;
	wire [2:0] BEopD, BEopE, BEopM;
	
	// F-Signal
	wire [1:0] FR1D, FR2D;
	wire [1:0] FSrcAE, FSrcBE;
	wire [1:0] FWDE;
	wire FWDM;
	
	// S-Signal
	wire [1:0] Tuse_rs;
	wire [1:0] Tuse_rt;
	wire [1:0] TnewD, TnewE, TnewM;
	wire Stall;
	
	// datapath
	wire [31:0] PCnext;
	wire [5:0] Opcode;
	wire [5:0] Funct;
	wire [4:0] shamtD, shamtE;
	wire [25:0] Imm26D;
	wire [15:0] Imm16D;
	wire [31:0] R1D0, R2D0;							// 直接读取的结果，未考虑 D 级转发
	wire [31:0] R1E0, R2E0;							// 未考虑 E 级转发的 reg-E 流水
	wire [31:0] SrcA, SrcB;
	wire [31:0] WDM0;									// WDE0
	wire [31:0] RFWDE, RFWDM, RFWDW;				// GRF.WD(X)
	wire HILO_busy;
   wire [31:0] HILO_resE, HILO_resM, HILO_resW;
	//wire [1:0] AddrD, AddrE, AddrM;
	
	assign Opcode = IRD[31:26];
	assign Funct = IRD[5:0];
	assign RsD = IRD[25:21];
	assign RtD = IRD[20:16];
	assign RdD = IRD[15:11];
	assign shamtD = IRD[10:6];
	assign Imm26D = IRD[25:0];
	assign Imm16D = IRD[15:0];
	assign R1D = //(FR1D == 2'b10)? RFWDE: 
					 (FR1D == 2'b01)? RFWDM: 
											R1D0;										
	assign R2D = //(FR2D == 2'b10)? RFWDE: 
					 (FR2D == 2'b01)? RFWDM: 
											R2D0;
	assign PCSrcD = BranchD & zeroD;
	assign R1E =  (FSrcAE == 2'b00)? R1E0:
					  (FSrcAE == 2'b01)?	RFWDW:
					  (FSrcAE == 2'b10)? RFWDM:			// AOM
												0;
	assign R2E =  (FSrcBE == 2'b00)?	R2E0:
					  (FSrcBE == 2'b01)?	RFWDW:
					  (FSrcBE == 2'b10)? RFWDM:			// AOM
												0;
	assign SrcA = 	(ALUASrcE == 2'b00)? R1E: 
						(ALUASrcE == 2'b01)? R2E:
													0; 			// shift use R2E
	assign SrcB = 	(ALUBSrcE == 2'b00)? R2E:
						(ALUBSrcE == 2'b01)? IME:
						(ALUBSrcE == 2'b10)? {27'b0, shamtE}:
						(ALUBSrcE == 2'b11)? {27'b0, R1E[4:0]}:
													0;				
	assign WAE = 	(RegDstE == 2'b00)? RtE:
						(RegDstE == 2'b01)? RdE: 
						(RegDstE == 2'b10)? 5'd31:
												  0;								
	assign WDE = R2E;									
	/*assign RFWDE = //(MemtoRegE == 2'b00)? AOE:
						(MemtoRegE == 2'b10)? (PCE + 8): 0;
						//(MemtoRegE == 2'b11)? HILO_resE:*/
													
	assign RFWDM = (MemtoRegM == 0)? AOM:
						(MemtoRegM == 1)? MDM:
						(MemtoRegM == 2)? (PCM + 8):
						(MemtoRegM == 3)? HILO_resM:
						(MemtoRegM == 4)? CP0_DOutM:
												0;
	assign RFWDW = (MemtoRegW == 0)? AOW:
						(MemtoRegW == 1)? MDW: 
						(MemtoRegW == 2)? (PCW + 8):
						(MemtoRegW == 3)? HILO_resW:
						(MemtoRegW == 4)? CP0_DOutW:
													 0;
	assign WDM = (FWDM == 1'b1)? RFWDW: WDM0;
	
	/*
	assign WDE = (FWDE == 2'b10)? RFWDM:
					 (FWDE == 2'b01)? RFWDW:
											WDE0;
	*/
		

	FCtrl fctrl(
		.RsD			(RsD),
		.RtD			(RtD),
		.RsE			(RsE),
		.RtE			(RtE),
		.WAE			(WAE),
		.WAM			(WAM),
		.WAW			(WAW),
		.RegWriteE	(RegWriteE),
		.RegWriteM	(RegWriteM),
		.RegWriteW	(RegWriteW),
		.FR1D			(FR1D),
		.FR2D			(FR2D),
		.FSrcAE		(FSrcAE),
		.FSrcBE		(FSrcBE),
		.FWDM			(FWDM)
	);
	
	SCtrl	sctrl(
		.Opcode		(Opcode),		
		.Funct		(Funct),
		.Rs			(RsD),
		.Rt			(RtD),
		.Tuse_rsD	(Tuse_rs),
		.Tuse_rtD	(Tuse_rt),
		.TnewD		(TnewD)
	);
	
	SJudge sj(
		.eretD		(eretD),
		.CP0WriteE	(CP0WriteE),
		.CP0WriteM	(CP0WriteM),
		.RdE			(RdE),
		.RdM			(RdM),
		
		.Rs			(RsD),
		.Rt			(RtD),
		.WAE			(WAE),
		.WAM			(WAM),
		.HILO_busy	(HILO_busy),
		.HILO_typeD	(HILO_typeD),
		.RegWriteE	(RegWriteE),
		.RegWriteM	(RegWriteM),
		.TnewE		(TnewE),
		.TnewM		(TnewM),
		.Tuse_rs		(Tuse_rs),
		.Tuse_rt		(Tuse_rt),
		.Stall		(Stall)
    );
	
	// IF
	
	PC pc(
		.clk			(clk),
		.reset		(reset),
		.Stall		(Stall),
		.PCnext		(PCnext),
		.PCF			(PCF),
		
		.Req			(Req),
		.eretD		(eretD),
		.EPC			(EPC),
		.AdEL			(AdELF)
	);
	
	assign ExcCodeF = (AdELF == 1'b1)	? 	4: 0;
	
	assign i_inst_addr = PCF;
	assign IRF = i_inst_rdata;
	
	assign BDF = BranchD | j_rD | j_addrD;
	// 无论跳转与否均需要置位
	
	RegD d_level(
		.Req			(Req),
		.ExcCodeF	(ExcCodeF),
		.ExcCodeD	(ExcCodeD0),
		.BDF			(BDF),
		.BDD			(BDD),
	
		.PCF			(PCF),
		.IRF			(IRF),
		.clk			(clk),
		.reset		(reset),
		.Stall		(Stall),
		.PCD			(PCD),
		.IRD			(IRD)
	);
	// ID & WB
	CMP cmp(
		.R1D			(R1D),
		.R2D			(R2D),
		.B_type		(B_typeD),
		.zeroD		(zeroD)
	);
	NPC npc(
		.Req			(Req),
		.eretD		(eretD),
		.EPC			(EPC),
		
		.PCF			(PCF),
		.PCD			(PCD),
		.Imm26		(Imm26D),
		.Imm16		(Imm16D),
		.ret_Addr	(R1D),						
		.PCSrc		(PCSrcD),
		.Jump			(j_addrD),
		.J_return	(j_rD),
		.next_PC		(PCnext)
	);
		// ctrler
	Controller ctrler(
		/*.Opcode		(Opcode),
		.Funct		(Funct),*/
		.IR			(IRD),
		.MemtoReg	(MemtoRegD),
		.MemWrite	(MemWriteD),
		.MemRead		(MemReadD),
		.RegDst		(RegDstD),
		.Branch		(BranchD),
		.ALUASrc		(ALUASrcD),
		.ALUBSrc		(ALUBSrcD),
		.j_addr		(j_addrD),
		.RegWrite	(RegWriteD),
		.j_r			(j_rD),
		.EXTop		(EXTop),
		.B_type		(B_typeD),
		.BEop			(BEopD),
		.DM_type		(DM_typeD),
		.HILO_type	(HILO_typeD),
		.ALU_Ctrl	(ALUCtrlD),
		
		.eret			(eretD),
		.CP0Write	(CP0WriteD),
		.MayAdE		(MayAdED),
		.MayOv		(MayOvD),
		.RI			(RID)
	);
	
	assign ExcCodeD = (ExcCodeD0 !== 0)	? 	ExcCodeD0:
							(RID === 1'b1)		?  10:
														0;
	
	assign w_grf_we = RegWriteW;
	assign w_grf_addr = WAW;
	assign w_grf_wdata = RFWDW;
	assign w_inst_addr = PCW;
	
	GRF grf(
		.RA1			(RsD),
		.RA2			(RtD),
		.PC			(PCW),
		.WA			(WAW),
		.WD			(RFWDW),
		.clk			(clk),
		.RegWrite	(RegWriteW),
		.reset		(reset),
		.RD1			(R1D0),
		.RD2			(R2D0)
	);
	EXT ext(
		.Imm			(Imm16D),
		.EXTop		(EXTop),
		.Imm_Ext		(IMD)
	);
	
	
	RegE e_level(
		.MemtoRegD  (MemtoRegD),
	   .RegWriteD 	(RegWriteD),
	   .MemWriteD	(MemWriteD),
	   .MemReadD	(MemReadD),
	   .ALUASrcD	(ALUASrcD),
		.ALUBSrcD	(ALUBSrcD),
		.ALUCtrlD	(ALUCtrlD),
		.RegDstD		(RegDstD),
		.DM_typeD	(DM_typeD),
		.shamtD		(shamtD),
		.shamtE		(shamtE),
		.PCD			(PCD),
		.R1D			(R1D),
		.R2D			(R2D),
		.IMD			(IMD),
		.RsD			(RsD),
		.RtD			(RtD),
		.RdD			(RdD),
		.TnewD		(TnewD),
		.HILO_typeD	(HILO_typeD),
		.BEopD		(BEopD),
		.clk			(clk),
		.reset		(reset),
		.Stall		(Stall),
		.MemtoRegE	(MemtoRegE),
		.RegWriteE	(RegWriteE),
		.MemWriteE	(MemWriteE),
		.MemReadE	(MemReadE),
		.ALUASrcE	(ALUASrcE),
		.ALUBSrcE	(ALUBSrcE),
		.ALUCtrlE	(ALUCtrlE),
		.RegDstE		(RegDstE),
		.PCE			(PCE),
		.R1E			(R1E0),
		.R2E			(R2E0),
		.IME			(IME),
		.RsE			(RsE),
		.RtE			(RtE),
		.RdE			(RdE),
		.TnewE		(TnewE),
		.HILO_typeE	(HILO_typeE),
		.DM_typeE	(DM_typeE),
		.BEopE		(BEopE),
		
		.RID			(RID),
		.RIE			(RIE),
		
		.Req			(Req),
		.eretD		(eretD),
		.eretE		(eretE),
		.CP0WriteD	(CP0WriteD),
		.CP0WriteE	(CP0WriteE),
		.BDD			(BDD),
		.BDE			(BDE),
		.ExcCodeD	(ExcCodeD),
		.ExcCodeE	(ExcCodeE0),
		.MayAdED		(MayAdED),
		.MayAdEE		(MayAdEE),
		.MayOvD		(MayOvD),
		.MayOvE		(MayOvE)
    );

	// Ex
	ALU alu(
		.MayOvE		(MayOvE),
		.MayAdEE		(MayAdEE),
		.OvE			(OvE),
		.AdEE			(AdEE),
		
		.SrcA			(SrcA),
		.SrcB			(SrcB),
		.ALU_Ctrl	(ALUCtrlE),
		.ALU_res		(AOE)
	);
	
	assign ExcCodeE = (ExcCodeE0 != 0)	?	ExcCodeE0:
							(OvE == 1'b1)		?	12:					
														0;
	
	HILO hilo(
		.Req			(Req),
	
		.clk			(clk),
		.reset		(reset),
		.R1E			(R1E),
		.R2E			(R2E),
		.HILO_type	(HILO_typeE),
		.HILO_busy	(HILO_busy),
		.HILO_res	(HILO_resE)
   );
	RegM m_level(
		.MemtoRegE	(MemtoRegE),
		.RegWriteE	(RegWriteE),
		.MemWriteE	(MemWriteE),
		.MemReadE	(MemReadE),
		.PCE			(PCE),					
		.AOE			(AOE),
		.WDE			(WDE),
		.WAE			(WAE),
		.HILO_resE	(HILO_resE),
		.TnewE		(TnewE),
		.BEopE		(BEopE),
		.DM_typeE	(DM_typeE),
		.RdE			(RdE),	
		.clk			(clk),	
		.reset		(reset),
		.MemtoRegM	(MemtoRegM),
		.RegWriteM	(RegWriteM),
		.MemWriteM	(MemWriteM),
		.MemReadM	(MemReadM),
		.PCM			(PCM),
		.AOM			(AOM),
		.WDM			(WDM0),
		.WAM			(WAM),
		.HILO_resM	(HILO_resM),
		.TnewM		(TnewM),
		.DM_typeM	(DM_typeM),
		.BEopM		(BEopM),
		.RdM			(RdM),
		
		.Req			(Req),
		.eretE		(eretE),
		.eretM		(eretM),
		.CP0WriteE	(CP0WriteE),
		.CP0WriteM	(CP0WriteM),
		.BDE			(BDE),
		.BDM			(BDM),
		.ExcCodeE	(ExcCodeE),
		.ExcCodeM	(ExcCodeM0),
		/*.OvE			(OvE),
		.OvM			(OvM),*/
		.AdEE			(AdEE),
		.AdEM			(AdEM)
	);
	
	// Mem
	/*DM dm(
		.Addr			(AOM),
		.WD			(WDM),
		.PC			(PCM),					
		.MemWrite	(MemWriteM),
		.MemRead		(MemReadM),
		.clk			(clk),
		.reset		(reset),
		.RD			(MDM)
	); */
	
	/*assign A1 = RdM;
	assign A2 = RdM;
	assign CP0_DIn = WDM;*/
	
	assign Store 	=	(DM_typeM == 2 || DM_typeM == 4 || DM_typeM == 7);
	assign Load	 	=	(DM_typeM == 1 || DM_typeM == 3 || DM_typeM == 5 || DM_typeM == 6 || DM_typeM == 8);
	assign LhorLb	= 	(DM_typeM == 3 || DM_typeM == 5 || DM_typeM == 6 || DM_typeM == 8);
	assign UseTimer = (AOM >= 32'h7f00 && AOM <= 32'h7f0b) || (AOM >= 32'h7f10 && AOM <= 32'h7f1b);
	assign UseDM	=	(AOM >= 32'h0 && AOM <= 32'h2fff);		 
	
	assign ExcCodeM = (ExcCodeM0 !== 0)														? 	ExcCodeM0:
							((DM_typeM == 1) && (AOM[1:0] != 2'b00)) 						?	4:			
							((DM_typeM == 3 || DM_typeM == 5) && (AOM[0] != 1'b0))	?	4:
							(LhorLb && UseTimer)													?	4:
							(Load && !UseTimer && !UseDM)										? 	4:
							(AdEM && Load)															?	4:
							((DM_typeM == 2) && (AOM[1:0] != 2'b00))						?	5:
							((DM_typeM == 4) && (AOM[0] != 1'b0))							?	5:
							((DM_typeM == 4 || DM_typeM == 7) && UseTimer)				?	5:
							((DM_typeM == 2) && UseTimer && AOM[3:0] == 4'h8)			?	5:
							(Store && !UseTimer && !UseDM)									?	5:
							(AdEM && Store)														?	5:
																											0;
	
	CP0 cp0(
		.A1			(RdM),				
		.A2			(RdM),				
		.DIn			(WDM),				
		.PC			(PCM),	// ???????				
		.ExcCodeIn	(ExcCodeM),		
		.HWInt		(HWInt),			
		.BDIn			(BDM),
		.WE			(CP0WriteM),									
		.EXLClr		(eretM),					
		.clk			(clk),
		.reset		(reset),
		.Req			(Req),								
		.EPC			(EPC),			
		.DOut			(CP0_DOutM),
		
		.IntFromOut	(IntFromOut)
    );
	
	
	wire [31:0] Dread;
	assign DMWE = (MemWriteM) && (!Req);
	
	BE be(
		/*.AdEM			(AdEM),
		.AdELM		(AdELM),
		.AdESM		(AdESM),*/
		.DMWE			(DMWE),
		
		.Addr32		(AOM),
		//.Addr			(AOM[1:0]),
		.Din			(WDM),
		.Dread		(Dread),
		.BEopM		(BEopM),
		.DM_typeM	(DM_typeM),
		.store_res	(m_data_wdata),
		.load_res	(MDM),
		.Byte_EnM	(Byte_EnM)
    );
	
	
	assign Dread = m_data_rdata;
	assign m_data_addr = AOM; 				//{AOM[31:2], 2'b00};
	assign m_data_byteen = Byte_EnM;
	assign m_inst_addr = PCM;
	
	//
		
	RegW w_level(
		.MemtoRegM	(MemtoRegM),
		.RegWriteM	(RegWriteM),
		.MDM			(MDM),
		.AOM			(AOM),
		.WAM			(WAM),
		.PCM			(PCM),
		.HILO_resM	(HILO_resM),
		.clk			(clk),
		.reset		(reset),
		.MemtoRegW	(MemtoRegW),
		.RegWriteW	(RegWriteW),
		.MDW			(MDW),
		.AOW			(AOW),
		.WAW			(WAW),
		.HILO_resW	(HILO_resW),
		.PCW			(PCW),
		
		.Req			(Req),
		.CP0_DOutM	(CP0_DOutM),
		.CP0_DOutW	(CP0_DOutW)
	);
	

endmodule
