module reg_group(

	reg_en,
	rd,rs,
	alu_out,
	clk,
	rst,
	
	rd_q,rs_q

);
	reg[15:0] r1 = 16'b0000000000000000;
	reg[15:0] r2 = 16'b0000000000000000;
	reg[15:0] r3 = 16'b0000000000000000;
	reg[15:0] r4 = 16'b0000000000000000;

	input[3:0] reg_en;
	input[1:0] rd,rs;
	
	input[15:0] alu_out;
	input clk;
	
	
	always@(posedge clk or negedge rst)
		if(!rst)
		begin
			
			
			
			
			
		end
		
		
		
		
		
		
		else 
			
	
	
	
	
	
	
	end 

endmodule