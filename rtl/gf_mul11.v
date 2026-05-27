module gf_mul11(input wire [7:0] in, output wire [7:0] out);
wire [7:0] x2, x4, x8;
gf_mul2 m2a(.in(in), .out(x2));
gf_mul2 m2b(.in(x2), .out(x4));
gf_mul2 m2c(.in(x4), .out(x8));
assign out = x8 ^ x2 ^ in;
endmodule