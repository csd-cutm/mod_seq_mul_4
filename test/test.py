# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0


# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start test")

    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Wait for reset to finish
    await ClockCycles(dut.clk, 5)

    test_vectors = [
        (3, 4, 12),
        (5, 5, 25),
        (9, 4, 36),
        (15, 15, 225),
        (0, 14, 0),
    ]

    for a, b, expected in test_vectors:
        dut._log.info(f"Test: a={a}, b={b}, expected={expected}")

        # Apply input: a in ui_in[3:0], b in ui_in[7:4]
        dut.ui_in.value = (b << 4) | a

        # Pulse start (uio_in[0])
        dut.uio_in.value = 1
        await ClockCycles(dut.clk, 1)
        dut.uio_in.value = 0

        # Wait enough clock cycles for the sequential multiplier to finish
        await ClockCycles(dut.clk, 40)

        result = dut.uo_out.value.integer
        dut._log.info(f"Result: got {result}, expected {expected}")
        assert result == expected, f"FAILED: a={a}, b={b}, got {result}, expected {expected}"

        
