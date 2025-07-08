# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
import random


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start test")

    # Start 100 KHz clock (10 us period)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Apply reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    # Run multiple random tests
    for _ in range(5):
        a = random.randint(0, 15)
        b = random.randint(0, 15)
        expected = a * b

        # Set inputs
        dut.ui_in.value = (b << 4) | a  # ui_in[7:4]=b, ui_in[3:0]=a
        dut.uio_in.value = 1            # start pulse
        dut._log.info(f"Inputs: a={a}, b={b}, start=1")

        # Wait for start to be latched
        await ClockCycles(dut.clk, 1)
        dut.uio_in.value = 0            # deassert start

        # Wait enough cycles for operation to finish
        await ClockCycles(dut.clk, 20)

        result = dut.uo_out.value.integer
        dut._log.info(f"Output: {result}, Expected: {expected}")

        assert result == expected, f"FAILED: a={a}, b={b} => got {result}, expected {expected}"

    dut._log.info("All test cases passed.")
