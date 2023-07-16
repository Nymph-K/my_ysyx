/*************************************************************
 * @ name           : mul_shift_64clk.v
 * @ description    : Shift-Multiplier 64 clock/mul
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-5-19
*************************************************************/
`ifndef MUL_SHIFT_64_CLK_V
`define MUL_SHIFT_64_CLK_V

`define A_SIGN  mul_signed[1]
`define B_SIGN  mul_signed[0]

`define A_SIGNR  mul_signed_r[1]
`define B_SIGNR  mul_signed_r[0]
`define A_NEGAR  multiplicand_n
`define B_NEGAR  multiplier_n

module mul_shift_64clk (
    input                   clk          ,  
    input                   rst          ,  
    input                   mul_valid    ,
    input                   flush        ,  // cancel
    input                   mulw         ,  // 32 bit mul
    input       [ 1:0]      mul_signed   ,  // 2'b11 (signed x signed ) ;2’b10 (signed x unsigned ) ;2’b00 (unsigned x unsigned ) ;
    input       [63:0]      multiplicand ,  // multiplicand
    input       [63:0]      multiplier   ,  // multiplier
    output reg              mul_ready    ,  // ready for receive
    output reg              out_valid    ,  // result valid
    output      [63:0]      result_hi    ,  // high 64 bit result
    output      [63:0]      result_lo       // high 64 bit result
);

    reg                 multiplicand_n; // A
    reg                 multiplier_n;   // B sign
    reg [127:0]         shifter;        // 128 bit shifter
    reg  [64:0]         multiplicand_r;
    reg [1:0]           mul_signed_r;
    reg [0:0]           state;          // FSM state
    reg [6:0]           mul_cnt;
    reg                 mulw_r;
    wire [64:0]         alu_a;
    wire [64:0]         alu_b;
    wire [64:0]         alu_out;
    wire                mul_handshake;
    wire                cnt_max;

    localparam MUL_CNT_MAX = 6'd63;
    localparam FSM_IDLE = 1'd0,
               FSM_MUL = 1'd1;

    assign mul_handshake = mul_valid & mul_ready;
    assign cnt_max = (mul_cnt == MUL_CNT_MAX);

    assign alu_a = multiplicand_r;
    assign alu_b  = {`A_SIGNR ? shifter[127] : 1'b0 , shifter[127:64]};
    assign alu_out = (`B_NEGAR & cnt_max) ? (alu_b - alu_a) : (alu_b + alu_a);
    
    assign result_lo = mulw_r ? shifter[95:32] : shifter[63:0];
    assign result_hi = shifter[127:64];

    always @(posedge clk ) begin
        if (rst | flush) begin
            state <= FSM_IDLE;
        end else begin
            case (state)
                FSM_IDLE: begin
                    if(mul_handshake) state <= FSM_MUL;
                end
                FSM_MUL: begin
                    if (cnt_max) begin
                        state <= FSM_IDLE;
                    end
                end
                default: begin
                    state <= FSM_IDLE;
                end
            endcase
        end
    end

    always @(posedge clk ) begin
        if (rst | flush) begin
            shifter         <= 128'b0;
            multiplicand_n  <= 1'b0;
            multiplier_n    <= 1'b0;
            mul_cnt         <= 6'b0;
            mul_ready       <= 1'b0;
            out_valid       <= 1'b0;
            multiplicand_r  <= 65'b0;
        end else begin
            case (state)
                FSM_IDLE: begin
                    if (mul_handshake) begin
                        shifter         <= {64'b0, mulw ? {32'b0, multiplier[31:0]} : multiplier};
                        multiplicand_n  <= `A_SIGN & (mulw ? multiplicand[31] : multiplicand[63]);
                        multiplier_n    <= `B_SIGN & (mulw ? multiplier[31] : multiplier[63]);
                        mul_cnt         <= mulw ? 6'd32 : 6'd0;
                        mul_ready       <= 1'b0;
                        mulw_r          <= mulw;
                        mul_signed_r    <= mul_signed;
                        multiplicand_r  <= mulw ? {{33{`A_SIGN ? multiplicand[31] : 1'b0}}, multiplicand[31:0]} : {`A_SIGN ? multiplicand[63] : 1'b0, multiplicand[63:0]};
                    end else begin
                        mul_ready       <= 1'b1;
                    end
                    out_valid       <= 1'b0;
                end

                FSM_MUL: begin
                    shifter         <= {(shifter[0] ? alu_out : { `A_SIGNR ? shifter[127] : 1'b0 , shifter[127:64]}), shifter[63:1]};
                    mul_cnt         <= mul_cnt + 1;
                    if (cnt_max) begin
                        out_valid       <= 1'b1;
                    end
                end

                default: begin
                    shifter         <= 129'b0;
                    multiplicand_n  <= 1'b0;
                    multiplier_n    <= 1'b0;
                    mul_cnt         <= 6'b0;
                    mul_ready       <= 1'b0;
                    out_valid       <= 1'b0;
                end
            endcase
        end
    end

endmodule //mul_shift

`endif