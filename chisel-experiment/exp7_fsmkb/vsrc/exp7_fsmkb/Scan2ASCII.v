module KBDREC(
  input        clock,
  input        reset,
  input        io_ps2_clk,
  input        io_ps2_data,
  input        io_data_ready,
  output       io_data_valid,
  output [7:0] io_data_bits
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
`endif // RANDOMIZE_REG_INIT
  reg [2:0] ps2_clk_delay; // @[FSMKB.scala 13:32]
  wire [2:0] _ps2_clk_delay_T_1 = {ps2_clk_delay[1:0],io_ps2_clk}; // @[Cat.scala 31:58]
  wire  ps2_clk_negedge = ~ps2_clk_delay[1] & ps2_clk_delay[2]; // @[FSMKB.scala 16:42]
  reg  valid; // @[FSMKB.scala 18:24]
  reg [3:0] bit_cnt; // @[FSMKB.scala 20:26]
  reg [9:0] bit_buffer; // @[FSMKB.scala 21:29]
  reg [7:0] data_fifo_0; // @[FSMKB.scala 22:28]
  reg [7:0] data_fifo_1; // @[FSMKB.scala 22:28]
  reg [7:0] data_fifo_2; // @[FSMKB.scala 22:28]
  reg [7:0] data_fifo_3; // @[FSMKB.scala 22:28]
  reg [7:0] data_fifo_4; // @[FSMKB.scala 22:28]
  reg [7:0] data_fifo_5; // @[FSMKB.scala 22:28]
  reg [7:0] data_fifo_6; // @[FSMKB.scala 22:28]
  reg [7:0] data_fifo_7; // @[FSMKB.scala 22:28]
  reg [2:0] rptr; // @[FSMKB.scala 24:23]
  reg [2:0] wptr; // @[FSMKB.scala 25:23]
  wire [7:0] _GEN_0 = 3'h0 == wptr ? bit_buffer[8:1] : data_fifo_0; // @[FSMKB.scala 22:28 31:{33,33}]
  wire [7:0] _GEN_1 = 3'h1 == wptr ? bit_buffer[8:1] : data_fifo_1; // @[FSMKB.scala 22:28 31:{33,33}]
  wire [7:0] _GEN_2 = 3'h2 == wptr ? bit_buffer[8:1] : data_fifo_2; // @[FSMKB.scala 22:28 31:{33,33}]
  wire [7:0] _GEN_3 = 3'h3 == wptr ? bit_buffer[8:1] : data_fifo_3; // @[FSMKB.scala 22:28 31:{33,33}]
  wire [7:0] _GEN_4 = 3'h4 == wptr ? bit_buffer[8:1] : data_fifo_4; // @[FSMKB.scala 22:28 31:{33,33}]
  wire [7:0] _GEN_5 = 3'h5 == wptr ? bit_buffer[8:1] : data_fifo_5; // @[FSMKB.scala 22:28 31:{33,33}]
  wire [7:0] _GEN_6 = 3'h6 == wptr ? bit_buffer[8:1] : data_fifo_6; // @[FSMKB.scala 22:28 31:{33,33}]
  wire [7:0] _GEN_7 = 3'h7 == wptr ? bit_buffer[8:1] : data_fifo_7; // @[FSMKB.scala 22:28 31:{33,33}]
  wire [2:0] _wptr_T_1 = wptr + 3'h1; // @[FSMKB.scala 32:30]
  wire  _GEN_8 = ~bit_buffer[0] & io_ps2_data & ^bit_buffer[9:1] | valid; // @[FSMKB.scala 29:89 30:23 18:24]
  wire [3:0] _bit_cnt_T_1 = bit_cnt + 4'h1; // @[FSMKB.scala 35:32]
  wire [9:0] _bit_buffer_T_1 = {io_ps2_data,bit_buffer[9:1]}; // @[Cat.scala 31:58]
  wire [2:0] _rptr_T_1 = rptr + 3'h1; // @[FSMKB.scala 40:22]
  wire [7:0] _GEN_45 = 3'h1 == rptr ? data_fifo_1 : data_fifo_0; // @[FSMKB.scala 43:{18,18}]
  wire [7:0] _GEN_46 = 3'h2 == rptr ? data_fifo_2 : _GEN_45; // @[FSMKB.scala 43:{18,18}]
  wire [7:0] _GEN_47 = 3'h3 == rptr ? data_fifo_3 : _GEN_46; // @[FSMKB.scala 43:{18,18}]
  wire [7:0] _GEN_48 = 3'h4 == rptr ? data_fifo_4 : _GEN_47; // @[FSMKB.scala 43:{18,18}]
  wire [7:0] _GEN_49 = 3'h5 == rptr ? data_fifo_5 : _GEN_48; // @[FSMKB.scala 43:{18,18}]
  wire [7:0] _GEN_50 = 3'h6 == rptr ? data_fifo_6 : _GEN_49; // @[FSMKB.scala 43:{18,18}]
  assign io_data_valid = valid; // @[FSMKB.scala 19:19]
  assign io_data_bits = 3'h7 == rptr ? data_fifo_7 : _GEN_50; // @[FSMKB.scala 43:{18,18}]
  always @(posedge clock) begin
    if (reset) begin // @[FSMKB.scala 13:32]
      ps2_clk_delay <= 3'h0; // @[FSMKB.scala 13:32]
    end else begin
      ps2_clk_delay <= _ps2_clk_delay_T_1; // @[FSMKB.scala 14:19]
    end
    if (reset) begin // @[FSMKB.scala 18:24]
      valid <= 1'h0; // @[FSMKB.scala 18:24]
    end else if (valid & io_data_ready) begin // @[FSMKB.scala 39:33]
      valid <= ~(_rptr_T_1 == wptr); // @[FSMKB.scala 41:15]
    end else if (ps2_clk_negedge) begin // @[FSMKB.scala 26:35]
      if (bit_cnt == 4'ha) begin // @[FSMKB.scala 27:32]
        valid <= _GEN_8;
      end
    end
    if (reset) begin // @[FSMKB.scala 20:26]
      bit_cnt <= 4'h0; // @[FSMKB.scala 20:26]
    end else if (ps2_clk_negedge) begin // @[FSMKB.scala 26:35]
      if (bit_cnt == 4'ha) begin // @[FSMKB.scala 27:32]
        bit_cnt <= 4'h0; // @[FSMKB.scala 28:21]
      end else begin
        bit_cnt <= _bit_cnt_T_1; // @[FSMKB.scala 35:21]
      end
    end
    if (reset) begin // @[FSMKB.scala 21:29]
      bit_buffer <= 10'h0; // @[FSMKB.scala 21:29]
    end else if (ps2_clk_negedge) begin // @[FSMKB.scala 26:35]
      if (!(bit_cnt == 4'ha)) begin // @[FSMKB.scala 27:32]
        bit_buffer <= _bit_buffer_T_1; // @[FSMKB.scala 36:24]
      end
    end
    if (reset) begin // @[FSMKB.scala 22:28]
      data_fifo_0 <= 8'h0; // @[FSMKB.scala 22:28]
    end else if (ps2_clk_negedge) begin // @[FSMKB.scala 26:35]
      if (bit_cnt == 4'ha) begin // @[FSMKB.scala 27:32]
        if (~bit_buffer[0] & io_ps2_data & ^bit_buffer[9:1]) begin // @[FSMKB.scala 29:89]
          data_fifo_0 <= _GEN_0;
        end
      end
    end
    if (reset) begin // @[FSMKB.scala 22:28]
      data_fifo_1 <= 8'h0; // @[FSMKB.scala 22:28]
    end else if (ps2_clk_negedge) begin // @[FSMKB.scala 26:35]
      if (bit_cnt == 4'ha) begin // @[FSMKB.scala 27:32]
        if (~bit_buffer[0] & io_ps2_data & ^bit_buffer[9:1]) begin // @[FSMKB.scala 29:89]
          data_fifo_1 <= _GEN_1;
        end
      end
    end
    if (reset) begin // @[FSMKB.scala 22:28]
      data_fifo_2 <= 8'h0; // @[FSMKB.scala 22:28]
    end else if (ps2_clk_negedge) begin // @[FSMKB.scala 26:35]
      if (bit_cnt == 4'ha) begin // @[FSMKB.scala 27:32]
        if (~bit_buffer[0] & io_ps2_data & ^bit_buffer[9:1]) begin // @[FSMKB.scala 29:89]
          data_fifo_2 <= _GEN_2;
        end
      end
    end
    if (reset) begin // @[FSMKB.scala 22:28]
      data_fifo_3 <= 8'h0; // @[FSMKB.scala 22:28]
    end else if (ps2_clk_negedge) begin // @[FSMKB.scala 26:35]
      if (bit_cnt == 4'ha) begin // @[FSMKB.scala 27:32]
        if (~bit_buffer[0] & io_ps2_data & ^bit_buffer[9:1]) begin // @[FSMKB.scala 29:89]
          data_fifo_3 <= _GEN_3;
        end
      end
    end
    if (reset) begin // @[FSMKB.scala 22:28]
      data_fifo_4 <= 8'h0; // @[FSMKB.scala 22:28]
    end else if (ps2_clk_negedge) begin // @[FSMKB.scala 26:35]
      if (bit_cnt == 4'ha) begin // @[FSMKB.scala 27:32]
        if (~bit_buffer[0] & io_ps2_data & ^bit_buffer[9:1]) begin // @[FSMKB.scala 29:89]
          data_fifo_4 <= _GEN_4;
        end
      end
    end
    if (reset) begin // @[FSMKB.scala 22:28]
      data_fifo_5 <= 8'h0; // @[FSMKB.scala 22:28]
    end else if (ps2_clk_negedge) begin // @[FSMKB.scala 26:35]
      if (bit_cnt == 4'ha) begin // @[FSMKB.scala 27:32]
        if (~bit_buffer[0] & io_ps2_data & ^bit_buffer[9:1]) begin // @[FSMKB.scala 29:89]
          data_fifo_5 <= _GEN_5;
        end
      end
    end
    if (reset) begin // @[FSMKB.scala 22:28]
      data_fifo_6 <= 8'h0; // @[FSMKB.scala 22:28]
    end else if (ps2_clk_negedge) begin // @[FSMKB.scala 26:35]
      if (bit_cnt == 4'ha) begin // @[FSMKB.scala 27:32]
        if (~bit_buffer[0] & io_ps2_data & ^bit_buffer[9:1]) begin // @[FSMKB.scala 29:89]
          data_fifo_6 <= _GEN_6;
        end
      end
    end
    if (reset) begin // @[FSMKB.scala 22:28]
      data_fifo_7 <= 8'h0; // @[FSMKB.scala 22:28]
    end else if (ps2_clk_negedge) begin // @[FSMKB.scala 26:35]
      if (bit_cnt == 4'ha) begin // @[FSMKB.scala 27:32]
        if (~bit_buffer[0] & io_ps2_data & ^bit_buffer[9:1]) begin // @[FSMKB.scala 29:89]
          data_fifo_7 <= _GEN_7;
        end
      end
    end
    if (reset) begin // @[FSMKB.scala 24:23]
      rptr <= 3'h0; // @[FSMKB.scala 24:23]
    end else if (valid & io_data_ready) begin // @[FSMKB.scala 39:33]
      rptr <= _rptr_T_1; // @[FSMKB.scala 40:14]
    end
    if (reset) begin // @[FSMKB.scala 25:23]
      wptr <= 3'h0; // @[FSMKB.scala 25:23]
    end else if (ps2_clk_negedge) begin // @[FSMKB.scala 26:35]
      if (bit_cnt == 4'ha) begin // @[FSMKB.scala 27:32]
        if (~bit_buffer[0] & io_ps2_data & ^bit_buffer[9:1]) begin // @[FSMKB.scala 29:89]
          wptr <= _wptr_T_1; // @[FSMKB.scala 32:22]
        end
      end
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
  ps2_clk_delay = _RAND_0[2:0];
  _RAND_1 = {1{`RANDOM}};
  valid = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  bit_cnt = _RAND_2[3:0];
  _RAND_3 = {1{`RANDOM}};
  bit_buffer = _RAND_3[9:0];
  _RAND_4 = {1{`RANDOM}};
  data_fifo_0 = _RAND_4[7:0];
  _RAND_5 = {1{`RANDOM}};
  data_fifo_1 = _RAND_5[7:0];
  _RAND_6 = {1{`RANDOM}};
  data_fifo_2 = _RAND_6[7:0];
  _RAND_7 = {1{`RANDOM}};
  data_fifo_3 = _RAND_7[7:0];
  _RAND_8 = {1{`RANDOM}};
  data_fifo_4 = _RAND_8[7:0];
  _RAND_9 = {1{`RANDOM}};
  data_fifo_5 = _RAND_9[7:0];
  _RAND_10 = {1{`RANDOM}};
  data_fifo_6 = _RAND_10[7:0];
  _RAND_11 = {1{`RANDOM}};
  data_fifo_7 = _RAND_11[7:0];
  _RAND_12 = {1{`RANDOM}};
  rptr = _RAND_12[2:0];
  _RAND_13 = {1{`RANDOM}};
  wptr = _RAND_13[2:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module FSMKB(
  input         clock,
  input         reset,
  input         io_ps2_clk,
  input         io_ps2_data,
  output        io_key_bits_push,
  output        io_key_bits_release,
  output        io_key_bits_same,
  output [1:0]  io_key_bits_cnt,
  output [15:0] io_key_bits_scancode_0,
  output [15:0] io_key_bits_scancode_1,
  output [15:0] io_key_bits_scancode_2,
  output [15:0] io_key_bits_scancode_3
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
`endif // RANDOMIZE_REG_INIT
  wire  kbdrec_clock; // @[FSMKB.scala 90:24]
  wire  kbdrec_reset; // @[FSMKB.scala 90:24]
  wire  kbdrec_io_ps2_clk; // @[FSMKB.scala 90:24]
  wire  kbdrec_io_ps2_data; // @[FSMKB.scala 90:24]
  wire  kbdrec_io_data_ready; // @[FSMKB.scala 90:24]
  wire  kbdrec_io_data_valid; // @[FSMKB.scala 90:24]
  wire [7:0] kbdrec_io_data_bits; // @[FSMKB.scala 90:24]
  reg [2:0] cs; // @[FSMKB.scala 70:21]
  reg  key_push; // @[FSMKB.scala 71:27]
  reg  key_release; // @[FSMKB.scala 72:30]
  reg  key_same; // @[FSMKB.scala 73:27]
  reg [15:0] key_buffer_0; // @[FSMKB.scala 75:25]
  reg [15:0] key_buffer_1; // @[FSMKB.scala 75:25]
  reg [15:0] key_buffer_2; // @[FSMKB.scala 75:25]
  reg [15:0] key_buffer_3; // @[FSMKB.scala 75:25]
  reg [1:0] key_cnt; // @[FSMKB.scala 76:26]
  wire  _buffer_full_T_1 = key_cnt == 2'h0; // @[FSMKB.scala 86:53]
  wire  buffer_full = cs == 3'h3 & key_cnt == 2'h0; // @[FSMKB.scala 86:41]
  wire  _T = 3'h0 == cs; // @[FSMKB.scala 105:20]
  wire [2:0] _GEN_0 = kbdrec_io_data_bits != 8'he0 ? 3'h1 : 3'h2; // @[FSMKB.scala 107:54 108:24 110:24]
  wire  _T_2 = 3'h1 == cs; // @[FSMKB.scala 105:20]
  wire  _T_3 = kbdrec_io_data_bits == 8'hf0; // @[FSMKB.scala 114:42]
  wire  _T_4 = kbdrec_io_data_bits == 8'he0; // @[FSMKB.scala 116:48]
  wire [15:0] _T_5 = {8'h0,kbdrec_io_data_bits}; // @[Cat.scala 31:58]
  wire [1:0] _T_7 = key_cnt - 2'h1; // @[FSMKB.scala 118:86]
  wire [15:0] _GEN_2 = 2'h1 == _T_7 ? key_buffer_1 : key_buffer_0; // @[FSMKB.scala 118:{63,63}]
  wire [15:0] _GEN_3 = 2'h2 == _T_7 ? key_buffer_2 : _GEN_2; // @[FSMKB.scala 118:{63,63}]
  wire [15:0] _GEN_4 = 2'h3 == _T_7 ? key_buffer_3 : _GEN_3; // @[FSMKB.scala 118:{63,63}]
  wire  _T_8 = _T_5 != _GEN_4; // @[FSMKB.scala 118:63]
  wire [2:0] _GEN_5 = _T_5 != _GEN_4 ? 3'h3 : 3'h1; // @[FSMKB.scala 118:94 119:24 121:24]
  wire [2:0] _GEN_6 = kbdrec_io_data_bits == 8'he0 ? 3'h2 : _GEN_5; // @[FSMKB.scala 116:60 117:24]
  wire [2:0] _GEN_7 = kbdrec_io_data_bits == 8'hf0 ? 3'h4 : _GEN_6; // @[FSMKB.scala 114:54 115:24]
  wire  _T_9 = 3'h2 == cs; // @[FSMKB.scala 105:20]
  wire [2:0] _GEN_8 = _buffer_full_T_1 ? 3'h1 : 3'h3; // @[FSMKB.scala 127:45 128:24 130:24]
  wire [2:0] _GEN_9 = _T_3 ? 3'h5 : _GEN_8; // @[FSMKB.scala 125:54 126:24]
  wire  _T_12 = 3'h3 == cs; // @[FSMKB.scala 105:20]
  wire [2:0] _GEN_15 = _T_4 ? 3'h2 : 3'h3; // @[FSMKB.scala 136:60 137:24]
  wire [2:0] _GEN_16 = _T_3 ? 3'h4 : _GEN_15; // @[FSMKB.scala 134:54 135:24]
  wire  _T_19 = 3'h4 == cs; // @[FSMKB.scala 105:20]
  wire  _T_22 = key_cnt == 2'h3; // @[FSMKB.scala 149:36]
  wire [2:0] _GEN_18 = key_cnt == 2'h2 ? 3'h1 : 3'h3; // @[FSMKB.scala 147:45 148:24]
  wire [2:0] _GEN_19 = key_cnt == 2'h1 ? 3'h0 : _GEN_18; // @[FSMKB.scala 145:39 146:24]
  wire  _T_23 = 3'h5 == cs; // @[FSMKB.scala 105:20]
  wire [2:0] _GEN_23 = 3'h5 == cs ? _GEN_19 : 3'h0; // @[FSMKB.scala 105:20]
  wire [2:0] _GEN_24 = 3'h4 == cs ? _GEN_19 : _GEN_23; // @[FSMKB.scala 105:20]
  wire [2:0] _GEN_25 = 3'h3 == cs ? _GEN_16 : _GEN_24; // @[FSMKB.scala 105:20]
  wire [2:0] _GEN_26 = 3'h2 == cs ? _GEN_9 : _GEN_25; // @[FSMKB.scala 105:20]
  wire [2:0] _GEN_27 = 3'h1 == cs ? _GEN_7 : _GEN_26; // @[FSMKB.scala 105:20]
  wire [2:0] _GEN_28 = 3'h0 == cs ? _GEN_0 : _GEN_27; // @[FSMKB.scala 105:20]
  wire [2:0] ns = kbdrec_io_data_valid ? _GEN_28 : cs; // @[FSMKB.scala 104:32 168:12]
  wire  _T_28 = ns == 3'h1; // @[FSMKB.scala 173:21]
  wire [15:0] _GEN_30 = 2'h0 == key_cnt ? _T_5 : key_buffer_0; // @[FSMKB.scala 177:{37,37} 75:25]
  wire [15:0] _GEN_31 = 2'h1 == key_cnt ? _T_5 : key_buffer_1; // @[FSMKB.scala 177:{37,37} 75:25]
  wire [15:0] _GEN_32 = 2'h2 == key_cnt ? _T_5 : key_buffer_2; // @[FSMKB.scala 177:{37,37} 75:25]
  wire [15:0] _GEN_33 = 2'h3 == key_cnt ? _T_5 : key_buffer_3; // @[FSMKB.scala 177:{37,37} 75:25]
  wire [1:0] _key_cnt_T_1 = key_cnt + 2'h1; // @[FSMKB.scala 178:36]
  wire  _T_30 = ns == 3'h3; // @[FSMKB.scala 186:21]
  wire  _T_32 = kbdrec_io_data_valid & _T_28; // @[FSMKB.scala 192:45]
  wire  _GEN_47 = ns == 3'h3 | _T_32; // @[FSMKB.scala 186:38 187:26]
  wire [15:0] _key_buffer_T_2 = {8'he0,kbdrec_io_data_bits}; // @[Cat.scala 31:58]
  wire [15:0] _GEN_55 = 2'h0 == key_cnt ? _key_buffer_T_2 : key_buffer_0; // @[FSMKB.scala 208:{37,37} 75:25]
  wire [15:0] _GEN_56 = 2'h1 == key_cnt ? _key_buffer_T_2 : key_buffer_1; // @[FSMKB.scala 208:{37,37} 75:25]
  wire [15:0] _GEN_57 = 2'h2 == key_cnt ? _key_buffer_T_2 : key_buffer_2; // @[FSMKB.scala 208:{37,37} 75:25]
  wire [15:0] _GEN_58 = 2'h3 == key_cnt ? _key_buffer_T_2 : key_buffer_3; // @[FSMKB.scala 208:{37,37} 75:25]
  wire  _GEN_67 = _key_buffer_T_2 != _GEN_4 ? 1'h0 : 1'h1; // @[FSMKB.scala 212:91 213:30 217:30]
  wire [15:0] _GEN_68 = _key_buffer_T_2 != _GEN_4 ? _GEN_55 : key_buffer_0; // @[FSMKB.scala 212:91 75:25]
  wire [15:0] _GEN_69 = _key_buffer_T_2 != _GEN_4 ? _GEN_56 : key_buffer_1; // @[FSMKB.scala 212:91 75:25]
  wire [15:0] _GEN_70 = _key_buffer_T_2 != _GEN_4 ? _GEN_57 : key_buffer_2; // @[FSMKB.scala 212:91 75:25]
  wire [15:0] _GEN_71 = _key_buffer_T_2 != _GEN_4 ? _GEN_58 : key_buffer_3; // @[FSMKB.scala 212:91 75:25]
  wire [1:0] _GEN_72 = _key_buffer_T_2 != _GEN_4 ? _key_cnt_T_1 : key_cnt; // @[FSMKB.scala 212:91 215:29 76:26]
  wire  _GEN_75 = _T_30 & _GEN_67; // @[FSMKB.scala 209:44 222:26]
  wire [15:0] _GEN_76 = _T_30 ? _GEN_68 : key_buffer_0; // @[FSMKB.scala 209:44 75:25]
  wire [15:0] _GEN_77 = _T_30 ? _GEN_69 : key_buffer_1; // @[FSMKB.scala 209:44 75:25]
  wire [15:0] _GEN_78 = _T_30 ? _GEN_70 : key_buffer_2; // @[FSMKB.scala 209:44 75:25]
  wire [15:0] _GEN_79 = _T_30 ? _GEN_71 : key_buffer_3; // @[FSMKB.scala 209:44 75:25]
  wire [1:0] _GEN_80 = _T_30 ? _GEN_72 : key_cnt; // @[FSMKB.scala 209:44 76:26]
  wire  _GEN_81 = _T_28 | _T_30; // @[FSMKB.scala 203:39 204:26]
  wire  _GEN_83 = _T_28 ? 1'h0 : _GEN_75; // @[FSMKB.scala 203:39 206:26]
  wire [1:0] _GEN_84 = _T_28 ? _key_cnt_T_1 : _GEN_80; // @[FSMKB.scala 203:39 207:25]
  wire  _T_42 = kbdrec_io_data_valid & _T_30; // @[FSMKB.scala 226:39]
  wire  _GEN_97 = _T_8 ? 1'h0 : 1'h1; // @[FSMKB.scala 229:88 230:30 234:30]
  wire [15:0] _GEN_98 = _T_8 ? _GEN_30 : key_buffer_0; // @[FSMKB.scala 229:88 75:25]
  wire [15:0] _GEN_99 = _T_8 ? _GEN_31 : key_buffer_1; // @[FSMKB.scala 229:88 75:25]
  wire [15:0] _GEN_100 = _T_8 ? _GEN_32 : key_buffer_2; // @[FSMKB.scala 229:88 75:25]
  wire [15:0] _GEN_101 = _T_8 ? _GEN_33 : key_buffer_3; // @[FSMKB.scala 229:88 75:25]
  wire [1:0] _GEN_102 = _T_8 ? _key_cnt_T_1 : key_cnt; // @[FSMKB.scala 229:88 232:29 76:26]
  wire  _GEN_105 = kbdrec_io_data_valid & _T_30 & _GEN_97; // @[FSMKB.scala 226:62 239:26]
  wire [15:0] _GEN_106 = kbdrec_io_data_valid & _T_30 ? _GEN_98 : key_buffer_0; // @[FSMKB.scala 226:62 75:25]
  wire [15:0] _GEN_107 = kbdrec_io_data_valid & _T_30 ? _GEN_99 : key_buffer_1; // @[FSMKB.scala 226:62 75:25]
  wire [15:0] _GEN_108 = kbdrec_io_data_valid & _T_30 ? _GEN_100 : key_buffer_2; // @[FSMKB.scala 226:62 75:25]
  wire [15:0] _GEN_109 = kbdrec_io_data_valid & _T_30 ? _GEN_101 : key_buffer_3; // @[FSMKB.scala 226:62 75:25]
  wire [1:0] _GEN_110 = kbdrec_io_data_valid & _T_30 ? _GEN_102 : key_cnt; // @[FSMKB.scala 226:62 76:26]
  wire  _T_50 = _T_5 == key_buffer_0; // @[FSMKB.scala 249:61]
  wire [15:0] _GEN_111 = _T_5 == key_buffer_0 ? key_buffer_1 : key_buffer_0; // @[FSMKB.scala 249:80 250:39 75:25]
  wire [15:0] _GEN_112 = _T_5 == key_buffer_0 ? key_buffer_0 : key_buffer_1; // @[FSMKB.scala 249:80 251:39 75:25]
  wire  _T_56 = _T_5 == key_buffer_1; // @[FSMKB.scala 259:71]
  wire [15:0] _GEN_113 = _T_5 == key_buffer_1 ? key_buffer_2 : key_buffer_1; // @[FSMKB.scala 259:90 260:43 75:25]
  wire [15:0] _GEN_114 = _T_5 == key_buffer_1 ? key_buffer_1 : key_buffer_2; // @[FSMKB.scala 259:90 261:43 75:25]
  wire [15:0] _GEN_116 = _T_50 ? key_buffer_2 : _GEN_113; // @[FSMKB.scala 255:84 257:43]
  wire [15:0] _GEN_117 = _T_50 ? key_buffer_0 : _GEN_114; // @[FSMKB.scala 255:84 258:43]
  wire [15:0] _GEN_118 = _T_5 == key_buffer_2 ? key_buffer_3 : key_buffer_2; // @[FSMKB.scala 273:90 274:43 75:25]
  wire [15:0] _GEN_119 = _T_5 == key_buffer_2 ? key_buffer_2 : key_buffer_3; // @[FSMKB.scala 273:90 275:43 75:25]
  wire [15:0] _GEN_121 = _T_56 ? key_buffer_3 : _GEN_118; // @[FSMKB.scala 269:90 271:43]
  wire [15:0] _GEN_122 = _T_56 ? key_buffer_1 : _GEN_119; // @[FSMKB.scala 269:90 272:43]
  wire [15:0] _GEN_125 = _T_50 ? key_buffer_3 : _GEN_121; // @[FSMKB.scala 264:84 267:43]
  wire [15:0] _GEN_126 = _T_50 ? key_buffer_0 : _GEN_122; // @[FSMKB.scala 264:84 268:43]
  wire [15:0] _GEN_127 = _T_22 ? _GEN_111 : _GEN_111; // @[FSMKB.scala 254:43]
  wire [15:0] _GEN_128 = _T_22 ? _GEN_116 : _GEN_116; // @[FSMKB.scala 254:43]
  wire [15:0] _GEN_129 = _T_22 ? _GEN_117 : _GEN_125; // @[FSMKB.scala 254:43]
  wire [15:0] _GEN_130 = _T_22 ? key_buffer_3 : _GEN_126; // @[FSMKB.scala 254:43 75:25]
  wire [15:0] _GEN_131 = _T_30 ? _GEN_127 : key_buffer_0; // @[FSMKB.scala 253:48 75:25]
  wire [15:0] _GEN_132 = _T_30 ? _GEN_128 : key_buffer_1; // @[FSMKB.scala 253:48 75:25]
  wire [15:0] _GEN_133 = _T_30 ? _GEN_129 : key_buffer_2; // @[FSMKB.scala 253:48 75:25]
  wire [15:0] _GEN_134 = _T_30 ? _GEN_130 : key_buffer_3; // @[FSMKB.scala 253:48 75:25]
  wire [15:0] _GEN_135 = _T_28 ? _GEN_111 : _GEN_131; // @[FSMKB.scala 248:43]
  wire [15:0] _GEN_136 = _T_28 ? _GEN_112 : _GEN_132; // @[FSMKB.scala 248:43]
  wire [15:0] _GEN_137 = _T_28 ? key_buffer_2 : _GEN_133; // @[FSMKB.scala 248:43 75:25]
  wire [15:0] _GEN_138 = _T_28 ? key_buffer_3 : _GEN_134; // @[FSMKB.scala 248:43 75:25]
  wire [1:0] _GEN_139 = kbdrec_io_data_valid ? _T_7 : key_cnt; // @[FSMKB.scala 243:40 244:25 76:26]
  wire  _GEN_141 = kbdrec_io_data_valid; // @[FSMKB.scala 243:40 246:29 281:29]
  wire [15:0] _GEN_142 = kbdrec_io_data_valid ? _GEN_135 : key_buffer_0; // @[FSMKB.scala 243:40 75:25]
  wire [15:0] _GEN_143 = kbdrec_io_data_valid ? _GEN_136 : key_buffer_1; // @[FSMKB.scala 243:40 75:25]
  wire [15:0] _GEN_144 = kbdrec_io_data_valid ? _GEN_137 : key_buffer_2; // @[FSMKB.scala 243:40 75:25]
  wire [15:0] _GEN_145 = kbdrec_io_data_valid ? _GEN_138 : key_buffer_3; // @[FSMKB.scala 243:40 75:25]
  wire  _T_66 = _key_buffer_T_2 == key_buffer_0; // @[FSMKB.scala 292:64]
  wire [15:0] _GEN_146 = _key_buffer_T_2 == key_buffer_0 ? key_buffer_1 : key_buffer_0; // @[FSMKB.scala 292:83 293:39 75:25]
  wire [15:0] _GEN_147 = _key_buffer_T_2 == key_buffer_0 ? key_buffer_0 : key_buffer_1; // @[FSMKB.scala 292:83 294:39 75:25]
  wire  _T_72 = _key_buffer_T_2 == key_buffer_1; // @[FSMKB.scala 302:74]
  wire [15:0] _GEN_148 = _key_buffer_T_2 == key_buffer_1 ? key_buffer_2 : key_buffer_1; // @[FSMKB.scala 302:93 303:43 75:25]
  wire [15:0] _GEN_149 = _key_buffer_T_2 == key_buffer_1 ? key_buffer_1 : key_buffer_2; // @[FSMKB.scala 302:93 304:43 75:25]
  wire [15:0] _GEN_151 = _T_66 ? key_buffer_2 : _GEN_148; // @[FSMKB.scala 298:87 300:43]
  wire [15:0] _GEN_152 = _T_66 ? key_buffer_0 : _GEN_149; // @[FSMKB.scala 298:87 301:43]
  wire [15:0] _GEN_153 = _key_buffer_T_2 == key_buffer_2 ? key_buffer_3 : key_buffer_2; // @[FSMKB.scala 316:93 317:43 75:25]
  wire [15:0] _GEN_154 = _key_buffer_T_2 == key_buffer_2 ? key_buffer_2 : key_buffer_3; // @[FSMKB.scala 316:93 318:43 75:25]
  wire [15:0] _GEN_156 = _T_72 ? key_buffer_3 : _GEN_153; // @[FSMKB.scala 312:93 314:43]
  wire [15:0] _GEN_157 = _T_72 ? key_buffer_1 : _GEN_154; // @[FSMKB.scala 312:93 315:43]
  wire [15:0] _GEN_160 = _T_66 ? key_buffer_3 : _GEN_156; // @[FSMKB.scala 307:87 310:43]
  wire [15:0] _GEN_161 = _T_66 ? key_buffer_0 : _GEN_157; // @[FSMKB.scala 307:87 311:43]
  wire [15:0] _GEN_162 = _T_22 ? _GEN_146 : _GEN_146; // @[FSMKB.scala 297:43]
  wire [15:0] _GEN_163 = _T_22 ? _GEN_151 : _GEN_151; // @[FSMKB.scala 297:43]
  wire [15:0] _GEN_164 = _T_22 ? _GEN_152 : _GEN_160; // @[FSMKB.scala 297:43]
  wire [15:0] _GEN_165 = _T_22 ? key_buffer_3 : _GEN_161; // @[FSMKB.scala 297:43 75:25]
  wire [15:0] _GEN_166 = _T_30 ? _GEN_162 : key_buffer_0; // @[FSMKB.scala 296:48 75:25]
  wire [15:0] _GEN_167 = _T_30 ? _GEN_163 : key_buffer_1; // @[FSMKB.scala 296:48 75:25]
  wire [15:0] _GEN_168 = _T_30 ? _GEN_164 : key_buffer_2; // @[FSMKB.scala 296:48 75:25]
  wire [15:0] _GEN_169 = _T_30 ? _GEN_165 : key_buffer_3; // @[FSMKB.scala 296:48 75:25]
  wire [15:0] _GEN_170 = _T_28 ? _GEN_146 : _GEN_166; // @[FSMKB.scala 291:43]
  wire [15:0] _GEN_171 = _T_28 ? _GEN_147 : _GEN_167; // @[FSMKB.scala 291:43]
  wire [15:0] _GEN_172 = _T_28 ? key_buffer_2 : _GEN_168; // @[FSMKB.scala 291:43 75:25]
  wire [15:0] _GEN_173 = _T_28 ? key_buffer_3 : _GEN_169; // @[FSMKB.scala 291:43 75:25]
  wire [15:0] _GEN_175 = kbdrec_io_data_valid ? _GEN_170 : key_buffer_0; // @[FSMKB.scala 286:40 75:25]
  wire [15:0] _GEN_176 = kbdrec_io_data_valid ? _GEN_171 : key_buffer_1; // @[FSMKB.scala 286:40 75:25]
  wire [15:0] _GEN_177 = kbdrec_io_data_valid ? _GEN_172 : key_buffer_2; // @[FSMKB.scala 286:40 75:25]
  wire [15:0] _GEN_178 = kbdrec_io_data_valid ? _GEN_173 : key_buffer_3; // @[FSMKB.scala 286:40 75:25]
  wire [1:0] _GEN_179 = _T_23 ? _GEN_139 : key_cnt; // @[FSMKB.scala 171:16 76:26]
  wire  _GEN_180 = _T_23 ? 1'h0 : key_push; // @[FSMKB.scala 171:16 71:27]
  wire  _GEN_181 = _T_23 ? _GEN_141 : key_release; // @[FSMKB.scala 171:16 72:30]
  wire  _GEN_182 = _T_23 ? 1'h0 : key_same; // @[FSMKB.scala 171:16 73:27]
  wire [15:0] _GEN_183 = _T_23 ? _GEN_175 : key_buffer_0; // @[FSMKB.scala 171:16 75:25]
  wire [15:0] _GEN_184 = _T_23 ? _GEN_176 : key_buffer_1; // @[FSMKB.scala 171:16 75:25]
  wire [15:0] _GEN_185 = _T_23 ? _GEN_177 : key_buffer_2; // @[FSMKB.scala 171:16 75:25]
  wire [15:0] _GEN_186 = _T_23 ? _GEN_178 : key_buffer_3; // @[FSMKB.scala 171:16 75:25]
  wire [1:0] _GEN_187 = _T_19 ? _GEN_139 : _GEN_179; // @[FSMKB.scala 171:16]
  wire  _GEN_188 = _T_19 ? 1'h0 : _GEN_180; // @[FSMKB.scala 171:16]
  wire  _GEN_189 = _T_19 ? _GEN_141 : _GEN_181; // @[FSMKB.scala 171:16]
  wire  _GEN_190 = _T_19 ? 1'h0 : _GEN_182; // @[FSMKB.scala 171:16]
  wire [15:0] _GEN_191 = _T_19 ? _GEN_142 : _GEN_183; // @[FSMKB.scala 171:16]
  wire [15:0] _GEN_192 = _T_19 ? _GEN_143 : _GEN_184; // @[FSMKB.scala 171:16]
  wire [15:0] _GEN_193 = _T_19 ? _GEN_144 : _GEN_185; // @[FSMKB.scala 171:16]
  wire [15:0] _GEN_194 = _T_19 ? _GEN_145 : _GEN_186; // @[FSMKB.scala 171:16]
  wire  _GEN_195 = _T_12 ? _T_42 : _GEN_188; // @[FSMKB.scala 171:16]
  wire  _GEN_196 = _T_12 ? 1'h0 : _GEN_189; // @[FSMKB.scala 171:16]
  wire  _GEN_197 = _T_12 ? _GEN_105 : _GEN_190; // @[FSMKB.scala 171:16]
  wire [1:0] _GEN_202 = _T_12 ? _GEN_110 : _GEN_187; // @[FSMKB.scala 171:16]
  KBDREC kbdrec ( // @[FSMKB.scala 90:24]
    .clock(kbdrec_clock),
    .reset(kbdrec_reset),
    .io_ps2_clk(kbdrec_io_ps2_clk),
    .io_ps2_data(kbdrec_io_ps2_data),
    .io_data_ready(kbdrec_io_data_ready),
    .io_data_valid(kbdrec_io_data_valid),
    .io_data_bits(kbdrec_io_data_bits)
  );
  assign io_key_bits_push = key_push; // @[FSMKB.scala 80:22]
  assign io_key_bits_release = key_release; // @[FSMKB.scala 81:25]
  assign io_key_bits_same = key_same; // @[FSMKB.scala 82:22]
  assign io_key_bits_cnt = key_cnt; // @[FSMKB.scala 83:21]
  assign io_key_bits_scancode_0 = key_buffer_0; // @[FSMKB.scala 84:26]
  assign io_key_bits_scancode_1 = key_buffer_1; // @[FSMKB.scala 84:26]
  assign io_key_bits_scancode_2 = key_buffer_2; // @[FSMKB.scala 84:26]
  assign io_key_bits_scancode_3 = key_buffer_3; // @[FSMKB.scala 84:26]
  assign kbdrec_clock = clock;
  assign kbdrec_reset = reset;
  assign kbdrec_io_ps2_clk = io_ps2_clk; // @[FSMKB.scala 91:23]
  assign kbdrec_io_ps2_data = io_ps2_data; // @[FSMKB.scala 92:24]
  assign kbdrec_io_data_ready = ~buffer_full; // @[FSMKB.scala 93:29]
  always @(posedge clock) begin
    if (reset) begin // @[FSMKB.scala 70:21]
      cs <= 3'h0; // @[FSMKB.scala 70:21]
    end else if (kbdrec_io_data_valid) begin // @[FSMKB.scala 104:32]
      if (3'h0 == cs) begin // @[FSMKB.scala 105:20]
        if (kbdrec_io_data_bits != 8'he0) begin // @[FSMKB.scala 107:54]
          cs <= 3'h1; // @[FSMKB.scala 108:24]
        end else begin
          cs <= 3'h2; // @[FSMKB.scala 110:24]
        end
      end else if (3'h1 == cs) begin // @[FSMKB.scala 105:20]
        cs <= _GEN_7;
      end else begin
        cs <= _GEN_26;
      end
    end
    if (reset) begin // @[FSMKB.scala 71:27]
      key_push <= 1'h0; // @[FSMKB.scala 71:27]
    end else if (_T) begin // @[FSMKB.scala 171:16]
      key_push <= _T_28;
    end else if (_T_2) begin // @[FSMKB.scala 171:16]
      key_push <= _GEN_47;
    end else if (_T_9) begin // @[FSMKB.scala 171:16]
      key_push <= _GEN_81;
    end else begin
      key_push <= _GEN_195;
    end
    if (reset) begin // @[FSMKB.scala 72:30]
      key_release <= 1'h0; // @[FSMKB.scala 72:30]
    end else if (_T) begin // @[FSMKB.scala 171:16]
      key_release <= 1'h0;
    end else if (_T_2) begin // @[FSMKB.scala 171:16]
      key_release <= 1'h0;
    end else if (_T_9) begin // @[FSMKB.scala 171:16]
      key_release <= 1'h0;
    end else begin
      key_release <= _GEN_196;
    end
    if (reset) begin // @[FSMKB.scala 73:27]
      key_same <= 1'h0; // @[FSMKB.scala 73:27]
    end else if (_T) begin // @[FSMKB.scala 171:16]
      key_same <= 1'h0;
    end else if (_T_2) begin // @[FSMKB.scala 171:16]
      if (ns == 3'h3) begin // @[FSMKB.scala 186:38]
        key_same <= 1'h0; // @[FSMKB.scala 189:26]
      end else begin
        key_same <= _T_32;
      end
    end else if (_T_9) begin // @[FSMKB.scala 171:16]
      key_same <= _GEN_83;
    end else begin
      key_same <= _GEN_197;
    end
    if (_T) begin // @[FSMKB.scala 171:16]
      if (ns == 3'h1) begin // @[FSMKB.scala 173:39]
        key_buffer_0 <= _GEN_30;
      end
    end else if (_T_2) begin // @[FSMKB.scala 171:16]
      if (ns == 3'h3) begin // @[FSMKB.scala 186:38]
        key_buffer_0 <= _GEN_30;
      end
    end else if (_T_9) begin // @[FSMKB.scala 171:16]
      if (_T_28) begin // @[FSMKB.scala 203:39]
        key_buffer_0 <= _GEN_55;
      end else begin
        key_buffer_0 <= _GEN_76;
      end
    end else if (_T_12) begin // @[FSMKB.scala 171:16]
      key_buffer_0 <= _GEN_106;
    end else begin
      key_buffer_0 <= _GEN_191;
    end
    if (_T) begin // @[FSMKB.scala 171:16]
      if (ns == 3'h1) begin // @[FSMKB.scala 173:39]
        key_buffer_1 <= _GEN_31;
      end
    end else if (_T_2) begin // @[FSMKB.scala 171:16]
      if (ns == 3'h3) begin // @[FSMKB.scala 186:38]
        key_buffer_1 <= _GEN_31;
      end
    end else if (_T_9) begin // @[FSMKB.scala 171:16]
      if (_T_28) begin // @[FSMKB.scala 203:39]
        key_buffer_1 <= _GEN_56;
      end else begin
        key_buffer_1 <= _GEN_77;
      end
    end else if (_T_12) begin // @[FSMKB.scala 171:16]
      key_buffer_1 <= _GEN_107;
    end else begin
      key_buffer_1 <= _GEN_192;
    end
    if (_T) begin // @[FSMKB.scala 171:16]
      if (ns == 3'h1) begin // @[FSMKB.scala 173:39]
        key_buffer_2 <= _GEN_32;
      end
    end else if (_T_2) begin // @[FSMKB.scala 171:16]
      if (ns == 3'h3) begin // @[FSMKB.scala 186:38]
        key_buffer_2 <= _GEN_32;
      end
    end else if (_T_9) begin // @[FSMKB.scala 171:16]
      if (_T_28) begin // @[FSMKB.scala 203:39]
        key_buffer_2 <= _GEN_57;
      end else begin
        key_buffer_2 <= _GEN_78;
      end
    end else if (_T_12) begin // @[FSMKB.scala 171:16]
      key_buffer_2 <= _GEN_108;
    end else begin
      key_buffer_2 <= _GEN_193;
    end
    if (_T) begin // @[FSMKB.scala 171:16]
      if (ns == 3'h1) begin // @[FSMKB.scala 173:39]
        key_buffer_3 <= _GEN_33;
      end
    end else if (_T_2) begin // @[FSMKB.scala 171:16]
      if (ns == 3'h3) begin // @[FSMKB.scala 186:38]
        key_buffer_3 <= _GEN_33;
      end
    end else if (_T_9) begin // @[FSMKB.scala 171:16]
      if (_T_28) begin // @[FSMKB.scala 203:39]
        key_buffer_3 <= _GEN_58;
      end else begin
        key_buffer_3 <= _GEN_79;
      end
    end else if (_T_12) begin // @[FSMKB.scala 171:16]
      key_buffer_3 <= _GEN_109;
    end else begin
      key_buffer_3 <= _GEN_194;
    end
    if (reset) begin // @[FSMKB.scala 76:26]
      key_cnt <= 2'h0; // @[FSMKB.scala 76:26]
    end else if (_T) begin // @[FSMKB.scala 171:16]
      if (ns == 3'h1) begin // @[FSMKB.scala 173:39]
        key_cnt <= _key_cnt_T_1; // @[FSMKB.scala 178:25]
      end
    end else if (_T_2) begin // @[FSMKB.scala 171:16]
      if (ns == 3'h3) begin // @[FSMKB.scala 186:38]
        key_cnt <= _key_cnt_T_1; // @[FSMKB.scala 191:25]
      end
    end else if (_T_9) begin // @[FSMKB.scala 171:16]
      key_cnt <= _GEN_84;
    end else begin
      key_cnt <= _GEN_202;
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
  cs = _RAND_0[2:0];
  _RAND_1 = {1{`RANDOM}};
  key_push = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  key_release = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  key_same = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  key_buffer_0 = _RAND_4[15:0];
  _RAND_5 = {1{`RANDOM}};
  key_buffer_1 = _RAND_5[15:0];
  _RAND_6 = {1{`RANDOM}};
  key_buffer_2 = _RAND_6[15:0];
  _RAND_7 = {1{`RANDOM}};
  key_buffer_3 = _RAND_7[15:0];
  _RAND_8 = {1{`RANDOM}};
  key_cnt = _RAND_8[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Num2Seg(
  input  [7:0]  io_in,
  output [15:0] io_out
);
  wire [7:0] _GEN_1 = 4'h1 == io_in[7:4] ? 8'h9f : 8'h3; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_2 = 4'h2 == io_in[7:4] ? 8'h25 : _GEN_1; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_3 = 4'h3 == io_in[7:4] ? 8'hd : _GEN_2; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_4 = 4'h4 == io_in[7:4] ? 8'h99 : _GEN_3; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_5 = 4'h5 == io_in[7:4] ? 8'h49 : _GEN_4; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_6 = 4'h6 == io_in[7:4] ? 8'h41 : _GEN_5; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_7 = 4'h7 == io_in[7:4] ? 8'h1f : _GEN_6; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_8 = 4'h8 == io_in[7:4] ? 8'h1 : _GEN_7; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_9 = 4'h9 == io_in[7:4] ? 8'h9 : _GEN_8; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_10 = 4'ha == io_in[7:4] ? 8'h11 : _GEN_9; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_11 = 4'hb == io_in[7:4] ? 8'hc1 : _GEN_10; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_12 = 4'hc == io_in[7:4] ? 8'h63 : _GEN_11; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_13 = 4'hd == io_in[7:4] ? 8'h85 : _GEN_12; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_14 = 4'he == io_in[7:4] ? 8'h61 : _GEN_13; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_15 = 4'hf == io_in[7:4] ? 8'h71 : _GEN_14; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_17 = 4'h1 == io_in[3:0] ? 8'h9f : 8'h3; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_18 = 4'h2 == io_in[3:0] ? 8'h25 : _GEN_17; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_19 = 4'h3 == io_in[3:0] ? 8'hd : _GEN_18; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_20 = 4'h4 == io_in[3:0] ? 8'h99 : _GEN_19; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_21 = 4'h5 == io_in[3:0] ? 8'h49 : _GEN_20; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_22 = 4'h6 == io_in[3:0] ? 8'h41 : _GEN_21; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_23 = 4'h7 == io_in[3:0] ? 8'h1f : _GEN_22; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_24 = 4'h8 == io_in[3:0] ? 8'h1 : _GEN_23; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_25 = 4'h9 == io_in[3:0] ? 8'h9 : _GEN_24; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_26 = 4'ha == io_in[3:0] ? 8'h11 : _GEN_25; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_27 = 4'hb == io_in[3:0] ? 8'hc1 : _GEN_26; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_28 = 4'hc == io_in[3:0] ? 8'h63 : _GEN_27; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_29 = 4'hd == io_in[3:0] ? 8'h85 : _GEN_28; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_30 = 4'he == io_in[3:0] ? 8'h61 : _GEN_29; // @[Cat.scala 31:{58,58}]
  wire [7:0] _GEN_31 = 4'hf == io_in[3:0] ? 8'h71 : _GEN_30; // @[Cat.scala 31:{58,58}]
  assign io_out = {_GEN_15,_GEN_31}; // @[Cat.scala 31:58]
endmodule
module Scan2ASCII(
  input         clock,
  input         reset,
  input         io_ps2_clk,
  input         io_ps2_data,
  output        io_shift,
  output        io_ctrl,
  output        io_alt,
  output [15:0] io_seg_scancode,
  output [15:0] io_seg_asciicode,
  output [15:0] io_seg_close,
  output [15:0] io_seg_times
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
`endif // RANDOMIZE_REG_INIT
  wire  fsmkb_clock; // @[Scan2ASCII.scala 31:23]
  wire  fsmkb_reset; // @[Scan2ASCII.scala 31:23]
  wire  fsmkb_io_ps2_clk; // @[Scan2ASCII.scala 31:23]
  wire  fsmkb_io_ps2_data; // @[Scan2ASCII.scala 31:23]
  wire  fsmkb_io_key_bits_push; // @[Scan2ASCII.scala 31:23]
  wire  fsmkb_io_key_bits_release; // @[Scan2ASCII.scala 31:23]
  wire  fsmkb_io_key_bits_same; // @[Scan2ASCII.scala 31:23]
  wire [1:0] fsmkb_io_key_bits_cnt; // @[Scan2ASCII.scala 31:23]
  wire [15:0] fsmkb_io_key_bits_scancode_0; // @[Scan2ASCII.scala 31:23]
  wire [15:0] fsmkb_io_key_bits_scancode_1; // @[Scan2ASCII.scala 31:23]
  wire [15:0] fsmkb_io_key_bits_scancode_2; // @[Scan2ASCII.scala 31:23]
  wire [15:0] fsmkb_io_key_bits_scancode_3; // @[Scan2ASCII.scala 31:23]
  wire [7:0] num2seg0_io_in; // @[Scan2ASCII.scala 327:26]
  wire [15:0] num2seg0_io_out; // @[Scan2ASCII.scala 327:26]
  wire [7:0] num2seg1_io_in; // @[Scan2ASCII.scala 329:26]
  wire [15:0] num2seg1_io_out; // @[Scan2ASCII.scala 329:26]
  wire [7:0] num2seg3_io_in; // @[Scan2ASCII.scala 331:26]
  wire [15:0] num2seg3_io_out; // @[Scan2ASCII.scala 331:26]
  reg [7:0] scancode; // @[Scan2ASCII.scala 24:27]
  reg [7:0] times; // @[Scan2ASCII.scala 26:24]
  reg  shift; // @[Scan2ASCII.scala 27:24]
  reg  ctrl; // @[Scan2ASCII.scala 28:23]
  reg  alt; // @[Scan2ASCII.scala 29:22]
  wire  same = fsmkb_io_key_bits_same;
  wire  push = fsmkb_io_key_bits_push;
  wire [7:0] _times_T_1 = times + 8'h1; // @[Scan2ASCII.scala 47:24]
  wire [1:0] cnt = fsmkb_io_key_bits_cnt;
  wire [1:0] _scancode_T_1 = cnt - 2'h1; // @[Scan2ASCII.scala 48:52]
  wire [15:0] _GEN_0 = fsmkb_io_key_bits_scancode_0; // @[Scan2ASCII.scala 48:{58,58}]
  wire [15:0] _GEN_1 = 2'h1 == _scancode_T_1 ? fsmkb_io_key_bits_scancode_1 : _GEN_0; // @[Scan2ASCII.scala 48:{58,58}]
  wire [15:0] _GEN_2 = 2'h2 == _scancode_T_1 ? fsmkb_io_key_bits_scancode_2 : _GEN_1; // @[Scan2ASCII.scala 48:{58,58}]
  wire [15:0] _GEN_3 = 2'h3 == _scancode_T_1 ? fsmkb_io_key_bits_scancode_3 : _GEN_2; // @[Scan2ASCII.scala 48:{58,58}]
  wire [15:0] _GEN_30 = 2'h1 == cnt ? fsmkb_io_key_bits_scancode_1 : _GEN_0; // @[Scan2ASCII.scala 56:{58,58}]
  wire [15:0] _GEN_31 = 2'h2 == cnt ? fsmkb_io_key_bits_scancode_2 : _GEN_30; // @[Scan2ASCII.scala 56:{58,58}]
  wire [15:0] _GEN_32 = 2'h3 == cnt ? fsmkb_io_key_bits_scancode_3 : _GEN_31; // @[Scan2ASCII.scala 56:{58,58}]
  wire  _shift_T_15 = _GEN_32[7:0] == 8'h59 | _GEN_32[7:0] == 8'h12 ? 1'h0 : shift; // @[Scan2ASCII.scala 56:25]
  wire  _ctrl_T_7 = _GEN_32[7:0] == 8'h14 ? 1'h0 : ctrl; // @[Scan2ASCII.scala 57:24]
  wire  _alt_T_7 = _GEN_32[7:0] == 8'h11 ? 1'h0 : alt; // @[Scan2ASCII.scala 58:23]
  wire  _GEN_34 = cnt != 2'h0 & _shift_T_15; // @[Scan2ASCII.scala 54:27 56:19 61:19]
  wire  _GEN_35 = cnt != 2'h0 & _ctrl_T_7; // @[Scan2ASCII.scala 54:27 57:18 62:18]
  wire  _GEN_36 = cnt != 2'h0 & _alt_T_7; // @[Scan2ASCII.scala 54:27 58:17 63:17]
  wire  release_ = fsmkb_io_key_bits_release;
  wire [15:0] _GEN_54 = 8'hd == scancode ? 16'h900 : 16'h0; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_55 = 8'he == scancode ? 16'h607e : _GEN_54; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_56 = 8'hf == scancode ? 16'h0 : _GEN_55; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_57 = 8'h10 == scancode ? 16'h0 : _GEN_56; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_58 = 8'h11 == scancode ? 16'h0 : _GEN_57; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_59 = 8'h12 == scancode ? 16'h0 : _GEN_58; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_60 = 8'h13 == scancode ? 16'h0 : _GEN_59; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_61 = 8'h14 == scancode ? 16'h0 : _GEN_60; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_62 = 8'h15 == scancode ? 16'h7151 : _GEN_61; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_63 = 8'h16 == scancode ? 16'h3121 : _GEN_62; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_64 = 8'h17 == scancode ? 16'h0 : _GEN_63; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_65 = 8'h18 == scancode ? 16'h0 : _GEN_64; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_66 = 8'h19 == scancode ? 16'h0 : _GEN_65; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_67 = 8'h1a == scancode ? 16'h7a5a : _GEN_66; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_68 = 8'h1b == scancode ? 16'h7353 : _GEN_67; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_69 = 8'h1c == scancode ? 16'h6141 : _GEN_68; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_70 = 8'h1d == scancode ? 16'h7757 : _GEN_69; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_71 = 8'h1e == scancode ? 16'h3240 : _GEN_70; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_72 = 8'h1f == scancode ? 16'h0 : _GEN_71; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_73 = 8'h20 == scancode ? 16'h0 : _GEN_72; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_74 = 8'h21 == scancode ? 16'h6343 : _GEN_73; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_75 = 8'h22 == scancode ? 16'h7858 : _GEN_74; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_76 = 8'h23 == scancode ? 16'h6444 : _GEN_75; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_77 = 8'h24 == scancode ? 16'h6545 : _GEN_76; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_78 = 8'h25 == scancode ? 16'h3424 : _GEN_77; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_79 = 8'h26 == scancode ? 16'h3323 : _GEN_78; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_80 = 8'h27 == scancode ? 16'h0 : _GEN_79; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_81 = 8'h28 == scancode ? 16'h0 : _GEN_80; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_82 = 8'h29 == scancode ? 16'h2000 : _GEN_81; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_83 = 8'h2a == scancode ? 16'h7656 : _GEN_82; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_84 = 8'h2b == scancode ? 16'h6646 : _GEN_83; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_85 = 8'h2c == scancode ? 16'h7454 : _GEN_84; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_86 = 8'h2d == scancode ? 16'h7252 : _GEN_85; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_87 = 8'h2e == scancode ? 16'h3525 : _GEN_86; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_88 = 8'h2f == scancode ? 16'h0 : _GEN_87; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_89 = 8'h30 == scancode ? 16'h0 : _GEN_88; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_90 = 8'h31 == scancode ? 16'h6e4e : _GEN_89; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_91 = 8'h32 == scancode ? 16'h6242 : _GEN_90; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_92 = 8'h33 == scancode ? 16'h6848 : _GEN_91; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_93 = 8'h34 == scancode ? 16'h6747 : _GEN_92; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_94 = 8'h35 == scancode ? 16'h7959 : _GEN_93; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_95 = 8'h36 == scancode ? 16'h365e : _GEN_94; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_96 = 8'h37 == scancode ? 16'h0 : _GEN_95; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_97 = 8'h38 == scancode ? 16'h0 : _GEN_96; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_98 = 8'h39 == scancode ? 16'h0 : _GEN_97; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_99 = 8'h3a == scancode ? 16'h6d4d : _GEN_98; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_100 = 8'h3b == scancode ? 16'h6a4a : _GEN_99; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_101 = 8'h3c == scancode ? 16'h7555 : _GEN_100; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_102 = 8'h3d == scancode ? 16'h3726 : _GEN_101; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_103 = 8'h3e == scancode ? 16'h382a : _GEN_102; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_104 = 8'h3f == scancode ? 16'h0 : _GEN_103; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_105 = 8'h40 == scancode ? 16'h0 : _GEN_104; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_106 = 8'h41 == scancode ? 16'h2c3c : _GEN_105; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_107 = 8'h42 == scancode ? 16'h6b4b : _GEN_106; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_108 = 8'h43 == scancode ? 16'h6949 : _GEN_107; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_109 = 8'h44 == scancode ? 16'h6f4f : _GEN_108; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_110 = 8'h45 == scancode ? 16'h3029 : _GEN_109; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_111 = 8'h46 == scancode ? 16'h3928 : _GEN_110; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_112 = 8'h47 == scancode ? 16'h0 : _GEN_111; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_113 = 8'h48 == scancode ? 16'h0 : _GEN_112; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_114 = 8'h49 == scancode ? 16'h2e3e : _GEN_113; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_115 = 8'h4a == scancode ? 16'h2f3f : _GEN_114; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_116 = 8'h4b == scancode ? 16'h6c4c : _GEN_115; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_117 = 8'h4c == scancode ? 16'h3b3a : _GEN_116; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_118 = 8'h4d == scancode ? 16'h7050 : _GEN_117; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_119 = 8'h4e == scancode ? 16'h2d5f : _GEN_118; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_120 = 8'h4f == scancode ? 16'h0 : _GEN_119; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_121 = 8'h50 == scancode ? 16'h0 : _GEN_120; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_122 = 8'h51 == scancode ? 16'h0 : _GEN_121; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_123 = 8'h52 == scancode ? 16'h2722 : _GEN_122; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_124 = 8'h53 == scancode ? 16'h0 : _GEN_123; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_125 = 8'h54 == scancode ? 16'h5b7b : _GEN_124; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_126 = 8'h55 == scancode ? 16'h3d2b : _GEN_125; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_127 = 8'h56 == scancode ? 16'h0 : _GEN_126; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_128 = 8'h57 == scancode ? 16'h0 : _GEN_127; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_129 = 8'h58 == scancode ? 16'h0 : _GEN_128; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_130 = 8'h59 == scancode ? 16'h0 : _GEN_129; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_131 = 8'h5a == scancode ? 16'hd00 : _GEN_130; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_132 = 8'h5b == scancode ? 16'h5d7d : _GEN_131; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_133 = 8'h5c == scancode ? 16'h0 : _GEN_132; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_134 = 8'h5d == scancode ? 16'h5c7c : _GEN_133; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_135 = 8'h5e == scancode ? 16'h0 : _GEN_134; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_136 = 8'h5f == scancode ? 16'h0 : _GEN_135; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_137 = 8'h60 == scancode ? 16'h0 : _GEN_136; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_138 = 8'h61 == scancode ? 16'h0 : _GEN_137; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_139 = 8'h62 == scancode ? 16'h0 : _GEN_138; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_140 = 8'h63 == scancode ? 16'h0 : _GEN_139; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_141 = 8'h64 == scancode ? 16'h0 : _GEN_140; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_142 = 8'h65 == scancode ? 16'h0 : _GEN_141; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_143 = 8'h66 == scancode ? 16'h800 : _GEN_142; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_144 = 8'h67 == scancode ? 16'h0 : _GEN_143; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_145 = 8'h68 == scancode ? 16'h0 : _GEN_144; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_146 = 8'h69 == scancode ? 16'h3100 : _GEN_145; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_147 = 8'h6a == scancode ? 16'h0 : _GEN_146; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_148 = 8'h6b == scancode ? 16'h3400 : _GEN_147; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_149 = 8'h6c == scancode ? 16'h3700 : _GEN_148; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_150 = 8'h6d == scancode ? 16'h0 : _GEN_149; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_151 = 8'h6e == scancode ? 16'h0 : _GEN_150; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_152 = 8'h6f == scancode ? 16'h0 : _GEN_151; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_153 = 8'h70 == scancode ? 16'h3000 : _GEN_152; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_154 = 8'h71 == scancode ? 16'h2e00 : _GEN_153; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_155 = 8'h72 == scancode ? 16'h3200 : _GEN_154; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_156 = 8'h73 == scancode ? 16'h3500 : _GEN_155; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_157 = 8'h74 == scancode ? 16'h3600 : _GEN_156; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_158 = 8'h75 == scancode ? 16'h3800 : _GEN_157; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_159 = 8'h76 == scancode ? 16'h0 : _GEN_158; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_160 = 8'h77 == scancode ? 16'h0 : _GEN_159; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_161 = 8'h78 == scancode ? 16'h0 : _GEN_160; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_162 = 8'h79 == scancode ? 16'h2b00 : _GEN_161; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_163 = 8'h7a == scancode ? 16'h3300 : _GEN_162; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_164 = 8'h7b == scancode ? 16'h0 : _GEN_163; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_165 = 8'h7c == scancode ? 16'h0 : _GEN_164; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_166 = 8'h7d == scancode ? 16'h3900 : _GEN_165; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_167 = 8'h7e == scancode ? 16'h0 : _GEN_166; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_168 = 8'h7f == scancode ? 16'h0 : _GEN_167; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_169 = 8'h80 == scancode ? 16'h0 : _GEN_168; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_170 = 8'h81 == scancode ? 16'h0 : _GEN_169; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_171 = 8'h82 == scancode ? 16'h0 : _GEN_170; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_172 = 8'h83 == scancode ? 16'hf700 : _GEN_171; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_173 = 8'h84 == scancode ? 16'h0 : _GEN_172; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_174 = 8'h85 == scancode ? 16'h0 : _GEN_173; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_175 = 8'h86 == scancode ? 16'h0 : _GEN_174; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_176 = 8'h87 == scancode ? 16'h0 : _GEN_175; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_177 = 8'h88 == scancode ? 16'h0 : _GEN_176; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_178 = 8'h89 == scancode ? 16'h0 : _GEN_177; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_179 = 8'h8a == scancode ? 16'h0 : _GEN_178; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_180 = 8'h8b == scancode ? 16'h0 : _GEN_179; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_181 = 8'h8c == scancode ? 16'h0 : _GEN_180; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_182 = 8'h8d == scancode ? 16'h0 : _GEN_181; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_183 = 8'h8e == scancode ? 16'h0 : _GEN_182; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_184 = 8'h8f == scancode ? 16'h0 : _GEN_183; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_185 = 8'h90 == scancode ? 16'h0 : _GEN_184; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_186 = 8'h91 == scancode ? 16'h0 : _GEN_185; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_187 = 8'h92 == scancode ? 16'h0 : _GEN_186; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_188 = 8'h93 == scancode ? 16'h0 : _GEN_187; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_189 = 8'h94 == scancode ? 16'h0 : _GEN_188; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_190 = 8'h95 == scancode ? 16'h0 : _GEN_189; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_191 = 8'h96 == scancode ? 16'h0 : _GEN_190; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_192 = 8'h97 == scancode ? 16'h0 : _GEN_191; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_193 = 8'h98 == scancode ? 16'h0 : _GEN_192; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_194 = 8'h99 == scancode ? 16'h0 : _GEN_193; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_195 = 8'h9a == scancode ? 16'h0 : _GEN_194; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_196 = 8'h9b == scancode ? 16'h0 : _GEN_195; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_197 = 8'h9c == scancode ? 16'h0 : _GEN_196; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_198 = 8'h9d == scancode ? 16'h0 : _GEN_197; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_199 = 8'h9e == scancode ? 16'h0 : _GEN_198; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_200 = 8'h9f == scancode ? 16'h0 : _GEN_199; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_201 = 8'ha0 == scancode ? 16'h0 : _GEN_200; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_202 = 8'ha1 == scancode ? 16'h0 : _GEN_201; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_203 = 8'ha2 == scancode ? 16'h0 : _GEN_202; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_204 = 8'ha3 == scancode ? 16'h0 : _GEN_203; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_205 = 8'ha4 == scancode ? 16'h0 : _GEN_204; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_206 = 8'ha5 == scancode ? 16'h0 : _GEN_205; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_207 = 8'ha6 == scancode ? 16'h0 : _GEN_206; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_208 = 8'ha7 == scancode ? 16'h0 : _GEN_207; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_209 = 8'ha8 == scancode ? 16'h0 : _GEN_208; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_210 = 8'ha9 == scancode ? 16'h0 : _GEN_209; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_211 = 8'haa == scancode ? 16'h0 : _GEN_210; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_212 = 8'hab == scancode ? 16'h0 : _GEN_211; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_213 = 8'hac == scancode ? 16'h0 : _GEN_212; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_214 = 8'had == scancode ? 16'h0 : _GEN_213; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_215 = 8'hae == scancode ? 16'h0 : _GEN_214; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_216 = 8'haf == scancode ? 16'h0 : _GEN_215; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_217 = 8'hb0 == scancode ? 16'h0 : _GEN_216; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_218 = 8'hb1 == scancode ? 16'h0 : _GEN_217; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_219 = 8'hb2 == scancode ? 16'h0 : _GEN_218; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_220 = 8'hb3 == scancode ? 16'h0 : _GEN_219; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_221 = 8'hb4 == scancode ? 16'h0 : _GEN_220; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_222 = 8'hb5 == scancode ? 16'h0 : _GEN_221; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_223 = 8'hb6 == scancode ? 16'h0 : _GEN_222; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_224 = 8'hb7 == scancode ? 16'h0 : _GEN_223; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_225 = 8'hb8 == scancode ? 16'h0 : _GEN_224; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_226 = 8'hb9 == scancode ? 16'h0 : _GEN_225; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_227 = 8'hba == scancode ? 16'h0 : _GEN_226; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_228 = 8'hbb == scancode ? 16'h0 : _GEN_227; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_229 = 8'hbc == scancode ? 16'h0 : _GEN_228; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_230 = 8'hbd == scancode ? 16'h0 : _GEN_229; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_231 = 8'hbe == scancode ? 16'h0 : _GEN_230; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_232 = 8'hbf == scancode ? 16'h0 : _GEN_231; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_233 = 8'hc0 == scancode ? 16'h0 : _GEN_232; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_234 = 8'hc1 == scancode ? 16'h0 : _GEN_233; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_235 = 8'hc2 == scancode ? 16'h0 : _GEN_234; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_236 = 8'hc3 == scancode ? 16'h0 : _GEN_235; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_237 = 8'hc4 == scancode ? 16'h0 : _GEN_236; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_238 = 8'hc5 == scancode ? 16'h0 : _GEN_237; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_239 = 8'hc6 == scancode ? 16'h0 : _GEN_238; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_240 = 8'hc7 == scancode ? 16'h0 : _GEN_239; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_241 = 8'hc8 == scancode ? 16'h0 : _GEN_240; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_242 = 8'hc9 == scancode ? 16'h0 : _GEN_241; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_243 = 8'hca == scancode ? 16'h0 : _GEN_242; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_244 = 8'hcb == scancode ? 16'h0 : _GEN_243; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_245 = 8'hcc == scancode ? 16'h0 : _GEN_244; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_246 = 8'hcd == scancode ? 16'h0 : _GEN_245; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_247 = 8'hce == scancode ? 16'h0 : _GEN_246; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_248 = 8'hcf == scancode ? 16'h0 : _GEN_247; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_249 = 8'hd0 == scancode ? 16'h0 : _GEN_248; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_250 = 8'hd1 == scancode ? 16'h0 : _GEN_249; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_251 = 8'hd2 == scancode ? 16'h0 : _GEN_250; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_252 = 8'hd3 == scancode ? 16'h0 : _GEN_251; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_253 = 8'hd4 == scancode ? 16'h0 : _GEN_252; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_254 = 8'hd5 == scancode ? 16'h0 : _GEN_253; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_255 = 8'hd6 == scancode ? 16'h0 : _GEN_254; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_256 = 8'hd7 == scancode ? 16'h0 : _GEN_255; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_257 = 8'hd8 == scancode ? 16'h0 : _GEN_256; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_258 = 8'hd9 == scancode ? 16'h0 : _GEN_257; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_259 = 8'hda == scancode ? 16'h0 : _GEN_258; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_260 = 8'hdb == scancode ? 16'h0 : _GEN_259; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_261 = 8'hdc == scancode ? 16'h0 : _GEN_260; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_262 = 8'hdd == scancode ? 16'h0 : _GEN_261; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_263 = 8'hde == scancode ? 16'h0 : _GEN_262; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_264 = 8'hdf == scancode ? 16'h0 : _GEN_263; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_265 = 8'he0 == scancode ? 16'h0 : _GEN_264; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_266 = 8'he1 == scancode ? 16'h0 : _GEN_265; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_267 = 8'he2 == scancode ? 16'h0 : _GEN_266; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_268 = 8'he3 == scancode ? 16'h0 : _GEN_267; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_269 = 8'he4 == scancode ? 16'h0 : _GEN_268; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_270 = 8'he5 == scancode ? 16'h0 : _GEN_269; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_271 = 8'he6 == scancode ? 16'h0 : _GEN_270; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_272 = 8'he7 == scancode ? 16'h0 : _GEN_271; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_273 = 8'he8 == scancode ? 16'h0 : _GEN_272; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_274 = 8'he9 == scancode ? 16'h0 : _GEN_273; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_275 = 8'hea == scancode ? 16'h0 : _GEN_274; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_276 = 8'heb == scancode ? 16'h0 : _GEN_275; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_277 = 8'hec == scancode ? 16'h0 : _GEN_276; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_278 = 8'hed == scancode ? 16'h0 : _GEN_277; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_279 = 8'hee == scancode ? 16'h0 : _GEN_278; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_280 = 8'hef == scancode ? 16'h0 : _GEN_279; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_281 = 8'hf0 == scancode ? 16'h0 : _GEN_280; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_282 = 8'hf1 == scancode ? 16'h0 : _GEN_281; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_283 = 8'hf2 == scancode ? 16'h0 : _GEN_282; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_284 = 8'hf3 == scancode ? 16'h0 : _GEN_283; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_285 = 8'hf4 == scancode ? 16'h0 : _GEN_284; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_286 = 8'hf5 == scancode ? 16'h0 : _GEN_285; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_287 = 8'hf6 == scancode ? 16'h0 : _GEN_286; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_288 = 8'hf7 == scancode ? 16'h0 : _GEN_287; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_289 = 8'hf8 == scancode ? 16'h0 : _GEN_288; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_290 = 8'hf9 == scancode ? 16'h0 : _GEN_289; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_291 = 8'hfa == scancode ? 16'h0 : _GEN_290; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_292 = 8'hfb == scancode ? 16'h0 : _GEN_291; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_293 = 8'hfc == scancode ? 16'h0 : _GEN_292; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_294 = 8'hfd == scancode ? 16'h0 : _GEN_293; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_295 = 8'hfe == scancode ? 16'h0 : _GEN_294; // @[Scan2ASCII.scala 325:{49,49}]
  wire [15:0] _GEN_296 = 8'hff == scancode ? 16'h0 : _GEN_295; // @[Scan2ASCII.scala 325:{49,49}]
  FSMKB fsmkb ( // @[Scan2ASCII.scala 31:23]
    .clock(fsmkb_clock),
    .reset(fsmkb_reset),
    .io_ps2_clk(fsmkb_io_ps2_clk),
    .io_ps2_data(fsmkb_io_ps2_data),
    .io_key_bits_push(fsmkb_io_key_bits_push),
    .io_key_bits_release(fsmkb_io_key_bits_release),
    .io_key_bits_same(fsmkb_io_key_bits_same),
    .io_key_bits_cnt(fsmkb_io_key_bits_cnt),
    .io_key_bits_scancode_0(fsmkb_io_key_bits_scancode_0),
    .io_key_bits_scancode_1(fsmkb_io_key_bits_scancode_1),
    .io_key_bits_scancode_2(fsmkb_io_key_bits_scancode_2),
    .io_key_bits_scancode_3(fsmkb_io_key_bits_scancode_3)
  );
  Num2Seg num2seg0 ( // @[Scan2ASCII.scala 327:26]
    .io_in(num2seg0_io_in),
    .io_out(num2seg0_io_out)
  );
  Num2Seg num2seg1 ( // @[Scan2ASCII.scala 329:26]
    .io_in(num2seg1_io_in),
    .io_out(num2seg1_io_out)
  );
  Num2Seg num2seg3 ( // @[Scan2ASCII.scala 331:26]
    .io_in(num2seg3_io_in),
    .io_out(num2seg3_io_out)
  );
  assign io_shift = shift; // @[Scan2ASCII.scala 338:14]
  assign io_ctrl = ctrl; // @[Scan2ASCII.scala 339:13]
  assign io_alt = alt; // @[Scan2ASCII.scala 340:12]
  assign io_seg_scancode = num2seg0_io_out; // @[Scan2ASCII.scala 336:21]
  assign io_seg_asciicode = num2seg3_io_out; // @[Scan2ASCII.scala 334:22]
  assign io_seg_close = 16'hffff; // @[Scan2ASCII.scala 337:18]
  assign io_seg_times = num2seg1_io_out; // @[Scan2ASCII.scala 335:18]
  assign fsmkb_clock = clock;
  assign fsmkb_reset = reset;
  assign fsmkb_io_ps2_clk = io_ps2_clk; // @[Scan2ASCII.scala 37:22]
  assign fsmkb_io_ps2_data = io_ps2_data; // @[Scan2ASCII.scala 38:23]
  assign num2seg0_io_in = scancode; // @[Scan2ASCII.scala 328:20]
  assign num2seg1_io_in = times; // @[Scan2ASCII.scala 330:20]
  assign num2seg3_io_in = shift ? _GEN_296[7:0] : _GEN_296[15:8]; // @[Scan2ASCII.scala 325:21]
  always @(posedge clock) begin
    if (reset) begin // @[Scan2ASCII.scala 24:27]
      scancode <= 8'h0; // @[Scan2ASCII.scala 24:27]
    end else if (release_) begin // @[Scan2ASCII.scala 53:19]
      if (cnt != 2'h0) begin // @[Scan2ASCII.scala 54:27]
        scancode <= _GEN_3[7:0]; // @[Scan2ASCII.scala 55:22]
      end else begin
        scancode <= 8'h0; // @[Scan2ASCII.scala 60:22]
      end
    end else if (push & ~same) begin // @[Scan2ASCII.scala 46:25]
      scancode <= _GEN_3[7:0]; // @[Scan2ASCII.scala 48:18]
    end
    if (reset) begin // @[Scan2ASCII.scala 26:24]
      times <= 8'h0; // @[Scan2ASCII.scala 26:24]
    end else if (push & ~same) begin // @[Scan2ASCII.scala 46:25]
      times <= _times_T_1; // @[Scan2ASCII.scala 47:15]
    end
    if (reset) begin // @[Scan2ASCII.scala 27:24]
      shift <= 1'h0; // @[Scan2ASCII.scala 27:24]
    end else if (release_) begin // @[Scan2ASCII.scala 53:19]
      shift <= _GEN_34;
    end else if (push & ~same) begin // @[Scan2ASCII.scala 46:25]
      shift <= _GEN_3[7:0] == 8'h59 | _GEN_3[7:0] == 8'h12 | shift; // @[Scan2ASCII.scala 49:15]
    end
    if (reset) begin // @[Scan2ASCII.scala 28:23]
      ctrl <= 1'h0; // @[Scan2ASCII.scala 28:23]
    end else if (release_) begin // @[Scan2ASCII.scala 53:19]
      ctrl <= _GEN_35;
    end else if (push & ~same) begin // @[Scan2ASCII.scala 46:25]
      ctrl <= _GEN_3[7:0] == 8'h14 | ctrl; // @[Scan2ASCII.scala 50:14]
    end
    if (reset) begin // @[Scan2ASCII.scala 29:22]
      alt <= 1'h0; // @[Scan2ASCII.scala 29:22]
    end else if (release_) begin // @[Scan2ASCII.scala 53:19]
      alt <= _GEN_36;
    end else if (push & ~same) begin // @[Scan2ASCII.scala 46:25]
      alt <= _GEN_3[7:0] == 8'h11 | alt; // @[Scan2ASCII.scala 51:13]
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
  scancode = _RAND_0[7:0];
  _RAND_1 = {1{`RANDOM}};
  times = _RAND_1[7:0];
  _RAND_2 = {1{`RANDOM}};
  shift = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  ctrl = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  alt = _RAND_4[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
