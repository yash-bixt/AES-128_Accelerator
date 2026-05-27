module rot_word(
    input wire [31:0] in,
    output wire [31:0] out
);

assign out = {in[23:0], in[31:24]};

endmodule
