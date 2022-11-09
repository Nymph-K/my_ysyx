module VgaCtrl(
  input         clock,
  input         reset,
  input  [23:0] io_vga_data,
  output [9:0]  io_h_addr,
  output [9:0]  io_v_addr,
  output        io_h_sync,
  output        io_v_sync,
  output        io_valid,
  output [7:0]  io_vag_r,
  output [7:0]  io_vag_g,
  output [7:0]  io_vag_b
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
`endif // RANDOMIZE_REG_INIT
  reg [9:0] x_cnt; // @[VgaCtrl.scala 26:24]
  reg [9:0] y_cnt; // @[VgaCtrl.scala 27:24]
  wire [9:0] _y_cnt_T_1 = y_cnt + 10'h1; // @[VgaCtrl.scala 33:28]
  wire [9:0] _x_cnt_T_1 = x_cnt + 10'h1; // @[VgaCtrl.scala 36:24]
  wire  h_valid = 10'h90 < x_cnt & x_cnt <= 10'h310; // @[VgaCtrl.scala 49:37]
  wire  v_valid = 10'h23 < y_cnt & y_cnt <= 10'h203; // @[VgaCtrl.scala 50:37]
  wire [9:0] _h_addr_T_2 = x_cnt - 10'h90; // @[VgaCtrl.scala 53:42]
  wire [9:0] _h_addr_T_4 = _h_addr_T_2 - 10'h1; // @[VgaCtrl.scala 53:53]
  wire [9:0] _v_addr_T_2 = y_cnt - 10'h23; // @[VgaCtrl.scala 54:42]
  wire [9:0] _v_addr_T_4 = _v_addr_T_2 - 10'h1; // @[VgaCtrl.scala 54:53]
  assign io_h_addr = h_valid ? _h_addr_T_4 : 10'h0; // @[VgaCtrl.scala 53:18]
  assign io_v_addr = v_valid ? _v_addr_T_4 : 10'h0; // @[VgaCtrl.scala 54:18]
  assign io_h_sync = x_cnt > 10'h60; // @[VgaCtrl.scala 47:25]
  assign io_v_sync = y_cnt > 10'h2; // @[VgaCtrl.scala 48:25]
  assign io_valid = h_valid & v_valid; // @[VgaCtrl.scala 51:22]
  assign io_vag_r = io_vga_data[23:16]; // @[VgaCtrl.scala 61:28]
  assign io_vag_g = io_vga_data[15:8]; // @[VgaCtrl.scala 62:28]
  assign io_vag_b = io_vga_data[7:0]; // @[VgaCtrl.scala 63:28]
  always @(posedge clock) begin
    if (reset) begin // @[VgaCtrl.scala 26:24]
      x_cnt <= 10'h1; // @[VgaCtrl.scala 26:24]
    end else if (x_cnt == 10'h320) begin // @[VgaCtrl.scala 28:29]
      x_cnt <= 10'h1; // @[VgaCtrl.scala 29:15]
    end else begin
      x_cnt <= _x_cnt_T_1; // @[VgaCtrl.scala 36:15]
    end
    if (reset) begin // @[VgaCtrl.scala 27:24]
      y_cnt <= 10'h1; // @[VgaCtrl.scala 27:24]
    end else if (x_cnt == 10'h320) begin // @[VgaCtrl.scala 28:29]
      if (y_cnt == 10'h20d) begin // @[VgaCtrl.scala 30:34]
        y_cnt <= 10'h1; // @[VgaCtrl.scala 31:19]
      end else begin
        y_cnt <= _y_cnt_T_1; // @[VgaCtrl.scala 33:19]
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
  x_cnt = _RAND_0[9:0];
  _RAND_1 = {1{`RANDOM}};
  y_cnt = _RAND_1[9:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module ReadImg(
  input         clock,
  input  [9:0]  io_h_addr,
  input  [9:0]  io_v_addr,
  output [23:0] io_vga_data
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_GARBAGE_ASSIGN
  reg [7:0] img_data [0:921653]; // @[ReadImg.scala 18:23]
  wire  img_data_r_data_MPORT_en; // @[ReadImg.scala 18:23]
  wire [19:0] img_data_r_data_MPORT_addr; // @[ReadImg.scala 18:23]
  wire [7:0] img_data_r_data_MPORT_data; // @[ReadImg.scala 18:23]
  wire  img_data_g_data_MPORT_en; // @[ReadImg.scala 18:23]
  wire [19:0] img_data_g_data_MPORT_addr; // @[ReadImg.scala 18:23]
  wire [7:0] img_data_g_data_MPORT_data; // @[ReadImg.scala 18:23]
  wire  img_data_b_data_MPORT_en; // @[ReadImg.scala 18:23]
  wire [19:0] img_data_b_data_MPORT_addr; // @[ReadImg.scala 18:23]
  wire [7:0] img_data_b_data_MPORT_data; // @[ReadImg.scala 18:23]
  wire [11:0] _r_data_T = io_h_addr * 2'h3; // @[ReadImg.scala 23:39]
  wire [9:0] _r_data_T_2 = 10'h1df - io_v_addr; // @[ReadImg.scala 23:54]
  wire [19:0] _r_data_T_3 = _r_data_T_2 * 10'h280; // @[ReadImg.scala 23:67]
  wire [21:0] _r_data_T_4 = _r_data_T_3 * 2'h3; // @[ReadImg.scala 23:75]
  wire [21:0] _GEN_0 = {{10'd0}, _r_data_T}; // @[ReadImg.scala 23:45]
  wire [21:0] _r_data_T_6 = _GEN_0 + _r_data_T_4; // @[ReadImg.scala 23:45]
  wire [21:0] _r_data_T_8 = _r_data_T_6 + 22'h36; // @[ReadImg.scala 23:81]
  wire [21:0] _r_data_T_10 = _r_data_T_8 + 22'h2; // @[ReadImg.scala 23:88]
  wire [21:0] _g_data_T_10 = _r_data_T_8 + 22'h1; // @[ReadImg.scala 24:88]
  wire [22:0] _b_data_T_9 = {{1'd0}, _r_data_T_8}; // @[ReadImg.scala 25:88]
  wire [7:0] g_data = img_data_g_data_MPORT_data;
  wire [7:0] b_data = img_data_b_data_MPORT_data;
  wire [15:0] _io_vga_data_T = {g_data,b_data}; // @[Cat.scala 31:58]
  wire [7:0] r_data = img_data_r_data_MPORT_data;
  assign img_data_r_data_MPORT_en = 1'h1;
  assign img_data_r_data_MPORT_addr = _r_data_T_10[19:0];
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign img_data_r_data_MPORT_data = img_data[img_data_r_data_MPORT_addr]; // @[ReadImg.scala 18:23]
  `else
  assign img_data_r_data_MPORT_data = img_data_r_data_MPORT_addr >= 20'he1036 ? _RAND_0[7:0] :
    img_data[img_data_r_data_MPORT_addr]; // @[ReadImg.scala 18:23]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign img_data_g_data_MPORT_en = 1'h1;
  assign img_data_g_data_MPORT_addr = _g_data_T_10[19:0];
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign img_data_g_data_MPORT_data = img_data[img_data_g_data_MPORT_addr]; // @[ReadImg.scala 18:23]
  `else
  assign img_data_g_data_MPORT_data = img_data_g_data_MPORT_addr >= 20'he1036 ? _RAND_1[7:0] :
    img_data[img_data_g_data_MPORT_addr]; // @[ReadImg.scala 18:23]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign img_data_b_data_MPORT_en = 1'h1;
  assign img_data_b_data_MPORT_addr = _b_data_T_9[19:0];
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign img_data_b_data_MPORT_data = img_data[img_data_b_data_MPORT_addr]; // @[ReadImg.scala 18:23]
  `else
  assign img_data_b_data_MPORT_data = img_data_b_data_MPORT_addr >= 20'he1036 ? _RAND_2[7:0] :
    img_data[img_data_b_data_MPORT_addr]; // @[ReadImg.scala 18:23]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign io_vga_data = {r_data,_io_vga_data_T}; // @[Cat.scala 31:58]
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
  integer initvar;
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
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_0 = {1{`RANDOM}};
  _RAND_1 = {1{`RANDOM}};
  _RAND_2 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
  `endif // RANDOMIZE
  $readmemh("./resource/picture.bmp_hex.txt", img_data);
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module VgaImg(
  input        clock,
  input        reset,
  output       io_h_sync,
  output       io_v_sync,
  output       io_valid,
  output [7:0] io_vag_r,
  output [7:0] io_vag_g,
  output [7:0] io_vag_b
);
  wire  vgactrl_clock; // @[VgaImg.scala 15:25]
  wire  vgactrl_reset; // @[VgaImg.scala 15:25]
  wire [23:0] vgactrl_io_vga_data; // @[VgaImg.scala 15:25]
  wire [9:0] vgactrl_io_h_addr; // @[VgaImg.scala 15:25]
  wire [9:0] vgactrl_io_v_addr; // @[VgaImg.scala 15:25]
  wire  vgactrl_io_h_sync; // @[VgaImg.scala 15:25]
  wire  vgactrl_io_v_sync; // @[VgaImg.scala 15:25]
  wire  vgactrl_io_valid; // @[VgaImg.scala 15:25]
  wire [7:0] vgactrl_io_vag_r; // @[VgaImg.scala 15:25]
  wire [7:0] vgactrl_io_vag_g; // @[VgaImg.scala 15:25]
  wire [7:0] vgactrl_io_vag_b; // @[VgaImg.scala 15:25]
  wire  readimg_clock; // @[VgaImg.scala 24:25]
  wire [9:0] readimg_io_h_addr; // @[VgaImg.scala 24:25]
  wire [9:0] readimg_io_v_addr; // @[VgaImg.scala 24:25]
  wire [23:0] readimg_io_vga_data; // @[VgaImg.scala 24:25]
  VgaCtrl vgactrl ( // @[VgaImg.scala 15:25]
    .clock(vgactrl_clock),
    .reset(vgactrl_reset),
    .io_vga_data(vgactrl_io_vga_data),
    .io_h_addr(vgactrl_io_h_addr),
    .io_v_addr(vgactrl_io_v_addr),
    .io_h_sync(vgactrl_io_h_sync),
    .io_v_sync(vgactrl_io_v_sync),
    .io_valid(vgactrl_io_valid),
    .io_vag_r(vgactrl_io_vag_r),
    .io_vag_g(vgactrl_io_vag_g),
    .io_vag_b(vgactrl_io_vag_b)
  );
  ReadImg readimg ( // @[VgaImg.scala 24:25]
    .clock(readimg_clock),
    .io_h_addr(readimg_io_h_addr),
    .io_v_addr(readimg_io_v_addr),
    .io_vga_data(readimg_io_vga_data)
  );
  assign io_h_sync = vgactrl_io_h_sync; // @[VgaImg.scala 17:15]
  assign io_v_sync = vgactrl_io_v_sync; // @[VgaImg.scala 18:15]
  assign io_valid = vgactrl_io_valid; // @[VgaImg.scala 19:14]
  assign io_vag_r = vgactrl_io_vag_r; // @[VgaImg.scala 20:14]
  assign io_vag_g = vgactrl_io_vag_g; // @[VgaImg.scala 21:14]
  assign io_vag_b = vgactrl_io_vag_b; // @[VgaImg.scala 22:14]
  assign vgactrl_clock = clock;
  assign vgactrl_reset = reset;
  assign vgactrl_io_vga_data = readimg_io_vga_data; // @[VgaImg.scala 16:25]
  assign readimg_clock = clock;
  assign readimg_io_h_addr = vgactrl_io_h_addr; // @[VgaImg.scala 25:23]
  assign readimg_io_v_addr = vgactrl_io_v_addr; // @[VgaImg.scala 26:23]
endmodule
