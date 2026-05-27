module sub_word(
    input  wire [31:0] in,
    output wire [31:0] out
);

aes_sbox s0 (
    .in(in[31:24]),
    .out(out[31:24])
);

aes_sbox s1 (
    .in(in[23:16]),
    .out(out[23:16])
);

aes_sbox s2 (
    .in(in[15:8]),
    .out(out[15:8])
);

aes_sbox s3 (
    .in(in[7:0]),
    .out(out[7:0])
);

endmodule