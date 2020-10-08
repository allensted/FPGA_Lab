module alu_mux(
	input[15:0] rd_q,
	input[15:0] rs_q,
	input[7:0] offset_addr,
	input alu_in_sel,
	input clk,rst,
	input en_in,
	
	output reg[15:0] alu_a,
	output reg[15:0] alu_b,
	output reg en_out


);


always @(posedge clk or negedge rst)
	begin
		//只有当en_in有效以及复位无效时才可以有效输出
		if(rst == 1'b0)
			begin
				alu_a = 16'bxxxxxxxxxxxxxxxx;
				alu_b = 16'bxxxxxxxxxxxxxxxx;
				alu_a = 16'bxxxxxxxxxxxxxxxx;
			end 
		else if(en_in == 1'b1)
			begin
				en_out = 1'b1;
				if(alu_in_sel == 0)
					begin
						alu_a = rd_q;
						alu_b = {8'h00,offset_addr};
					end 
				else
					begin
						alu_a = rd_q;
						alu_b = rs_q;
					end 
			end
			
	end 


endmodule