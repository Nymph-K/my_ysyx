module Num2seg(
  input  [3:0] io_in,
  output [7:0] io_out
);
  wire [7:0] _GEN_1 = 4'h1 == io_in ? 8'h9f : 8'h3; // @[Num2seg.scala 28:{16,16}]
  wire [7:0] _GEN_2 = 4'h2 == io_in ? 8'h25 : _GEN_1; // @[Num2seg.scala 28:{16,16}]
  wire [7:0] _GEN_3 = 4'h3 == io_in ? 8'hd : _GEN_2; // @[Num2seg.scala 28:{16,16}]
  wire [7:0] _GEN_4 = 4'h4 == io_in ? 8'h99 : _GEN_3; // @[Num2seg.scala 28:{16,16}]
  wire [7:0] _GEN_5 = 4'h5 == io_in ? 8'h49 : _GEN_4; // @[Num2seg.scala 28:{16,16}]
  wire [7:0] _GEN_6 = 4'h6 == io_in ? 8'h41 : _GEN_5; // @[Num2seg.scala 28:{16,16}]
  wire [7:0] _GEN_7 = 4'h7 == io_in ? 8'h1f : _GEN_6; // @[Num2seg.scala 28:{16,16}]
  wire [7:0] _GEN_8 = 4'h8 == io_in ? 8'h1 : _GEN_7; // @[Num2seg.scala 28:{16,16}]
  wire [7:0] _GEN_9 = 4'h9 == io_in ? 8'h9 : _GEN_8; // @[Num2seg.scala 28:{16,16}]
  wire [7:0] _GEN_10 = 4'ha == io_in ? 8'h11 : _GEN_9; // @[Num2seg.scala 28:{16,16}]
  wire [7:0] _GEN_11 = 4'hb == io_in ? 8'hc1 : _GEN_10; // @[Num2seg.scala 28:{16,16}]
  wire [7:0] _GEN_12 = 4'hc == io_in ? 8'h63 : _GEN_11; // @[Num2seg.scala 28:{16,16}]
  wire [7:0] _GEN_13 = 4'hd == io_in ? 8'h85 : _GEN_12; // @[Num2seg.scala 28:{16,16}]
  wire [7:0] _GEN_14 = 4'he == io_in ? 8'h61 : _GEN_13; // @[Num2seg.scala 28:{16,16}]
  assign io_out = 4'hf == io_in ? 8'h71 : _GEN_14; // @[Num2seg.scala 28:{16,16}]
endmodule
module Coder83(
  input        clock,
  input        reset,
  input        io_en,
  input  [7:0] io_in,
  output       io_out_z,
  output [2:0] io_out_led,
  output [7:0] io_out_seg
);
  wire [3:0] num2seg_io_in; // @[Coder83.scala 15:29]
  wire [7:0] num2seg_io_out; // @[Coder83.scala 15:29]
  wire  _T = io_in == 8'h0; // @[Coder83.scala 19:28]
  wire [7:0] _GEN_5 = {{4'd0}, io_in[7:4]}; // @[Bitwise.scala 105:31]
  wire [7:0] _io_out_led_T_3 = _GEN_5 & 8'hf; // @[Bitwise.scala 105:31]
  wire [7:0] _io_out_led_T_5 = {io_in[3:0], 4'h0}; // @[Bitwise.scala 105:70]
  wire [7:0] _io_out_led_T_7 = _io_out_led_T_5 & 8'hf0; // @[Bitwise.scala 105:80]
  wire [7:0] _io_out_led_T_8 = _io_out_led_T_3 | _io_out_led_T_7; // @[Bitwise.scala 105:39]
  wire [7:0] _GEN_6 = {{2'd0}, _io_out_led_T_8[7:2]}; // @[Bitwise.scala 105:31]
  wire [7:0] _io_out_led_T_13 = _GEN_6 & 8'h33; // @[Bitwise.scala 105:31]
  wire [7:0] _io_out_led_T_15 = {_io_out_led_T_8[5:0], 2'h0}; // @[Bitwise.scala 105:70]
  wire [7:0] _io_out_led_T_17 = _io_out_led_T_15 & 8'hcc; // @[Bitwise.scala 105:80]
  wire [7:0] _io_out_led_T_18 = _io_out_led_T_13 | _io_out_led_T_17; // @[Bitwise.scala 105:39]
  wire [7:0] _GEN_7 = {{1'd0}, _io_out_led_T_18[7:1]}; // @[Bitwise.scala 105:31]
  wire [7:0] _io_out_led_T_23 = _GEN_7 & 8'h55; // @[Bitwise.scala 105:31]
  wire [7:0] _io_out_led_T_25 = {_io_out_led_T_18[6:0], 1'h0}; // @[Bitwise.scala 105:70]
  wire [7:0] _io_out_led_T_27 = _io_out_led_T_25 & 8'haa; // @[Bitwise.scala 105:80]
  wire [7:0] _io_out_led_T_28 = _io_out_led_T_23 | _io_out_led_T_27; // @[Bitwise.scala 105:39]
  wire [2:0] _io_out_led_T_37 = _io_out_led_T_28[6] ? 3'h6 : 3'h7; // @[Mux.scala 47:70]
  wire [2:0] _io_out_led_T_38 = _io_out_led_T_28[5] ? 3'h5 : _io_out_led_T_37; // @[Mux.scala 47:70]
  wire [2:0] _io_out_led_T_39 = _io_out_led_T_28[4] ? 3'h4 : _io_out_led_T_38; // @[Mux.scala 47:70]
  wire [2:0] _io_out_led_T_40 = _io_out_led_T_28[3] ? 3'h3 : _io_out_led_T_39; // @[Mux.scala 47:70]
  wire [2:0] _io_out_led_T_41 = _io_out_led_T_28[2] ? 3'h2 : _io_out_led_T_40; // @[Mux.scala 47:70]
  wire [2:0] _io_out_led_T_42 = _io_out_led_T_28[1] ? 3'h1 : _io_out_led_T_41; // @[Mux.scala 47:70]
  wire [2:0] _io_out_led_T_43 = _io_out_led_T_28[0] ? 3'h0 : _io_out_led_T_42; // @[Mux.scala 47:70]
  wire [2:0] _io_out_led_T_45 = 3'h7 - _io_out_led_T_43; // @[Coder83.scala 24:43]
  wire [2:0] _GEN_1 = io_in == 8'h0 ? 3'h0 : _io_out_led_T_45; // @[Coder83.scala 19:37 21:36 24:36]
  Num2seg num2seg ( // @[Coder83.scala 15:29]
    .io_in(num2seg_io_in),
    .io_out(num2seg_io_out)
  );
  assign io_out_z = io_en & _T; // @[Coder83.scala 18:21 28:34]
  assign io_out_led = io_en ? _GEN_1 : 3'h0; // @[Coder83.scala 18:21 29:36]
  assign io_out_seg = io_en ? num2seg_io_out : 8'hff; // @[Coder83.scala 18:21 26:28 30:36]
  assign num2seg_io_in = {{1'd0}, io_out_led}; // @[Coder83.scala 16:23]
endmodule
