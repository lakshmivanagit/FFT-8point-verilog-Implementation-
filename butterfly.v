module butterfly (
input [31:0] a_real, a_imag,
input [31:0] b_real, b_imag,
input [31:0] w_real, w_imag,
output [31:0] y0_real, y0_imag,
output [31:0] y1_real, y1_imag
);
wire [31:0] bw_real, bw_imag;
wire [31:0] temp1, temp2, temp3, temp4;
// Complex multiplication: bw = b * w
// bw_real = b_real * w_real - b_imag * w_imag
fp_multiplier mult1 (.a(b_real), .b(w_real), .result(temp1)); // b_real * w_real
fp_multiplier mult2 (.a(b_imag), .b(w_imag), .result(temp2)); // b_imag * w_imag
fp_adder_combined sub1 (.a(temp1), .b({~temp2[31], temp2[30:0]}), .result(bw_real)); // temp1 - temp
// bw_imag = b_real * w_imag + b_imag * w_real
fp_multiplier mult3 (.a(b_real), .b(w_imag), .result(temp3)); // b_real * w_imag
fp_multiplier mult4 (.a(b_imag), .b(w_real), .result(temp4)); // b_imag * w_real
fp_adder_combined add1 (.a(temp3), .b(temp4), .result(bw_imag)); // temp3 + temp4
// y0 = a + bw
fp_adder_combined add2 (.a(a_real), .b(bw_real), .result(y0_real));
fp_adder_combined add3 (.a(a_imag), .b(bw_imag), .result(y0_imag));
// y1 = a - bw
fp_adder_combined sub2 (.a(a_real), .b({~bw_real[31], bw_real[30:0]}), .result(y1_real));
fp_adder_combined sub3 (.a(a_imag), .b({~bw_imag[31], bw_imag[30:0]}), .result(y1_imag));
endmodule
