import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles


outputs = [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 2, 0xe, 0x8, 0x6, 0xa, 0xf, 0x8, 0xc ]

@cocotb.test()
async def test_cpu_4bit(dut):
    dut._log.info("start")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.fork(clock.start())
    
    dut._log.info("reset")
    dut.rst.value = 1
    await ClockCycles(dut.clk, 10)
    dut.rst.value = 0

    dut._log.info("check all data outputs")
    for i in range(24):
        dut._log.info("check output {}".format(i))
        while 1 :
            await ClockCycles(dut.clk, 1)
            if dut.data_write.value == 0:
                assert int(dut.data_out.value) == outputs[i]
                break

