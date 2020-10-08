`define B15to0H 3'b000
`define AandBH  3'b011
`define AorBH   3'b100
`define AaddBH  3'b001
`define AsubBH  3'b010
`define AshflH  3'b101
`define AshfrH  3'b110      // 对各种操作指令的定义



module alu(

	input[15:0] alu_a,
	input[15:0] alu_b,
	input[2:0] alu_func,
	
	input en_in,clk,rst,
	
	output reg[15:0] alu_out,
	output reg en_out

);

	always @(posedge clk or negedge rst)
		begin
			if(rst == 1'b0)
				begin
					alu_out = 16'b0000000000000000;
					en_out = 1'b0;
				end 
			else if(en_in == 1'b1)
				begin
					en_out = 1'b1;
					case(alu_func)
						`B15to0H: alu_out = alu_b;
						`AandBH:  alu_out = alu_a & alu_b;
						`AorBH:   alu_out = alu_a | alu_b;
						`AaddBH:  alu_out = alu_a + alu_b;
						`AsubBH:  alu_out = alu_a - alu_b;
						`AshflH:  alu_out = alu_a << 1'b1;
						`AshfrH:  alu_out = alu_a >> 1'b1;
						default:  alu_out = 16'b0000000000000000;
					endcase 			
				end 
				
		end

endmodule




