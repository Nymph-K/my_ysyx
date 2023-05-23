/*************************************************************
 * @ name           : mul_shift_64clk.v
 * @ description    : Shift-Multiplier 64 clock/mul
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-5-19
*************************************************************/
`ifndef MUL_SHIFT_64_CLK_V
`define MUL_SHIFT_64_CLK_V

`define A_SIGN  mul_signed_r[1]
`define B_SIGN  mul_signed_r[0]
`define A_NEGA  (`A_SIGN & multiplicand_s )
`define B_NEGA  (`B_SIGN & multiplier_s )

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

    reg                 multiplicand_s; // A
    reg                 multiplier_s;   // B sign
    reg [1:0]           mul_signed_r;
    reg [127:0]         shifter;        // 128 bit shifter
    reg [0:0]           state;          // FSM state
    reg [6:0]           mul_cnt;
    reg                 mulw_r;
    reg  [64:0]         alu_a;
    wire [64:0]         alu_b;
    wire [64:0]         alu_aw;         // word
    wire [64:0]         alu_ad;         // double word
    wire [64:0]         alu_bw;
    wire [64:0]         alu_out;
    wire                mul_handshake;
    wire                cnt_max;

    localparam MUL_CNT_MAX = 6'd63;
    localparam FSM_IDLE = 1'd0,
               FSM_MUL = 1'd1;

    assign alu_aw = {32'b0, mul_signed[1] ? multiplicand[31] : 1'b0, multiplicand[31:0]};
    assign alu_ad = {mul_signed[1] ? multiplicand[63] : 1'b0, multiplicand[63:0]};

    assign alu_bw = {32'b0, `A_SIGN ? shifter[63] : 1'b0, shifter[63:32]};
    assign alu_b  = mulw_r ? alu_bw : {`A_SIGN ? shifter[127] : 1'b0, shifter[127:64]};
    assign alu_out = (`B_NEGA & cnt_max) ? (alu_b - alu_a) : (alu_a + alu_b);
    assign mul_handshake = mul_valid & mul_ready;
    assign {result_hi, result_lo} = shifter[127:0];
    assign cnt_max = (mul_cnt == MUL_CNT_MAX);

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
            multiplicand_s  <= 1'b0;
            multiplier_s    <= 1'b0;
            mul_cnt         <= 6'b0;
            mul_ready       <= 1'b0;
            out_valid       <= 1'b0;
            alu_a           <= 65'b0;
        end else begin
            case (state)
                FSM_IDLE: begin
                    if (mul_handshake) begin
                        shifter         <= mulw ? {96'b0, multiplier[31:0]} : {64'b0, multiplier};
                        multiplicand_s  <= mulw ? multiplicand[31] : multiplicand[63];
                        multiplier_s    <= mulw ? multiplier[31] : multiplier[63];
                        mul_signed_r    <= mul_signed;
                        mul_cnt         <= mulw ? 6'd32 : 6'd0;
                        mul_ready       <= 1'b0;
                        mulw_r          <= mulw;
                        alu_a           <= mulw ? alu_aw : alu_ad;
                    end else begin
                        mul_ready       <= 1'b1;
                    end
                    out_valid       <= 1'b0;
                end
                
                FSM_MUL: begin
                    shifter         <= mulw_r ? {64'b0, (shifter[0] ? alu_out[32:0] : { (`A_SIGN ? shifter[63] : 1'b0), shifter[63:32]}), shifter[31:1]}
                                              : {(shifter[0] ? alu_out : { (`A_SIGN ? shifter[127] : 1'b0), shifter[127:64]}), shifter[63:1]};
                    mul_cnt         <= mul_cnt + 1;
                    if (cnt_max) begin
                        out_valid       <= 1'b1;
                    end
                end

                default: begin
                    shifter         <= 129'b0;
                    multiplicand_s  <= 1'b0;
                    multiplier_s    <= 1'b0;
                    mul_cnt         <= 6'b0;
                    mul_ready       <= 1'b0;
                    out_valid       <= 1'b0;
                end
            endcase
        end
    end

endmodule //mul_shift

`endif