`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a VCD file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Inputs and outputs exactly as in your main module
  reg clk;
  reg start;
  reg [3:0] a, b;
  wire [7:0] op;

  // Instantiate the multiplier module
  seq_mul uut (
    .clk(clk),
    .start(start),
    .a(a),
    .b(b),
    .op(op)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk; // 10ns period

  // Stimulus
  initial begin
    // Initialize
    start = 0;
    a = 4'd0;
    b = 4'd0;

    // Test case 1: 3 × 5 = 15
    #10 a = 4'd3; b = 4'd5; start = 1;
    #10 start = 0;
    #60;

    // Test case 2: 9 × 2 = 18
    a = 4'd9; b = 4'd2; start = 1;
    #10 start = 0;
    #60;

    // Test case 3: 7 × 7 = 49
    a = 4'd7; b = 4'd7; start = 1;
    #10 start = 0;
    #60;

    $finish;
  end

endmodule

