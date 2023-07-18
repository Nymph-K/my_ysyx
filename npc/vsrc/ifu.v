module ifu (
	input  clk,
	input  rst,
	input [`HXLEN-1:0] pc,
	output [31:0] inst
);

    import "DPI-C" function void paddr_read(input longint raddr, output longint mem_r_data);

    reg [`XLEN-1:0] _;
    wire [`HXLEN-1:0] pc_align = pc & 32'hFFFF_FFFC;

	always_latch @(*) begin
        if (~rst) begin
            paddr_read({32'b0, pc_align}, _);
        end
	end

    assign inst = pc[2] ? _[`XLEN-1:`HXLEN] : _[`HXLEN-1:0] ;

endmodule //ifu