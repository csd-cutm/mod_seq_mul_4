# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
import random


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start test")

    # Set clock
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Apply reset
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    # Run multiple tests
    for _ in range(5):
        a = random.randint(0, 15)
        b = random.randint(0, 15)
        expected = a * b

        dut.ui_in.value = (b << 4) | a  # ui_in = {b[3:0], a[3:0]}
        dut.uio_in.value = 1            # start = 1
        dut._log.info(f"Test: a={a}, b={b}, expected={expected}")

        await ClockCycles(dut.clk, 1)
        dut.uio_in.value = 0

        await ClockCycles(dut.clk, 20)  # Wait for operation

        result = dut.uo_out.value.integer
        assert result == expected, f"FAILED: a={a}, b={b}, got {result}, expected {expected}"
        dut._log.info(f"PASSED: result={result}")

    dut._log.info("All test cases passed.")
