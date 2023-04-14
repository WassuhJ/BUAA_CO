`timescale 1ns / 1ps
`define IDLE 2'b00
`define LOAD 2'b01
`define CNT  2'b10
`define INT  2'b11

`define ctrl   mem[0]
`define preset mem[1]
`define count  mem[2]
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:43:39 12/28/2017 
// Design Name: 
// Module Name:    TC 
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
	1) 在允许计数器计数前，应首先停止计数；然后加载初值寄存器；再允许计数。
	2) 无论哪种模式，如果不需要产生中断，则应屏蔽中断
*/
module TC(
    input clk,
    input reset,
    input [31:2] Addr,
    input WE,
    input [31:0] Din,
    output [31:0] Dout,
    output IRQ
    );

	reg [1:0] state;
	reg [31:0] mem [2:0];	
	// 0(CTRL): 	控制寄存器 
	// 1(PRESET): 	初值寄存器 
	// 2(COUNT): 	计数值寄存器
	
	reg _IRQ;
	assign IRQ = `ctrl[3] & _IRQ;
	// IM = Ctrl[3] 		中断屏蔽位, 为 1 允许中断
	// Mode = Ctrl[2:1] 	00: 方式 0; 01: 方式 1
	// Enable = Ctrl[0]	计数器使能，为 1 允许计数
	
	assign Dout = mem[Addr[3:2]];
	
	wire [31:0] load = Addr[3:2] == 0 ? {28'h0, Din[3:0]} : Din;
	
	integer i;
	always @(posedge clk) begin
		if(reset) begin
			state <= 0; 
			for(i = 0; i < 3; i = i+1) mem[i] <= 0;
			_IRQ <= 0;
		end
		else if(WE) begin
			// $display("%d@: *%h <= %h", $time, {Addr, 2'b00}, load);
			mem[Addr[3:2]] <= load;
		end
		else begin
			case(state)
				`IDLE : if(`ctrl[0]) begin
					state <= `LOAD;
					_IRQ <= 1'b0;
				end
				`LOAD : begin
					`count <= `preset;
					state <= `CNT;
				end
				`CNT  : 
					if(`ctrl[0]) begin
						if(`count > 1) `count <= `count-1;
						else begin
							`count <= 0;
							state <= `INT;
							_IRQ <= 1'b1;
						end
					end
					else state <= `IDLE;
				default : begin
					if(`ctrl[2:1] == 2'b00) `ctrl[0] <= 1'b0;
					else _IRQ <= 1'b0;
					state <= `IDLE;
				end
			endcase
		end
	end

endmodule
