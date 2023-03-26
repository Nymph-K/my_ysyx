/*************************************************************
 * @ name           : common.v
 * @ description    : option defines
 * @ use module     : none
 * @ author         : K
 * @ chnge date     : 2023-3-10
*************************************************************/
`ifndef COMMON_V
`define COMMON_V

/***************************代码规范***************************
 * 每个文件有一个文件头，注明文件名、功能描述、引用模块、设计者、设计时间、修改信息及版权信息等
 * 每个文件只包含一个module，module名要小写，并且与文件名保持一致
 * 推荐用parameter来定义有实际意义的常数，parameter大写
 * 信号名小写，名字中用下划线连接：module_fun，同一信号在不同层次应该保持一致性
 * module例化名用u_xx_x标示
 * 在顶层模块中，除了内部的互连和module的例化外，避免在做其他逻辑
 * 为逻辑升级保留的无用端口以及信号要注释
 * 除移位寄存器外，每个always语句只对一个变量赋值
 * if 都有else和它对应，case同理，禁止使用casex。条件表达式必须是判断（==, !=, <, >）
 * 对齐代码使用空格，而不是tab键
*************************************************************/

`define XLEN                64
`define DXLEN               128     //double XLEN
`define HXLEN               32     //half XLEN

`define START_ADDR          `XLEN'h80000000

`define EXTENSION_M         1

//`define CLINT_ENABLE      1           // CLINT timer

`ifdef  CLINT_ENABLE        /*  clint device addr  */
`define CLINT_MSIP_ADDR     `XLEN'h2000000
`define CLINT_MTIMECMP_ADDR `XLEN'h2004000
`define CLINT_MTIME_ADDR    `XLEN'h200BFF8
`endif

`define DPI_C_SET_GPR_PTR   1

`define FAST_SIMULATION     1

`define USE_IF_CASE         1           // use always if case
 
`ifndef USE_IF_CASE
`define USE_LUT_MUX         1           // use LUT Mux
`endif

//`define ADDR_ALIGN        1           // 8 Byte align

`define USE_AXI_IFU         1

`define USE_AXI_LSU         1

/*  rd src  */
`define RD_SRC_ALU 		      2'd0		//alu_result
`define RD_SRC_MEM 		      2'd1		//mem_data_out
`define RD_SRC_MDU 		      2'd2		//mdu_result
`define RD_SRC_CSR 		      2'd3		//csr_r_data

/*  alu control  */
`define ALU_CTRL_AOS		    3'b000//ADD or SUB
`define ALU_CTRL_SLL		    3'b001
`define ALU_CTRL_SLT		    3'b010
`define ALU_CTRL_SLTU	        3'b011
`define ALU_CTRL_XOR		    3'b100
`define ALU_CTRL_SR		        3'b101
`define ALU_CTRL_OR		        3'b110
`define ALU_CTRL_AND		    3'b111

/*  alu src1  */
`define ALU_SRC1_0 		      2'b00		//0
`define ALU_SRC1_XRS1 	      2'b01		//x_rs1
`define ALU_SRC1_PC 	      2'b10		//pc
`define ALU_SRC1_CSR 	      2'b11		//csr_alu_src1

/*  alu src2  */
`define ALU_SRC2_XRS2 	      2'b00		//x_rs2
`define ALU_SRC2_IMM 	      2'b01		//imm
`define ALU_SRC2_4   	      2'b10		//4
`define ALU_SRC2_CSR 	      2'b11		//csr_alu_src1

/*  pc src1  */
`define PC_SRC1_PC 	          1'b0		//pc
`define PC_SRC1_XRS1 	      1'b1		//x_rs1

/*  pc src1  */
`define PC_SRC2_4 	          1'b0		//4
`define PC_SRC2_IMM 	      1'b1		//imm

/*  opcode  */
`define LOAD			    7'b0000011		//LOAD
`define LOAD_FP			    7'b0000111		//LOAD-FP
`define CUSTOM_0		    7'b0001011		//custom-0
`define MISC_MEM		    7'b0001111		//MISC-MEM
`define OP_IMM			    7'b0010011		//OP-IMM
`define AUIPC			    7'b0010111		//AUIPC
`define OP_IMM_32		    7'b0011011		//OP-IMM-32
`define STORE			    7'b0100011		//STORE
`define STORE_FP		    7'b0100111		//STORE-FP
`define CUSTOM_1		    7'b0101011		//custom-1
`define AMO				    7'b0101111		//AMO
`define OP				    7'b0110011		//OP
`define LUI				    7'b0110111		//LUI
`define OP_32			    7'b0111011		//OP-32
`define MADD			    7'b1000011		//MADD
`define MSUB			    7'b1000111		//MSUB
`define NMSUB			    7'b1001011		//NMSUB
`define NMADD			    7'b1001111		//NMADD
`define OP_FP			    7'b1010011		//OP-FP
`define RESERVED_0		    7'b1010111		//reserved
`define CUSTOM_2		    7'b1011011		//custom-2/rv128
`define BRANCH			    7'b1100011		//BRANCH
`define JALR			    7'b1100111		//JALR
`define RESERVED_1		    7'b1101011		//reserved
`define JAL				    7'b1101111		//JAL
`define SYSTEM			    7'b1110011		//SYSTEM
`define RESERVED_2		    7'b1110111		//reserved
`define CUSTOM_3		    7'b1111011		//custom-3/rv128

/*  funct3  */
//BRANCH
`define BEQ		            3'b000
`define BNE		            3'b001
`define BLT		            3'b100
`define BGE		            3'b101
`define BLTU	            3'b110
`define BGEU	            3'b111
//LOAD
`define LB		            3'b000
`define LH		            3'b001
`define LW		            3'b010
`define LBU		            3'b100
`define LHU		            3'b101
`define LWU		            3'b110
`define LD		            3'b011
//STORE
`define SB		            3'b000
`define SH		            3'b001
`define SW		            3'b010
`define SD		            3'b011
//OP-IMM
`define ADDI	            3'b000
`define SLTI	            3'b010
`define SLTIU	            3'b011
`define XORI	            3'b100
`define ORI		            3'b110
`define ANDI	            3'b111
`define SLLI	            3'b001
`define SRLI	            3'b101//same0
`define SRAI	            3'b101//same0
//OP_IMM_32
`define ADDIW	            3'b000
`define SLLIW	            3'b001
`define SRLIW	            3'b101//same1
`define SRAIW	            3'b101//same1
//OP_32
`define ADDW	            3'b000//same2
`define SUBW	            3'b000//same2
`define SLLW	            3'b001
`define SRLW	            3'b101//same3
`define SRAW	            3'b101//same3
//OP
`define ADD		            3'b000//same4
`define SUB		            3'b000//same4
`define SLL		            3'b001
`define SLT		            3'b010
`define SLTU	            3'b011
`define XOR		            3'b100
`define SRL		            3'b101//same5
`define SRA		            3'b101//same5
`define OR		            3'b110
`define AND		            3'b111
//MISC-MEM
`define FENCE	            3'b000
`define FENCEI	            3'b001
//SYSTEM
`define ECALL	            3'b000
`define EBREAK	            3'b000
`define MRET	            3'b000
`define CSRRW	            3'b001
`define CSRRS	            3'b010
`define CSRRC	            3'b011
`define CSRRWI	            3'b101
`define CSRRSI	            3'b110
`define CSRRCI	            3'b111

`ifdef EXTENSION_M
//OP
`define MUL		            3'b000
`define MULH	            3'b001
`define MULHSU	            3'b010
`define MULHU	            3'b011
`define DIV		            3'b100
`define DIVU	            3'b101
`define REM		            3'b110
`define REMU	            3'b111
//OP_32
`define MULW	            3'b000
`define DIVW	            3'b100
`define DIVUW	            3'b101
`define REMW	            3'b110
`define REMUW	            3'b111
`endif


`define INST_EBREAK         32'b00000000000100000000000001110011
`define INST_ECALL          32'b00000000000000000000000001110011
`define INST_MRET           32'b00110000001000000000000001110011

`endif //COMMON_V