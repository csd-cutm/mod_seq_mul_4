`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/

module tb ();

  // VCD dump setup
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Testbench signals
  reg clk;
  reg rst_n;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Instantiate DUT
  tt_um_seq_mul user_project (
      .ui_in  (ui_in),
      .uo_out (uo_out),
      .uio_in (uio_in),
      .uio_out(uio_out),
      .uio_oe (uio_oe),
      .clk    (clk),
      .rst_n  (rst_n)
  );

  // Clock generation (10us period => 100KHz)
  always #5 clk = ~clk;

  // Test sequence
  initial begin
    // Init
    clk = 0;
    rst_n = 0;
    ui_in = 8'b0;
    uio_in = 8'b0;

    // Apply reset
    #100;
    rst_n = 1;

    // Test 1: a = 3, b = 5 (expected op = 15)
    ui_in = {4'd5, 4'd3};  // b[3:0], a[3:0]
    uio_in[0] = 1;         // start = 1
    #100;
    uio_in[0] = 0;
    #2000;

    // Test 2: a = 7, b = 4 (expected op = 28)
    ui_in = {4'd4, 4'd7};
    uio_in[0] = 1;
    #100;
    uio_in[0] = 0;
    #2000;

    // Done
    $finish;
  end

endmodule
