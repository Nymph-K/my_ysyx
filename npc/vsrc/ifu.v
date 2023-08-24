module ifu (
	input  clk,
	input  rst,
	input [31:0] pc,
	output [31:0] inst,
    output reg if_valid
);

    import "DPI-C" function void paddr_read(input longint raddr, output longint mem_r_data);

    reg [63:0] _;
    wire [31:0] pc_align = pc & 32'hFFFF_FFFC;

	always_latch @(*) begin
        if (~rst) begin
            paddr_read({32'b0, pc_align}, _);
        end
	end

    assign inst = pc[2] ? _[63:32] : _[31:0] ;

    always @(posedge clk) begin
        if(rst)
            if_valid <= 0;
        else
            if_valid <= ~if_valid;
    end
    
endmodule //ifu
