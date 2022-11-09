module LFSR(
  input        clock,
  input        reset,
  input        io_en,
  input  [7:0] io_in,
  output [7:0] io_out
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  reg [7:0] result; // @[LFSR.scala 14:25]
  wire [7:0] _xorresult_T = result & 8'h1d; // @[LFSR.scala 16:30]
  wire  xorresult = ^_xorresult_T; // @[LFSR.scala 16:39]
  wire [8:0] _result_T = {xorresult,result}; // @[Cat.scala 31:58]
  assign io_out = result; // @[LFSR.scala 22:12]
  always @(posedge clock) begin
    if (reset) begin // @[LFSR.scala 14:25]
      result <= 8'h0; // @[LFSR.scala 14:25]
    end else if (io_en) begin // @[LFSR.scala 17:17]
      result <= io_in; // @[LFSR.scala 18:16]
    end else begin
      result <= _result_T[8:1]; // @[LFSR.scala 20:16]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  result = _RAND_0[7:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
