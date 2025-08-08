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
module fp_multiplier (
input [31:0] a, // IEEE 754 float A
input [31:0] b, // IEEE 754 float B
output [31:0] result // IEEE 754 float result
);
// Extract fields
wire sign_a = a[31];
wire sign_b = b[31];
wire [7:0] exp_a = a[30:23];
wire [7:0] exp_b = b[30:23];
wire [22:0] frac_a = a[22:0];
wire [22:0] frac_b = b[22:0];
// Add implicit leading 1
wire [23:0] mant_a = (exp_a == 0) ? {1'b0, frac_a} : {1'b1, frac_a};
wire [23:0] mant_b = (exp_b == 0) ? {1'b0, frac_b} : {1'b1, frac_b};
// Multiply mantissas (24 x 24 = 48 bits)
wire [47:0] mant_mult = mant_a * mant_b;
// Add exponents and subtract bias
wire [9:0] exp_sum = exp_a + exp_b - 127;
// Normalize result
wire norm_shift = mant_mult[47]; // If MSB is 1, shift right
wire [22:0] final_mant = norm_shift ? mant_mult[46:24] :
mant_mult[45:23];
wire [7:0] final_exp = norm_shift ? exp_sum + 1 : exp_sum;
// Compute final sign
wire sign_result = sign_a ^ sign_b;
// Handle special cases (zero input)
wire zero_a = (a[30:0] == 31'b0);
wire zero_b = (b[30:0] == 31'b0);
wire is_zero = zero_a | zero_b;
// Result construction
assign result = is_zero ? 32'b0 : {sign_result, final_exp, final_mant};
endmodule
module fp_adder_combined(
input [31:0] a,
input [31:0] b,
output [31:0] result
);
// Field extraction
wire sign_a = a[31];
wire sign_b = b[31];
wire [7:0] exp_a = a[30:23];
wire [7:0] exp_b = b[30:23];
wire [22:0] frac_a = a[22:0];
wire [22:0] frac_b = b[22:0];
// Hidden bit
wire [23:0] mant_a = (exp_a == 0) ? {1'b0, frac_a} : {1'b1, frac_a};
wire [23:0] mant_b = (exp_b == 0) ? {1'b0, frac_b} : {1'b1, frac_b};
// Exponent alignment
wire [7:0] exp_diff = (exp_a > exp_b) ? (exp_a - exp_b) : (exp_b - exp_a);
wire [23:0] mant_a_shifted = (exp_b > exp_a) ? (mant_a >> exp_diff) : mant_a;
wire [23:0] mant_b_shifted = (exp_a > exp_b) ? (mant_b >> exp_diff) : mant_b;
wire [7:0] max_exp = (exp_a > exp_b) ? exp_a : exp_b;
reg [31:0] result_reg;
assign result = result_reg;
// Internal registers
integer i;
reg [4:0] shift_amt;
reg [23:0] norm_mant;
reg [7:0] norm_exp;
reg [24:0] mant_sum;
reg [22:0] final_frac;
reg [7:0] final_exp;
reg sign_out;
reg [24:0] diff;
reg [23:0] mant_large, mant_small;
reg a_gt_b;
always @(*) begin
if (sign_a == sign_b) begin
// Case I: Same sign (Add)
mant_sum = {1'b0, mant_a_shifted} + {1'b0, mant_b_shifted};
if (mant_sum[24]) begin
final_exp = max_exp + 1;
final_frac = mant_sum[23:1];
end else begin
final_exp = max_exp;
final_frac = mant_sum[22:0];
end
sign_out = sign_a;
result_reg = {sign_out, final_exp, final_frac};
end else begin
// Case II: Different sign (Subtract)
a_gt_b = (mant_a_shifted >= mant_b_shifted);
mant_large = a_gt_b ? mant_a_shifted : mant_b_shifted;
mant_small = a_gt_b ? mant_b_shifted : mant_a_shifted;
sign_out = a_gt_b ? sign_a : sign_b;
diff = {1'b0, mant_large} - {1'b0, mant_small};
// Normalize
if (diff[23:0] == 0) begin
norm_mant = 0;
norm_exp = 0;
end else begin
shift_amt = 0;
for (i = 23; i >= 0; i = i - 1) begin
if (diff[i]) begin
shift_amt = 23 - i;
// disable_found = 1'b1;
i = -1; // break manually
end
end
norm_mant = diff[23:0] << shift_amt;
norm_exp = max_exp - shift_amt;
end
result_reg = {sign_out, norm_exp, norm_mant[22:0]};
end
end
endmodule
