/*************************************************************
 * @ name           : mul_shift_0term.v
 * @ description    : Shift-Multiplier when 0 terminate
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-5-19
*************************************************************/
`ifndef MUL_SHIFT_0TERM_V
`define MUL_SHIFT_0TERM_V

`define A_SIGN  mul_signed_r[1]
`define B_SIGN  mul_signed_r[0]
`define A_NEGA  (`A_SIGN & multiplicand_s )
`define B_NEGA  (`B_SIGN & multiplier_s )
`define MUL_1   multiplier_r[0]

module mul_shift_0term (
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

    reg  [127:0]        multiplicand_r; // A
    reg  [63:0]         multiplier_r;   // B
    reg                 multiplicand_s; // A sign
    reg                 multiplier_s;   // B sign
    reg  [1:0]          mul_signed_r;
    reg  [127:0]        result;        // 128 bit result
    reg                 state;          // FSM state
    reg  [6:0]          mul_cnt;
    reg                 mulw_r;
    wire [127:0]        alu_a;
    wire [127:0]        alu_b;
    wire [127:0]        multiplicand_w;         // word
    wire [127:0]        multiplicand_d;         // double word
    wire [127:0]        alu_out;
    wire                mul_handshake;
    wire                cnt_max;
    wire                mul_zero;

    localparam MUL_CNT_MAX = 6'd63;
    localparam FSM_IDLE = 1'd0,
               FSM_MUL = 1'd1;

    assign multiplicand_w = {mul_signed[1] ? {96{multiplicand[31]}} : 96'b0, multiplicand[31:0]};
    assign multiplicand_d = {mul_signed[1] ? {64{multiplicand[63]}} : 64'b0, multiplicand[63:0]};
    assign alu_a = `MUL_1 ? multiplicand_r : 128'b0;
    assign alu_b = result;
    assign alu_out = (`B_NEGA & cnt_max) ? (alu_b - alu_a) : (alu_b + alu_a);
    assign mul_handshake = mul_valid & mul_ready;
    assign {result_hi, result_lo} = result;
    assign cnt_max = (mul_cnt == MUL_CNT_MAX);
    assign mul_zero = (multiplier_r == 64'b0);

    always @(posedge clk ) begin
        if (rst | flush) begin
            state <= FSM_IDLE;
        end else begin
            case (state)
                FSM_IDLE: begin
                    if(mul_handshake) state <= FSM_MUL;
                end
                FSM_MUL: begin
                    if (cnt_max | mul_zero) begin
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
            result          <= 128'b0;
            multiplicand_s  <= 1'b0;
            multiplier_s    <= 1'b0;
            multiplier_r    <= 64'b0;
            mul_cnt         <= 7'b0;
            mul_ready       <= 1'b0;
            out_valid       <= 1'b0;
            multiplicand_r  <= 65'b0;
        end else begin
            case (state)
                FSM_IDLE: begin
                    if (mul_handshake) begin
                        result          <= 128'b0;
                        multiplicand_r  <= mulw ? multiplicand_w : multiplicand_d;
                        multiplier_r    <= mulw ? {32'b0, multiplier[31:0]} : multiplier;
                        multiplicand_s  <= mulw ? multiplicand[31] : multiplicand[63];
                        multiplier_s    <= mulw ? multiplier[31] : multiplier[63];
                        mul_signed_r    <= mul_signed;
                        mul_cnt         <= mulw ? 6'd32 : 6'd0;
                        mul_ready       <= 1'b0;
                        mulw_r          <= mulw;
                    end else begin
                        mul_ready       <= 1'b1;
                    end
                    out_valid       <= 1'b0;
                end
                
                FSM_MUL: begin
                    result          <= alu_out;
                    multiplicand_r  <= multiplicand_r << 1;
                    mul_cnt         <= mul_cnt + 1;
                    multiplier_r    <= multiplier_r >> 1;
                    if (cnt_max | mul_zero) begin
                        out_valid       <= 1'b1;
                    end
                end

                default: begin
                    result          <= 128'b0;
                    multiplicand_s  <= 1'b0;
                    multiplier_s    <= 1'b0;
                    mul_cnt         <= 7'b0;
                    mul_ready       <= 1'b0;
                    out_valid       <= 1'b0;
                end
            endcase
        end
    end

endmodule //mul_shift_0term

`endif