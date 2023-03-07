/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NPC is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include "local-include/reg.h"
#include <cpu/cpu.h>
#include <cpu/ifetch.h>
#include <cpu/decode.h>

#include "svdpi.h"//DPI-C
#include "Vtop__Dpi.h"//DPI-C


static VerilatedContext* contextp = new VerilatedContext;
TOP_NAME* mycpu = new TOP_NAME{contextp};
bool trace_print = true;

#if WAVE_TRACE
#include "verilated.h"
#include "verilated_vcd_c.h"

static VerilatedVcdC* tfp = new VerilatedVcdC;

static void posedge_half_cycle() {
  mycpu->clk = 1; mycpu->eval();tfp->dump(contextp->time());contextp->timeInc(1);
}
static void negedge_half_cycle() {
  mycpu->clk = 0; mycpu->eval();tfp->dump(contextp->time());contextp->timeInc(1);
}

#else

static void posedge_half_cycle() {
  mycpu->clk = 1; mycpu->eval();
}
static void negedge_half_cycle() {
  mycpu->clk = 0; mycpu->eval();
}

#endif

static void single_cycle() {
  posedge_half_cycle();
  negedge_half_cycle();
}

static void reset(int n) {
  mycpu->rst = 1;
  while (n -- > 0) single_cycle();
  mycpu->clk = 1; mycpu->eval();
  mycpu->rst = 0; mycpu->eval();
}

void stopCPU(void)
{
  //difftest_skip_ref();
  npc_state.state = NPC_END;
  npc_state.halt_pc = mycpu->pc;
  npc_state.halt_ret = cpu_gpr[10];
}

int riscv64_exec_once(void) {
  mycpu->clk = 1; mycpu->eval();
  posedge_half_cycle();
  negedge_half_cycle();
  return 0;
}

int isa_exec_once(Decode *s) {
  riscv64_exec_once();
  s->pc = mycpu->pc;
  s->snpc = mycpu->pc + 4;
  s->dnpc = mycpu->dnpc;
  s->isa.inst.val = mycpu->inst;
  return 0;
}

void init_cpu(void)
{
  // IFNVBOARD(nvboard_bind_all_pins(mycpu));
  // IFNVBOARD(nvboard_init());
  #if WAVE_TRACE
  contextp->traceEverOn(true);
  mycpu->trace(tfp, 0);
  tfp->open("wave.vcd");
  #endif
  reset(10);
  IFDEF(CONFIG_DIFFTEST, riscv64_exec_once());
}

void exit_cpu(void)
{
  IFWAVE(tfp->close());
  delete contextp;
}