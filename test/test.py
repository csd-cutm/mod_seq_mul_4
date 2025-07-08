# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0


import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start test")

    # Setup clock: 100MHz (10ns period)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset the design
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)

    # Define test cases: (a, b, expected_result)
    test_cases = [
        (3, 4, 12),
        (7, 5, 35),
        (2, 2, 4),
        (8, 3, 24),
        (15, 15, 225)
    ]

    for a, b, expected in test_cases:
        dut._log.info(f"Test: a={a}, b={b}, expected={expected}")

        # Apply inputs
        dut.ui_in.value = (b << 4) | a   # ui_in[3:0] = a, ui_in[7:4] = b
        dut.uio_in.value = 1             # start = 1
        await ClockCycles(dut.clk, 1)
        dut.uio_in.value = 0             # start = 0

        # Wait sufficient cycles for sequential multiplier to complete
        await ClockCycles(dut.clk, 30)

        result = dut.uo_out.value.integer
        dut._log.info(f"Result: got {result}, expected {expected}")
        assert result == expected, f"FAILED: a={a}, b={b}, got {result}, expected {expected}"

    dut._log.info("All test cases passed!")

        
