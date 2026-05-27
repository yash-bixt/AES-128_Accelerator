module mix_columns(
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

wire [7:0] b0  = state_in[127:120];
wire [7:0] b1  = state_in[119:112];
wire [7:0] b2  = state_in[111:104];
wire [7:0] b3  = state_in[103:96];
wire [7:0] b4  = state_in[95:88];
wire [7:0] b5  = state_in[87:80];
wire [7:0] b6  = state_in[79:72];
wire [7:0] b7  = state_in[71:64];
wire [7:0] b8  = state_in[63:56];
wire [7:0] b9  = state_in[55:48];
wire [7:0] b10 = state_in[47:40];
wire [7:0] b11 = state_in[39:32];
wire [7:0] b12 = state_in[31:24];
wire [7:0] b13 = state_in[23:16];
wire [7:0] b14 = state_in[15:8];
wire [7:0] b15 = state_in[7:0];

wire [7:0] c0, c1, c2, c3;
wire [7:0] c4, c5, c6, c7;
wire [7:0] c8, c9, c10, c11;
wire [7:0] c12, c13, c14, c15;

// AES columns are consecutive 4-byte groups:
// Column 0 = b0,b1,b2,b3
// Column 1 = b4,b5,b6,b7
// Column 2 = b8,b9,b10,b11
// Column 3 = b12,b13,b14,b15

mix_single_column col0 (
    .s0(b0), .s1(b1), .s2(b2), .s3(b3),
    .m0(c0), .m1(c1), .m2(c2), .m3(c3)
);

mix_single_column col1 (
    .s0(b4), .s1(b5), .s2(b6), .s3(b7),
    .m0(c4), .m1(c5), .m2(c6), .m3(c7)
);

mix_single_column col2 (
    .s0(b8), .s1(b9), .s2(b10), .s3(b11),
    .m0(c8), .m1(c9), .m2(c10), .m3(c11)
);

mix_single_column col3 (
    .s0(b12), .s1(b13), .s2(b14), .s3(b15),
    .m0(c12), .m1(c13), .m2(c14), .m3(c15)
);

assign state_out = {
    c0, c1, c2, c3,
    c4, c5, c6, c7,
    c8, c9, c10, c11,
    c12, c13, c14, c15
};

endmodule


module mix_single_column(
    input  wire [7:0] s0,
    input  wire [7:0] s1,
    input  wire [7:0] s2,
    input  wire [7:0] s3,

    output wire [7:0] m0,
    output wire [7:0] m1,
    output wire [7:0] m2,
    output wire [7:0] m3
);

wire [7:0] s0_mul2, s1_mul2, s2_mul2, s3_mul2;
wire [7:0] s0_mul3, s1_mul3, s2_mul3, s3_mul3;

gf_mul2 mul2_0 (.in(s0), .out(s0_mul2));
gf_mul2 mul2_1 (.in(s1), .out(s1_mul2));
gf_mul2 mul2_2 (.in(s2), .out(s2_mul2));
gf_mul2 mul2_3 (.in(s3), .out(s3_mul2));

gf_mul3 mul3_0 (.in(s0), .out(s0_mul3));
gf_mul3 mul3_1 (.in(s1), .out(s1_mul3));
gf_mul3 mul3_2 (.in(s2), .out(s2_mul3));
gf_mul3 mul3_3 (.in(s3), .out(s3_mul3));

assign m0 = s0_mul2 ^ s1_mul3 ^ s2      ^ s3;
assign m1 = s0      ^ s1_mul2 ^ s2_mul3 ^ s3;
assign m2 = s0      ^ s1      ^ s2_mul2 ^ s3_mul3;
assign m3 = s0_mul3 ^ s1      ^ s2      ^ s3_mul2;

endmodule