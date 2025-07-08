`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/

`timescale 1ns/1ps

module tb;

    reg [7:0] ui_in;     // ui_in[3:0] = a, ui_in[7:4] = b
    reg [7:0] uio_in;    // uio_in[0] = start
    reg clk;
    reg rst_n;

    wire [7:0] uo_out;   // output: op
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    // Instantiate the design
    tt_um_seq_mul dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz clock

    // Simulation control
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);

        // Initial values
        clk     = 0;
        rst_n   = 0;
        ui_in   = 8'b0;
        uio_in  = 8'b0;

        // Reset
        #20;
        rst_n = 1;

        // Test 1: a = 3, b = 4 (3*4 = 12)
        ui_in[3:0] = 4'd3;   // a = 3
        ui_in[7:4] = 4'd4;   // b = 4
        uio_in[0]  = 1'b1;   // start pulse

        #10;
        uio_in[0] = 1'b0;    // de-assert start

        // Wait for operation to finish (4 cycles)
        #200;

        $display("Test1: a=3, b=4 => op = %d", uo_out);
        if (uo_out !== 8'd12)
            $display("FAIL: Expected 12, got %d", uo_out);
        else
            $display("PASS");

        // Add more test cases if needed...

        #100;
        $finish;
    end

endmodule
