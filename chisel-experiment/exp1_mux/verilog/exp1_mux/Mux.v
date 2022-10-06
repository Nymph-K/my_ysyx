module Mux(
  input        clock,
  input        reset,
  input  [1:0] io_y,
  input  [1:0] io_x_0,
  input  [1:0] io_x_1,
  input  [1:0] io_x_2,
  input  [1:0] io_x_3,
  output [1:0] io_out
);
  wire [1:0] _GEN_1 = 2'h1 == io_y ? io_x_1 : io_x_0; // @[Mux.scala 11:{16,16}]
  wire [1:0] _GEN_2 = 2'h2 == io_y ? io_x_2 : _GEN_1; // @[Mux.scala 11:{16,16}]
  assign io_out = 2'h3 == io_y ? io_x_3 : _GEN_2; // @[Mux.scala 11:{16,16}]
endmodule
