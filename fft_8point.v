module fft_8point (
input [31:0] x0_real, x0_imag,
input [31:0] x1_real, x1_imag,
input [31:0] x2_real, x2_imag,
input [31:0] x3_real, x3_imag,
input [31:0] x4_real, x4_imag,
input [31:0] x5_real, x5_imag,
input [31:0] x6_real, x6_imag,
input [31:0] x7_real, x7_imag,
output [31:0] X0_real, X0_imag,
output [31:0] X1_real, X1_imag,
output [31:0] X2_real, X2_imag,
output [31:0] X3_real, X3_imag,
output [31:0] X4_real, X4_imag,
output [31:0] X5_real, X5_imag,
output [31:0] X6_real, X6_imag,
output [31:0] X7_real, X7_imag
);
// Twiddle factors (IEEE 754 single-precision)
parameter W2_0_REAL = 32'h3F800000; // 1.0
parameter W2_0_IMAG = 32'h00000000; // 0.0
parameter W2_1_REAL = 32'h3F800000; // 1.0
parameter W2_1_IMAG = 32'h00000000; // 0.0
parameter W4_0_REAL = 32'h3F800000; // 1.0
parameter W4_0_IMAG = 32'h00000000; // 0.0
parameter W4_1_REAL = 32'h00000000; // 0.0
parameter W4_1_IMAG = 32'hBF800000; // -1.0
parameter W8_0_REAL = 32'h3F800000; // 1.0
parameter W8_0_IMAG = 32'h00000000; // 0.0
parameter W8_1_REAL = 32'h3F3504F3; // 0.707107
parameter W8_1_IMAG = 32'hBF3504F3; // -0.707107
parameter W8_2_REAL = 32'h00000000; // 0.0
parameter W8_2_IMAG = 32'hBF800000; // -1.0
parameter W8_3_REAL = 32'hBF3504F3; // -0.707107
parameter W8_3_IMAG = 32'hBF3504F3; // -0.707107
// Stage 1
wire [31:0] S1_0_real, S1_0_imag, S1_1_real, S1_1_imag;
wire [31:0] S1_2_real, S1_2_imag, S1_3_real, S1_3_imag;
wire [31:0] S1_4_real, S1_4_imag, S1_5_real, S1_5_imag;
wire [31:0] S1_6_real, S1_6_imag, S1_7_real, S1_7_imag;// x(0) + x(4)
butterfly bfly1_0 (
.a_real(x0_real), .a_imag(x0_imag),
.b_real(x4_real), .b_imag(x4_imag),
.w_real(W2_0_REAL), .w_imag(W2_0_IMAG),
.y0_real(S1_0_real), .y0_imag(S1_0_imag),
.y1_real(S1_1_real), .y1_imag(S1_1_imag)
);
// x(2) + x(6)
butterfly bfly1_1 (
.a_real(x2_real), .a_imag(x2_imag),
.b_real(x6_real), .b_imag(x6_imag),
.w_real(W2_0_REAL), .w_imag(W2_0_IMAG),
.y0_real(S1_2_real), .y0_imag(S1_2_imag),
.y1_real(S1_3_real), .y1_imag(S1_3_imag)
);
// x(1) + x(5)
butterfly bfly1_2 (
.a_real(x1_real), .a_imag(x1_imag),
.b_real(x5_real), .b_imag(x5_imag),
.w_real(W2_0_REAL), .w_imag(W2_0_IMAG),
.y0_real(S1_4_real), .y0_imag(S1_4_imag),
.y1_real(S1_5_real), .y1_imag(S1_5_imag)
);
// x(3) + x(7)
butterfly bfly1_3 (
.a_real(x3_real), .a_imag(x3_imag),
.b_real(x7_real), .b_imag(x7_imag),
.w_real(W2_0_REAL), .w_imag(W2_0_IMAG),
.y0_real(S1_6_real), .y0_imag(S1_6_imag),
.y1_real(S1_7_real), .y1_imag(S1_7_imag)
);
// Stage 2
wire [31:0] S2_0_real, S2_0_imag, S2_1_real, S2_1_imag;
wire [31:0] S2_2_real, S2_2_imag, S2_3_real, S2_3_imag;
wire [31:0] S2_4_real, S2_4_imag, S2_5_real, S2_5_imag;
wire [31:0] S2_6_real, S2_6_imag, S2_7_real, S2_7_imag;
// S2_0 = S1_0 + S1_2
butterfly bfly2_0 (
.a_real(S1_0_real), .a_imag(S1_0_imag),
.b_real(S1_2_real), .b_imag(S1_2_imag),
.w_real(W4_0_REAL), .w_imag(W4_0_IMAG),
.y0_real(S2_0_real), .y0_imag(S2_0_imag),
.y1_real(S2_2_real), .y1_imag(S2_2_imag)
);
// S2_1 = S1_1 + S1_3 * W4^1
butterfly bfly2_1 (
.a_real(S1_1_real), .a_imag(S1_1_imag),
.b_real(S1_3_real), .b_imag(S1_3_imag),
.w_real(W4_1_REAL), .w_imag(W4_1_IMAG),
.y0_real(S2_1_real), .y0_imag(S2_1_imag),
.y1_real(S2_3_real), .y1_imag(S2_3_imag)
);
// S2_4 = S1_4 + S1_6
butterfly bfly2_2 (
.a_real(S1_4_real), .a_imag(S1_4_imag),
.b_real(S1_6_real), .b_imag(S1_6_imag),
.w_real(W4_0_REAL), .w_imag(W4_0_IMAG),
.y0_real(S2_4_real), .y0_imag(S2_4_imag),
.y1_real(S2_6_real), .y1_imag(S2_6_imag)
);
// S2_5 = S1_5 + S1_7 * W4^1
butterfly bfly2_3 (
.a_real(S1_5_real), .a_imag(S1_5_imag),
.b_real(S1_7_real), .b_imag(S1_7_imag),
.w_real(W4_1_REAL), .w_imag(W4_1_IMAG),
.y0_real(S2_5_real), .y0_imag(S2_5_imag),
.y1_real(S2_7_real), .y1_imag(S2_7_imag)
);
// Stage 3 (final output)
// X(0) = S2_0 + S2_4
butterfly bfly3_0 (
.a_real(S2_0_real), .a_imag(S2_0_imag),
.b_real(S2_4_real), .b_imag(S2_4_imag),
.w_real(W8_0_REAL), .w_imag(W8_0_IMAG),
.y0_real(X0_real), .y0_imag(X0_imag),
.y1_real(X4_real), .y1_imag(X4_imag)
);
// X(1) = S2_1 + S2_5 * W8^1
butterfly bfly3_1 (
.a_real(S2_1_real), .a_imag(S2_1_imag),
.b_real(S2_5_real), .b_imag(S2_5_imag),
.w_real(W8_1_REAL), .w_imag(W8_1_IMAG),
.y0_real(X1_real), .y0_imag(X1_imag),
.y1_real(X5_real), .y1_imag(X5_imag)
);
// X(2) = S2_2 + S2_6 * W8^2
butterfly bfly3_2 (
.a_real(S2_2_real), .a_imag(S2_2_imag),
.b_real(S2_6_real), .b_imag(S2_6_imag),
.w_real(W8_2_REAL), .w_imag(W8_2_IMAG),
.y0_real(X2_real), .y0_imag(X2_imag),
.y1_real(X6_real), .y1_imag(X6_imag)
);
// X(3) = S2_3 + S2_7 * W8^3
butterfly bfly3_3 (
.a_real(S2_3_real), .a_imag(S2_3_imag),
.b_real(S2_7_real), .b_imag(S2_7_imag),
.w_real(W8_3_REAL), .w_imag(W8_3_IMAG),
.y0_real(X3_real), .y0_imag(X3_imag),
.y1_real(X7_real), .y1_imag(X7_imag)
);
endmodule
