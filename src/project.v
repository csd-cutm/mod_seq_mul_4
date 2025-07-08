/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_seq_mul (
    input  [7:0] ui_in,     // ui_in[3:0] = a, ui_in[7:4] = b
    output [7:0] uo_out,    // op[7:0]
    input  [7:0] uio_in,    // uio_in[0] = start
    output [7:0] uio_out,   // unused
    output [7:0] uio_oe,    // unused
    input        clk,
    input        rst_n
);

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    wire [3:0] a = ui_in[3:0];
    wire [3:0] b = ui_in[7:4];
    wire       start = uio_in[0];

    wire [7:0] op;

    seq_mul dut (
        .clk(clk),
        .start(start),
        .a(a),
        .b(b),
        .op(op)
    );

    assign uo_out = op;

endmodule

// Main sequential multiplier
top-level module: seq_mul.v

module seq_mul(clk, start, a, b, op);
    input [3:0] a, b;
    input clk, start;
    output [7:0] op;

    wire [8:0] p;
    wire [3:0] t, c, a1;
    wire ld, load, cy;
    wire [1:0] out;
    wire en, tc;

    reg4 rg1(a1, clk, start, a);

    assign t[0] = a1[0] & p[0];
    assign t[1] = a1[1] & p[0];
    assign t[2] = a1[2] & p[0];
    assign t[3] = a1[3] & p[0];

    adder_4bit ad(p[8:5], t, c, cy);

    Regbank_4bit rg2(clk, start, ld, cy, c, b, p);

    cnt4 cnt(out, 2'b00, load, en, clk, tc, 2'b11);
    pg pg1(start, tc, en, clk, 1'b0);

    assign load = start | tc;
    assign ld = en;
    assign op = p[8:1];
endmodule

module reg4(y, clk, en, a);
    input [3:0] a;
    output [3:0] y;
    input clk, en;

    fdce d1(y[0], clk, en, a[0]);
    fdce d2(y[1], clk, en, a[1]);
    fdce d3(y[2], clk, en, a[2]);
    fdce d4(y[3], clk, en, a[3]);
endmodule

module fdce(q, clk, ce, d);
    input d, clk, ce;
    output reg q;
    initial begin q = 0; end
    always @ (posedge clk) begin
        if (ce)
            q <= d;
    end
endmodule

module adder_4bit(a, b, sum, cy);
    input [3:0] a, b;
    output [3:0] sum;
    output cy;

    wire co1, co2, co3;

    fa m1(a[0], b[0], 1'b0, sum[0], co1);
    fa m2(a[1], b[1], co1, sum[1], co2);
    fa m3(a[2], b[2], co2, sum[2], co3);
    fa m4(a[3], b[3], co3, sum[3], cy);
endmodule

module fa(a, b, cin, sum, co);
    input a, b, cin;
    output sum, co;
    wire t1, t2, t4;
    ha X1(a, b, t1, t2);
    ha X2(cin, t1, sum, t4);
    assign co = t2 | t4;
endmodule

module ha(input a, b, output sum, co);
    assign sum = a ^ b;
    assign co = a & b;
endmodule

module Regbank_4bit(clk, start, ld, cy, c, b, p);
    input [3:0] c, b;
    output [8:0] p;
    input clk, start, ld, cy;
    wire en2;

    fdce f1(p[8], clk, ld, cy);

    fdce d1(p[7], clk, ld, c[3]);
    fdce d2(p[6], clk, ld, c[2]);
    fdce d3(p[5], clk, ld, c[1]);
    fdce d4(p[4], clk, ld, c[0]);

    mux_reg m1(clk, p[4], b[3], start, en2, p[3]);
    mux_reg m2(clk, p[3], b[2], start, en2, p[2]);
    mux_reg m3(clk, p[2], b[1], start, en2, p[1]);
    mux_reg m4(clk, p[1], b[0], start, en2, p[0]);

    assign en2 = start | ld;
endmodule

module mux_reg(clk, a, b, s, en, z);
    input clk, a, b, s, en;
    output z;
    wire y;

    mux m1(a, b, s, y);
    fdce m2(z, clk, en, y);
endmodule

module mux(A, B, S, Y);
    input A, B, S;
    output Y;
    assign Y = (S) ? B : A;
endmodule

module cnt4(out, data, load, en, clk, tc, lmt);
    output [1:0] out;
    output reg tc;
    input [1:0] data, lmt;
    input load, en, clk;
    reg [1:0] out;

    always @(posedge clk) begin
        if (load)
            out <= data;
        else if (en)
            out <= out + 1;
    end

    always @(posedge clk)
        tc <= (out == lmt);
endmodule

module pg(start, tc, q, clk, reset);
    input start, tc, clk, reset;
    output q;
    wire t1, t2;
    parameter vdd = 1'b1;
    parameter gnd = 1'b0;

    mux M1(t2, vdd, start, q);
    mux M2(q, gnd, tc, t1);
    DFF d2(t2, clk, reset, t1);
endmodule

module DFF(q, clk, reset, d);
    input d, clk, reset;
    output reg q;
    initial begin q = 0; end
    always @ (posedge clk) begin
        if (reset)
            q <= 0;
        else
            q <= d;
    end
endmodule


