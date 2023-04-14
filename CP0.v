`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:31:39 12/11/2021 
// Design Name: 
// Module Name:    CP0 
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
module CP0(
    input [4:0] A1,				// 读 CP0 寄存器编号 		执行 mfc0 指令时产生
    input [4:0] A2,				// 写 CP0 寄存器编号		执行 mtc0 指令时产生
    input [31:0] DIn,			// CP0 寄存器的写入数据 	执行 mtc0 指令时产生
    input [31:0] PC,				// 中断/异常时的 PC
    input [4:0] ExcCodeIn,		// 中断/异常的类型			异常功能部件
    input [5:0] HWInt,			// 6 个设备中断				外部设备
	 input BDIn,
    input WE,						// CP0 寄存器写使能			执行 mtc0 指令时产生
	 //input EXLSet,				// 置 1 						流水线在 W 级产生
	 input EXLClr,					// 置 0 SR 的 EXL 位		执行 eret 指令时产生 	
    input clk,
    input reset,
    output Req,					// 中断请求，输出至CPU控制器					
    output [31:0] EPC,			// EXC 寄存器输出至 NPC
    output [31:0] DOut,			// CP0 寄存器的输出数据		执行 mfc0 指令时产生，输出数据至 GPR
    
	 output IntFromOut
	 );
	 
	 assign IntFromOut = HWInt[2] & IM[12] & IE & !EXL;
	 
	 // SR = {16'b0, IM, 8'b0, EXL, IE};
	 reg [15:10] IM;
	 reg EXL, IE;
	 
	 // Cause = {BD, 15'b0, HWInt_pend, 3'b0, ExcCode, 2'b0};
	 reg [15:10] HWInt_pend;
	 reg [6:2] ExcCode;
	 reg BD;
	
	 // EPC
	 reg [31:0] EPC_reg;
	 
	 // PRId
	 reg [31:0] PRId_reg;
	 
	 assign IntReq = (|(HWInt & IM)) & IE & !EXL; 	
	 // 在确定 SR 寄存器相应位无中断屏蔽、当前无中断且全局中断使能允许中断后
	 assign ExcReq = (|ExcCodeIn) & !EXL;				
	 // 存在异常，且不在中断中
	 assign Req = IntReq | ExcReq;
	 
	 assign DOut = (A1 == 12)	?	{16'b0, IM, 8'b0, EXL, IE}:							
						(A1 == 13)	?	{BD, 15'b0, HWInt_pend, 3'b0, ExcCode, 2'b0}:	
						(A1 == 14)	?	EPC:												
						(A1 == 15)	?	PRId_reg:												
											32'd0;

	 assign EPC = EPC_reg;	
	 /*(Req === 1'b1)? (BDIn ? (PC[31:2] - 1): PC[31:2]):*/
											
											
	initial begin
		// SR
		IM <= 0;	
		EXL <= 0;	IE <= 0;
		// Cause
		HWInt_pend <= 0;	BD <= 0;
		ExcCode <= 0;
		// EPC
		EPC_reg <= 0;
		// PRId
		PRId_reg <= 32'h7715_4148;
	end
	 
	 always @(posedge clk) begin
		if(reset) begin
			// SR
			IM <= 0;	
			EXL <= 0;	IE <= 0;
			// Cause
			HWInt_pend <= 0;	BD <= 0;
			ExcCode <= 0;
			// EPC
			EPC_reg <= 0;
			// PRId
			PRId_reg <= 32'h7715_4148;
		end
		else begin
			HWInt_pend <= HWInt;
			if(EXLClr === 1'b1) EXL <= 1'b0;
			
			if(Req === 1'b1) begin
				ExcCode <= (IntReq === 1'b1)? 0: ExcCodeIn;
				EXL <= 1'b1;
				EPC_reg <= (Req === 1'b1)? (BDIn ? (PC - 4): PC):
													EPC_reg;
				BD <= BDIn;
			end
			else if(WE) begin
				if(A2 == 12) begin
					{IM, EXL, IE} <= {DIn[15:10], DIn[1], DIn[0]};
				end
				else if(A2 == 14) begin
					EPC_reg <= DIn; 
				end
			end
			
		end
	 end

endmodule

