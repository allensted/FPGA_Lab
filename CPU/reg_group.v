module reg_group(
	clk,
	rst,
	reg_en,
	rd,rs,
	alu_out,
	en_in,
	
	en_out,
	rd_q,rs_q

);
	reg[15:0] r0 = 16'b0000000000000000;
	reg[15:0] r1 = 16'b0000000000000000;
	reg[15:0] r2 = 16'b0000000000000000;
	reg[15:0] r3 = 16'b0000000000000000;

	input[3:0] reg_en;
	input[1:0] rd,rs;
	
	input[15:0] alu_out;
	input clk,rst;
	input en_in;
	
	output reg en_out;
	output reg[15:0] rd_q;
	output reg[15:0] rs_q;

	always@(posedge clk)
	begin
		case(reg_en)
			4'b0001:r0 = alu_out;
			4'b0010:r1 = alu_out;
			4'b0100:r2 = alu_out;
			4'b1000:r3 = alu_out;
			default:
			begin
				r0 = r0;
				r1 = r1;
				r2 = r2;
				r3 = r3;
			end
		endcase 		
	end

	
	
	always@(posedge clk or negedge rst)
		if(!rst)
			begin
				rd_q = 16'b0000000000000000;
				rs_q = 16'b0000000000000000;
				en_out = 1'b0;	
			end		
		else 
			begin
				if(en_in == 1)
					begin
						en_out = 1'b1;
						case(rd)
							2'b00:rd_q = r0;
							2'b01:rd_q = r1;
							2'b10:rd_q = r2;
							2'b11:rd_q = r3;
						endcase 
						
						case(rs)
							2'b00:rs_q = r0;
							2'b01:rs_q = r1;
							2'b10:rs_q = r2;
							2'b11:rs_q = r3;
						endcase 
					end
				
				else
					begin
						rd_q = 16'b0000000000000000;
						rs_q = 16'b0000000000000000;
						en_out = 1'b0;		
					end
			end
	
endmodule		