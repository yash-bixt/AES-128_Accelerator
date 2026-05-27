module gf_mul3(
    input wire [7:0] in,
    output wire [7:0] out
);

wire [7:0] mul2;

gf_mul2 m2(
    .in(in),
    .out(mul2)
);

assign out = mul2 ^ in;

endmodule
