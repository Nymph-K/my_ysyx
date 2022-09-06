VSRC=./vsrc
VSRCS=$(shell find $(VSRC) -name "*.v")
CSRC=./csrc
CSRCS=$(shell find $(CSRC) -name "*.cpp")

all:$(VSRCS) $(CSRCS)
	@echo "**************all***************"
	verilator -Wall --cc --trace --exe --build $(CSRCS) $(VSRCS)

sim:all
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "**************sim***************"
	./obj_dir/Vtop

wave:wave.vcd
	@echo "**************wave***************"
	gtkwave wave.vcd

include ../Makefile
