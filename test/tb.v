`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
// SPDX-FileCopyrightText: © 2024 Tiny Tapeout
// SPDX-License-Identifier: Apache-2.0


module tb;

  reg clk = 0;
  reg rst_n = 0;
  reg [7:0] ui_in;     // a[3:0], b[3:0]
  reg [7:0] uio_in;    // start
  wire [7:0] uo_out;

  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  tt_um_seq_mul dut (
    .clk(clk),
    .rst_n(rst_n),
    .ui_in(ui_in),
    .uio_in(uio_in),
    .uo_out(uo_out),
    .uio_out(uio_out),
    .uio_oe(uio_oe)
  );

  // Generate clock
  always #5 clk = ~clk;

  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);

    #10;
    rst_n = 1;

    test(3, 4, 12);
    test(5, 5, 25);
    test(9, 4, 36);
    test(15, 15, 225);
    test(0, 14, 0);

    #100;
    $finish;
  end

  task test(input [3:0] a, input [3:0] b, input [7:0] expected);
    begin
      ui_in = {b, a};
      uio_in = 8'b00000001;  // start = 1
      #10;
      uio_in = 8'b00000000;

      #300;  // wait time

      $display("Test1: a=%0d, b=%0d => op = %0d", a, b, uo_out);
      if (uo_out !== expected) begin
        $display("FAIL: Expected %0d, got %0d", expected, uo_out);
      end else begin
        $display("PASS: a=%0d * b=%0d = %0d", a, b, uo_out);
      end
    end
  endtask

endmodule


