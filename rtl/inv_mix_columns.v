module inv_mix_columns(
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

inv_mix_single_column col0(.s0(b0), .s1(b1), .s2(b2), .s3(b3), .m0(c0), .m1(c1), .m2(c2), .m3(c3));
inv_mix_single_column col1(.s0(b4), .s1(b5), .s2(b6), .s3(b7), .m0(c4), .m1(c5), .m2(c6), .m3(c7));
inv_mix_single_column col2(.s0(b8), .s1(b9), .s2(b10), .s3(b11), .m0(c8), .m1(c9), .m2(c10), .m3(c11));
inv_mix_single_column col3(.s0(b12), .s1(b13), .s2(b14), .s3(b15), .m0(c12), .m1(c13), .m2(c14), .m3(c15));

assign state_out = {
    c0, c1, c2, c3,
    c4, c5, c6, c7,
    c8, c9, c10, c11,
    c12, c13, c14, c15
};

endmodule


module inv_mix_single_column(
    input  wire [7:0] s0,
    input  wire [7:0] s1,
    input  wire [7:0] s2,
    input  wire [7:0] s3,
    output wire [7:0] m0,
    output wire [7:0] m1,
    output wire [7:0] m2,
    output wire [7:0] m3
);

wire [7:0] s0_9, s0_11, s0_13, s0_14;
wire [7:0] s1_9, s1_11, s1_13, s1_14;
wire [7:0] s2_9, s2_11, s2_13, s2_14;
wire [7:0] s3_9, s3_11, s3_13, s3_14;

gf_mul9  a0(.in(s0), .out(s0_9));
gf_mul11 a1(.in(s0), .out(s0_11));
gf_mul13 a2(.in(s0), .out(s0_13));
gf_mul14 a3(.in(s0), .out(s0_14));

gf_mul9  b0(.in(s1), .out(s1_9));
gf_mul11 b1(.in(s1), .out(s1_11));
gf_mul13 b2(.in(s1), .out(s1_13));
gf_mul14 b3(.in(s1), .out(s1_14));

gf_mul9  c0(.in(s2), .out(s2_9));
gf_mul11 c1(.in(s2), .out(s2_11));
gf_mul13 c2(.in(s2), .out(s2_13));
gf_mul14 c3(.in(s2), .out(s2_14));

gf_mul9  d0(.in(s3), .out(s3_9));
gf_mul11 d1(.in(s3), .out(s3_11));
gf_mul13 d2(.in(s3), .out(s3_13));
gf_mul14 d3(.in(s3), .out(s3_14));

assign m0 = s0_14 ^ s1_11 ^ s2_13 ^ s3_9;
assign m1 = s0_9  ^ s1_14 ^ s2_11 ^ s3_13;
assign m2 = s0_13 ^ s1_9  ^ s2_14 ^ s3_11;
assign m3 = s0_11 ^ s1_13 ^ s2_9  ^ s3_14;

endmodule