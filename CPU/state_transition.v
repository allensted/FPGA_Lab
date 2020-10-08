`define B15to0H 3'b000
`define AandBH  3'b011
`define AorBH   3'b100
`define AaddBH  3'b001
`define AsubBH  3'b010
`define AshflH  3'b101
`define AshfrH  3'b110      // 对各种操作指令的定义



module state_transition(

	input en1,en2,
	input en_in,
	input[3:0] opcode,
	input[1:0] rd,
	input clk,rst,

	
	output reg[2:0] alu_func,
	output reg alu_in_sel,en_fetch_pulse,
	en_pc_pulse,en_rf_pulse,
	output reg[1:0] pc_ctrl,
	output reg[3:0] reg_en
	
);


reg en_fetch_reg,en_fetch;
reg en_rf_reg,en_rf;
reg en_pc_reg,en_pc;
reg [3:0] current_state,next_state;
// 定义指令对应的编码
parameter Initial = 4'b0000;
parameter Fetch = 4'b0001;
parameter Decode = 4'b0010;
parameter Execute_Movel = 4'b0011;
parameter Execute_Move2 = 4'b0100;
parameter Execute_Add1 = 4'b0101;
parameter Execute_Add2 = 4'b0110;
parameter Execute_Sub = 4'b0111;
parameter Execute_And = 4'b1000;
parameter Execute_Or = 4'b1001;
parameter Execute_Jump = 4'b1010;
parameter Execute_Leftshift = 4'b1011;
parameter Execute_Rightshift = 4'b1100;
parameter Write_back = 4'b1101;

// 状态转移
always @ (posedge clk or negedge rst) 
begin
// 如果rst就置当前状态为Initial，否则当前状态转到下一个状态
	if(!rst)
		current_state = Initial;
	else 
		current_state = next_state;
end
// 控制下一状态
always @ (current_state or en_in or en1 or en2 or opcode) 
begin
	case (current_state)
		Initial: 
		// 初始化状态，如果使能有效则取指令，否则保持状态
		begin
			if(en_in)
				next_state = Fetch;
			else
				next_state = current_state;
		end
		Fetch: 
		// 取指令，如果ir输出使能有效则下一个状态为译码，否则保持当前状态
		begin
			if(en1) 
				next_state = Decode;
			else
				next_state = current_state;
		end
		Decode: 
		// 译码，根据opcode设置下一状态
		begin
			case(opcode) 
				4'b0000: next_state = Execute_Movel;
				4'b0001: next_state = Execute_Move2;
				4'b0010: next_state = Execute_Add1;
				4'b0011: next_state = Execute_Add2;
				4'b0100: next_state = Execute_Sub;
				4'b0101: next_state = Execute_And;
				4'b0110: next_state = Execute_Or;
				4'b0111: next_state = Execute_Jump;
				4'b1000: next_state = Execute_Leftshift;
				4'b1001: next_state = Execute_Rightshift;
				default: next_state = current_state;
			endcase
		end
		// 其他操作，在alu输出使能有效时，下一状态为回写，否则保持当前状态
		
		//把立即数（offset_addr）赋值给R1
		Execute_Movel: 
		begin
			if(en2)
				next_state = Write_back;
			else
				next_state = current_state;
		end
		
		//把R1赋值给R2
		Execute_Move2: 
		begin
			if(en2)
				next_state = Write_back;
			else
				next_state = current_state;
		end
		
		//把R1加上8：把立即数场赋值给alu_b然后加到alu_a上面
		Execute_Add1: 
		begin
			if(en2)
				next_state = Write_back;
			else
				next_state = current_state;
		end
		
		//选择把R1 R2的值加到一起 存到R1
		Execute_Add2: 
		begin
			if(en2)
				next_state = Write_back;
			else
				next_state = current_state;
		end
		Execute_Sub: 
		begin
			if(en2)
				next_state = Write_back;
			else
				next_state = current_state;
		end
		Execute_And: 
		begin
			if(en2)
				next_state = Write_back;
			else
				next_state = current_state;
		end	
		Execute_Or: 
		begin
			if(en2)
				next_state = Write_back;
			else
				next_state = current_state;
		end
		Execute_Leftshift: 
		begin
			if(en2)
				next_state = Write_back;
			else
				next_state = current_state;
		end
		Execute_Rightshift:
		begin
			if(en2)
				next_state = Write_back;
			else
				next_state = current_state;
		end
		// 思考:为什么jump和Write_back的下一状态都为取指令
		//没懂JUMP是什么意思
		Execute_Jump: 
			next_state = Fetch;
		Write_back:
			next_state = Fetch;
		default: 
			next_state = current_state;
	endcase
end
//根据不同状态设置
//		en_fetch
//		en_rf
//		en_pc
//		pc_ctrl
//		reg_en
//		alu_in_sel
//		alu_func
// 参数的值，使得其他状态进行相应操作
// 思考：
// 1.什么指令要置alu_in_sel为1，不同指令的pc_ctrl的值
		//alu_in_sel 为1 的时候alu_a 和alu_b的值可以分别是R1 R2这样可以进行运算  不同的pc_ctrl输出值不一样
// 2.Execute_Movel，Execute_Move2的区别在哪儿，该怎么操作
		//一个是把R1赋值为立即数 一个是把R2变为R1的值
// 3.en_pc_pulse,en_rf_pulse,en_fetch_pulse应该在什么情况产生
		//？
// 4.在什么时候让程序计数器加一
		//?
// 5.为什么是next_state
		//因为每个时钟上升沿都会把current_state 更新为next_state
always @ (clk or rst or next_state) 
begin
	if(!rst) 
	begin
		en_fetch = 1'b0;
		en_rf = 1'b0;
		en_pc = 1'b0;
		pc_ctrl = 2'b00;
		reg_en = 4'b0000;
		alu_in_sel = 1'b0;
		alu_func = 3'b000;
	end
	else 
	begin
		case (next_state)
			Initial: 
			// 初始化时，将参数全置0
			begin
				en_fetch = 1'b0;
				en_rf = 1'b0;
				en_pc = 1'b0;
				pc_ctrl = 2'b00;
				reg_en = 4'b0000;
				alu_in_sel = 1'b0;
				alu_func = 3'b000;
			end
			Fetch: 
			begin
				en_fetch = 1'b1;
				en_rf = 1'b0;
				en_pc = 1'b1;
				pc_ctrl = 2'b01;
				reg_en = 4'b0000;
				alu_in_sel = 1'b0;
				alu_func = 3'b000;
			end
			Decode: 
			// 译码时什么操作都不做
			begin
				en_fetch = 1'b0;
				en_rf = 1'b0;
				en_pc = 1'b0;
				pc_ctrl = 2'b00;
				reg_en = 4'b0000;
				alu_in_sel = 1'b0;
				alu_func = 3'b000;
			end
			//把立即数（offset_addr）赋值给R1
		Execute_Movel: 
			begin
				en_fetch = 1'b0;
				en_rf = 1'b0;
				en_pc = 1'b1;
				pc_ctrl = 2'b10;
				//为什么不使能 en_group?它起到什么作用？
				
				//选择R1
				reg_en = 4'b0010;
				//选择rd_q输入为R1

				//选择alu_b = offset_addr
				alu_in_sel = 1'b0;
				//选择输出alu_b
				alu_func = `B15to0H;
			end
		//把R1赋值给R2
		Execute_Move2: 
			begin
				en_fetch = 1'b0;
				en_rf = 1'b0;
				en_pc = 1'b1;
				pc_ctrl = 2'b10;
				
				//选择R2
				reg_en = 4'b0100;
				//选择rd_q输入为R2 rs_q输入为R1
				//为什么rs不是state_transition的输入呢？为什么只有rd  rs = 01;
				//选择alu_a = rd_q;alu_b = rs_q;
				alu_in_sel = 1'b1;
				//选择输出alu_b
				alu_func = `B15to0H;
			end
		//把R1加上8：把立即数场赋值给alu_b然后加到alu_a上面
		Execute_Add1: 
			begin
				en_fetch = 1'b0;
				en_rf = 1'b0;
				en_pc = 1'b1;
				pc_ctrl = 2'b10;
				
				//选择R1
				reg_en = 4'b0100;
				//选择rd_q输入为R1
			
				//选择alu_b = offset_addr
				alu_in_sel = 1'b0;
				//选择把alu_a+alu_b组作为输出
				alu_func = `AaddBH;
			end
		
		//选择把R1 R2的值加到一起 存到R1
		Execute_Add2: 
			begin
				en_fetch = 1'b0;
				en_rf = 1'b0;
				en_pc = 1'b1;
				pc_ctrl = 2'b10;
				
				//选择R2
				reg_en = 4'b0010;
				//选择rd_q输入为R2 rs_q输入为R1
				
				//rs = 10;
				//选择alu_a = rd_q;alu_b = rs_q;
				alu_in_sel = 1'b1;
				//选择把alu_a+alu_b组作为输出
				alu_func = `B15to0H;
			end
		Execute_Sub: 
			begin
				en_fetch = 1'b0;
				en_rf = 1'b0;
				en_pc = 1'b1;
				pc_ctrl = 2'b10;
				
				//选择R2
				reg_en = 4'b0010;
				//选择rd_q输入为R2 rs_q输入为R1
				
				//rs = 10;
				//选择alu_a = rd_q;alu_b = rs_q;
				alu_in_sel = 1'b1;
				//选择把alu_a+alu_b组作为输出
				alu_func = `AsubBH;
			end
		Execute_And: 
			begin
				en_fetch = 1'b0;
				en_rf = 1'b0;
				en_pc = 1'b1;
				pc_ctrl = 2'b10;
				
				//选择R2
				reg_en = 4'b0010;
				//选择rd_q输入为R2 rs_q输入为R1
			
				//rs = 10;
				//选择alu_a = rd_q;alu_b = rs_q;
				alu_in_sel = 1'b1;
				//选择把alu_a+alu_b组作为输出
				alu_func = `AandBH;
			end	
		Execute_Or: 
			begin
				en_fetch = 1'b0;
				en_rf = 1'b0;
				en_pc = 1'b1;
				pc_ctrl = 2'b10;
				
				//选择R2
				reg_en = 4'b0010;
				//选择rd_q输入为R2 rs_q输入为R1
				
				//rs = 10;
				//选择alu_a = rd_q;alu_b = rs_q;
				alu_in_sel = 1'b1;
				//选择把alu_a+alu_b组作为输出
				alu_func = `AorBH;
			end
		Execute_Leftshift: 
			begin
				en_fetch = 1'b0;
				en_rf = 1'b0;
				en_pc = 1'b1;
				pc_ctrl = 2'b10;
				
				//选择R1
				reg_en = 4'b0001;
				//选择rd_q输入为R2 rs_q输入为R1
				
				//选择alu_a = rd_q;alu_b = rs_q;
				alu_in_sel = 1'b1;
				//选择把alu_a+alu_b组作为输出
				alu_func = `AshflH;
			end
		Execute_Rightshift:
			begin
				en_fetch = 1'b0;
				en_rf = 1'b0;
				en_pc = 1'b1;
				pc_ctrl = 2'b10;
				
				//选择R1
				reg_en = 4'b0001;
				//选择rd_q输入为R2 rs_q输入为R1
				
				//选择alu_a = rd_q;alu_b = rs_q;
				alu_in_sel = 1'b1;
				//选择把alu_a+alu_b组作为输出
				alu_func = `AshfrH;
			end
		// 思考:为什么jump和Write_back的下一状态都为取指令
		//没懂JUMP #1是什么意思 就是让PC输出地址 00000001
		Execute_Jump: 
			begin
				en_fetch = 1'b0;
				en_rf = 1'b0;
				en_pc = 1'b1;
				pc_ctrl = 2'b10;
				
				reg_en = 4'b0000;
				alu_in_sel = 1'b0;
				alu_func = `B15to0H;
			end
		
		Write_back:
			// 回写是将运算结果存入寄存器，该状态需要设置的参数只有reg_en	??
			begin
				case(reg_en)
					4'b0001:en_rf = 1'b1;
					4'b0010:en_rf = 1'b1;
					4'b0100:en_rf = 1'b1;
					4'b1000:en_rf = 1'b1;
					4'b0000:en_rf = 1'b1;
					default:en_rf = 1'b0;
				endcase
			end
		default: 
			begin
				en_fetch = 1'b0;
				en_rf = 1'b0;
				en_rf = 1'b0;
				en_pc = 1'b0;
				pc_ctrl = 2'b00;
				reg_en = 4'b0000;
				alu_in_sel = 1'b0;
				alu_func = `B15to0H;
			end
		endcase
	end
end

// 下面时通过上升沿检测器来产生en_fetch_pulse，en_pc_pulse和en_rf_pulse，这些信号是各模块的输入使能
always @ (posedge clk or negedge rst) 
begin
	if(!rst) 
	begin
		en_fetch_reg <= 1'b0;
		en_pc_reg <= 1'b0;
		en_rf_reg <= 1'b0;
	end
	else 
	begin
		en_fetch_reg <= en_fetch;
		en_pc_reg <= en_pc;
		en_rf_reg <= en_rf;
	end
end
// 虽然en_fetch_pulse等信号是在这里产生的，但是在什么时候产生完全是在执行next_state是产生的
always @ (en_fetch or en_fetch_reg)
	en_fetch_pulse = en_fetch & (~en_fetch_reg);
	
always @ (en_pc_reg or en_pc)
	en_pc_pulse = en_pc & (~en_pc_reg);
	
always @ (en_rf_reg or en_rf)
	en_rf_pulse = en_rf & (~en_rf_reg);

endmodule




