module aes128_decrypt_top(
    input  wire         clk,
    input  wire         rst,
    input  wire         start,
    input  wire [127:0] ciphertext_in,
    input  wire [127:0] key,
    output wire [127:0] plaintext_out,
    output wire         done
);

aes128_decrypt_core core (
    .clk(clk),
    .rst(rst),
    .start(start),
    .ciphertext_in(ciphertext_in),
    .key(key),
    .plaintext_out(plaintext_out),
    .done(done)
);

endmodule