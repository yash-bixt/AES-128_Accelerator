module aes128_encrypt_top(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [127:0] plaintext,
    input wire [127:0] key,
    output wire [127:0] ciphertext,
    output wire done
);

aes128_encrypt_core core_inst(
    .clk(clk),
    .rst(rst),
    .start(start),
    .plaintext(plaintext),
    .key(key),
    .ciphertext(ciphertext),
    .done(done)
);

endmodule
