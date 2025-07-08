`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
`timescale 1ns / 1ps

module tb ();

  // Dump the signals to a VCD file. You can view it with GTKWave or Surfer.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Instantiate your module under test
  tt_um_seq_mul user_project (
      .ui_in  (ui_in),     // Dedicated inputs (a[3:0], b[3:0])
      .uo_out (uo_out),    // Output: op[7:0]
      .uio_in (uio_in),    // Bidirectional inputs: start = uio_in[0]
      .uio_out(uio_out),   // not used
      .uio_oe (uio_oe),    // not used
      .ena    (ena),       // not used in this design
      .clk    (clk),       // clock
      .rst_n  (rst_n)      // active-low reset
  );

  // Clock generation: 100 KHz => 10us period
  always #5 clk = ~clk;

  // Test sequence
  initial begin
    // Initialize
    clk = 0;
    rst_n = 0;
    ena = 1;               // Just tie high
    ui_in = 8'b0;
    uio_in = 8'b0;

    // Hold reset for some cycles
    #100;
    rst_n = 1;

    // Example stimulus: a = 3, b = 5 => expect 15
    ui_in = {4'd5, 4'd3};  // b = 5, a = 3
    uio_in[0] = 1'b1;      // start = 1

    #2000; // wait for multiplication to complete

    // Second test: a = 9, b = 2 => expect 18
    ui_in = {4'd2, 4'd9};  // b = 2, a = 9
    uio_in[0] = 1'b1;

    #2000;

    // Done
    $finish;
  end

endmodule

