module mem_wb_reg (
	input           clk                     ,
	input           rst                     ,
    input           mem_idle                ,
    input           mem_lsu_r_ready         ,
    input           mem_lsu_r_valid         ,
    input           mem_lsu_w_valid         ,
    input           mem_lsu_w_ready         ,
    input  [63:0]   mem_lsu_r_data          ,
    input           in_valid                ,
    input  [31:0]   in_pc                   ,
    input  [31:0]   in_inst                 ,
    input  [ 4:0]   in_rs1                  ,
    input  [ 4:0]   in_rs2                  ,
    input  [63:0]   in_x_rs2                ,
    input  [63:0]   in_x_rd                 ,
    input  [ 4:0]   in_rd                   ,
    input           in_rd_idx_0             ,
    input           in_rd_w_en              ,
    input           in_rd_w_src_exu         ,
    input           in_rd_w_src_mem         ,
    input           in_rd_w_src_csr         ,
    input           in_csr_w_en             ,
    input  [11:0]   in_csr_addr             ,
    input  [63:0]   in_csr_r_data           ,
    input  [63:0]   in_exu_result           ,
    input           in_inst_system_ebreak   ,

    output              out_valid               ,
    output              out_ready               ,
    output reg [31:0]   out_pc                  ,
    output reg [31:0]   out_inst                ,
    output reg [ 4:0]   out_rs1                 ,
    output reg [ 4:0]   out_rs2                 ,
    output reg [63:0]   out_x_rs2               ,
    output     [63:0]   out_x_rd                ,
    output reg [ 4:0]   out_rd                  ,
    output reg          out_rd_idx_0            ,
    output reg          out_rd_w_en             ,
    output reg          out_rd_w_src_exu        ,
    output reg          out_rd_w_src_mem        ,
    output reg          out_rd_w_src_csr        ,
    output reg          out_csr_w_en            ,
    output reg [11:0]   out_csr_addr            ,
    output reg [63:0]   out_csr_r_data          ,
    output reg [63:0]   out_exu_result          ,
    output     [63:0]   out_lsu_r_data          ,
    output reg          out_lsu_r_ready         ,
    output              out_lsu_r_valid         ,
    output reg          out_inst_system_ebreak   
);

    reg [63:0] out_x_rd_;
    wire wen = in_valid & mem_idle; // TODO: wen = in_valid & (mem_idle | (~mem_idle & ~(mem_lsu_r_ready | mem_lsu_w_valid)))
    wire ctrl_flush = rst | (~in_valid & out_valid);
    assign out_ready = mem_idle; // TODO: (mem_idle | (~mem_idle & ~(mem_lsu_r_ready | mem_lsu_w_valid)))
    reg out_valid_r;

    localparam IDLE = 0; // not access mem
    localparam AMEM = 1; // access mem
    reg [0:0] fsm;

    assign out_valid = (fsm == IDLE) ? out_valid_r : mem_lsu_r_valid | mem_lsu_w_ready;
    assign out_x_rd = out_rd_w_src_mem ? mem_lsu_r_data : out_x_rd_;
    assign out_lsu_r_data = mem_lsu_r_data;
    assign out_lsu_r_valid = mem_lsu_r_valid;

    always @(posedge clk) begin
        if (rst) begin
            fsm <= IDLE;
        end else begin
            if (wen & (mem_lsu_r_ready | mem_lsu_w_valid)) fsm <= AMEM;
            else if(mem_lsu_r_valid | mem_lsu_w_ready) fsm <= IDLE;
        end
    end

    always @(posedge clk) begin
        if (ctrl_flush) begin
            out_valid_r         <= 0;
            out_lsu_r_ready     <= 0;
            out_rd_w_en         <= 0;
        end else begin
            out_valid_r <= wen;
            if(wen) begin
                out_lsu_r_ready     <= mem_lsu_r_ready;
                out_rd_w_en         <= in_rd_w_en;
            end
        end
    end

    always @(posedge clk ) begin
        if (rst) begin
                out_pc                  <= 0;
                out_inst                <= 0;
                out_rs1                 <= 0;
                out_rs2                 <= 0;
                out_x_rs2               <= 0;
                out_x_rd_               <= 0;
                out_rd                  <= 0;
                out_rd_idx_0            <= 0;
                out_rd_w_src_exu        <= 0;
                out_rd_w_src_mem        <= 0;
                out_rd_w_src_csr        <= 0;
                out_csr_w_en            <= 0;
                out_csr_addr            <= 0;
                out_csr_r_data          <= 0;
                out_exu_result          <= 0;
                out_inst_system_ebreak  <= 0;
        end else begin
            if(wen) begin
                out_pc                  <= in_pc;
                out_inst                <= in_inst;
                out_rs1                 <= in_rs1;
                out_rs2                 <= in_rs2;
                out_x_rs2               <= in_x_rs2;
                out_x_rd_               <= in_x_rd;
                out_rd                  <= in_rd;
                out_rd_idx_0            <= in_rd_idx_0;
                out_rd_w_src_exu        <= in_rd_w_src_exu;
                out_rd_w_src_mem        <= in_rd_w_src_mem;
                out_rd_w_src_csr        <= in_rd_w_src_csr;
                out_csr_w_en            <= in_csr_w_en;
                out_csr_addr            <= in_csr_addr;
                out_csr_r_data          <= in_csr_r_data;
                out_exu_result          <= in_exu_result;
                out_inst_system_ebreak  <= in_inst_system_ebreak;
            end
        end
    end




endmodule //mem_wb_reg

