# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/tb.v $(PWD)/cpu.v 

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = tb

# MODULE is the basename of the Python test file
MODULE = test

# include cocotb's make rules to take care of the simulator setup
include $(shell ~/.local/bin/cocotb-config --makefiles)/Makefile.sim

