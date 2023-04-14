`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:13:26 12/11/2021 
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
module mips(
    input wire clk,										// 时钟信号
    input wire reset,									// 同步复位信号
    input wire interrupt,								// 外部中断信号
    output wire [31:0] macroscopic_pc,				// 宏观 PC（见下文）
	 
    output wire [31:0] i_inst_addr,					// 取指 PC
    input wire [31:0] i_inst_rdata,					// i_inst_addr 对应的 32 位指令

    output wire [31:0] m_data_addr,					// 数据存储器待写入地址
    input wire [31:0] m_data_rdata,					// m_data_addr 对应的 32 位数据
    output wire [31:0] m_data_wdata,				// 数据存储器待写入数据
    output wire [3:0] m_data_byteen,				// 字节使能信号

    output wire [31:0] m_inst_addr,					// M 级PC
	 
    output wire w_grf_we,								// grf 写使能信号

    output wire [4:0] w_grf_addr,					// grf 待写入寄存器编号
    output wire [31:0] w_grf_wdata,					// grf 待写入数据
    
	 output wire [31:0] w_inst_addr					// W 级 PC
    );
	 
	 wire [5:0] HWInt;
	 wire [31:0] PrRD, PrWD;
	 wire PrWE;
	/* wire [31:2] PrAddr, DEV_Addr;
	 wire [31:0] DEV_WD;
	 */
	 
	 // Timer
	 wire TCWE1, TCWE2;
	 wire [31:0] TCOut1, TCOut2;
	 wire IRQ1, IRQ2;
	 
	 //wire DMWE;
	 wire IntFromOut;
	 
	 assign HWInt = {3'b0, interrupt, IRQ2, IRQ1};
	 assign macroscopic_pc = m_inst_addr;
	
	 wire [3:0] m_data_byteen0;
	 wire [31:0] m_data_addr0; 
	 wire [31:0] m_data_rdata0;
	 //assign m_data_byteen = _IntFromOut ?	4'b1111:	(DMWE ? m_data_byteen0: 0);
	 
	 reg _IntFromOut;
	 
	 initial begin
		_IntFromOut <= 0;
	 end
	 always @(posedge clk)
		_IntFromOut <= IntFromOut;
    //assign m_data_addr = _IntFromOut ? 32'h7f20: m_data_addr0;
	
	 assign m_data_wdata = PrWD;
	 
	 CPU cpu(
		.clk					(clk),
		.reset				(reset),
		.i_inst_rdata		(i_inst_rdata),
		.m_data_rdata		(PrRD),
		.i_inst_addr		(i_inst_addr),
		.m_data_wdata		(PrWD),
		
		.m_data_addr		(m_data_addr0),
		.m_data_byteen		(m_data_byteen0),
		.m_inst_addr		(m_inst_addr),
		
		.w_grf_we			(w_grf_we),
		.w_grf_addr			(w_grf_addr),
		.w_grf_wdata		(w_grf_wdata),
		.w_inst_addr		(w_inst_addr),
		.HWInt				(HWInt),
		
		//.PrWE					(PrWE),
		//.PrRD					(PrRD),
		
		.IntFromOut			(IntFromOut)
	 );
 
	 Bridge bridge(
		.IntFromOut			(_IntFromOut),
		
		.m_data_addr_in	(m_data_addr0),
		.m_data_addr_out	(m_data_addr),
		
		.m_data_byteen_in	(m_data_byteen0),
		.m_data_byteen_out(m_data_byteen),
		
		.m_data_rdata_in	(m_data_rdata),
		.m_data_rdata_out	(PrRD),
		
		.TCWE1				(TCWE1),
		.TCWE2				(TCWE2),
		
		.TCOut1				(TCOut1),
		.TCOut2				(TCOut2)
	 );
	 
	 // assign 
	 
	 TC Timer1(
		.clk					(clk),
		.reset				(reset),
		.Addr					(m_data_addr[31:2]),
		.WE					(TCWE1),
		.Din					(PrWD),
		.Dout					(TCOut1),
		.IRQ					(IRQ1)
    );
	 
	 TC Timer2(
		.clk					(clk),
		.reset				(reset),
		.Addr					(m_data_addr[31:2]),
		.WE					(TCWE2),
		.Din					(PrWD),
		.Dout					(TCOut2),
		.IRQ					(IRQ2)
    );


endmodule