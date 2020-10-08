module data_path(

	clk, rst, offset_addr,
	en_pc_pulse, pc_ctrl,
	en_in_reg_group,reg_en, alu_in_sel, alu_func,
	en_out, pc_out, rd, rs	
	
);

input clk,rst,en_pc_pulse,en_in_reg_group,alu_in_sel;
input [7:0] offset_addr;
input [1:0] pc_ctrl,rd,rs;
input [3:0] reg_en;
input [2:0] alu_func;
output [15:0] pc_out;
output en_out;

wire [15:0] rd_q, rs_q, alu_a, alu_b, alu_out;	
wire en_out_reg_group, en_out_alu_mux, en_out_alu;  

pc pc1(
	.clk(clk), 
	.rst(rst), 
	.en_in(en_pc_pulse),
	.pc_ctrl(pc_ctrl), 
	.offset_addr(offset_addr), 	
	
	.pc_out(pc_out) 		
);

reg_group reg_group1(
	.clk(clk),
	.rst(rst),
	.en_in(en_in_reg_group),
	.reg_en(reg_en),
	.rd(rd),
	.rs(rs),
	.alu_out(alu_out),	
	
	.en_out(en_out_reg_group),
	.rd_q(rd_q),
	.rs_q(rs_q)
);
	
alu_mux alu_mux1(
	.clk(clk),
	.rst(rst),
	.en_in(en_out_reg_group),
	.alu_in_sel(alu_in_sel),
	.rd_q(rd_q),
	.rs_q(rs_q),
	.offset_addr(offset_addr),
	
	.alu_a(alu_a),
	.alu_b(alu_b),
	.en_out(en_out_alu_mux)

);	
	
alu alu1(
	.clk(clk),
	.rst(rst),
	.en_in(en_out_alu_mux),
	.alu_a(alu_a),
	.alu_b(alu_b),
	.alu_func(alu_func),
	
	.alu_out(alu_out),
	.en_out(en_out)
	
);
	
	
	
	
	
	

endmodule