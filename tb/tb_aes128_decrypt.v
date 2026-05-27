`timescale 1ns/1ps

module tb_aes128_decrypt;

reg clk;
reg rst;
reg start;

reg  [127:0] ciphertext_in;
reg  [127:0] key;

wire [127:0] plaintext_out;
wire done;

localparam [127:0] EXPECTED = 128'h00112233445566778899AABBCCDDEEFF;

aes128_decrypt_top dut(
    .clk(clk),
    .rst(rst),
    .start(start),
    .ciphertext_in(ciphertext_in),
    .key(key),
    .plaintext_out(plaintext_out),
    .done(done)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    start = 0;

    ciphertext_in = 128'h69C4E0D86A7B0430D8CDB78070B4C55A;
    key           = 128'h000102030405060708090A0B0C0D0E0F;

    #30;
    rst = 0;

    #20;
    start = 1;

    #10;
    start = 0;

    wait(done == 1'b1);
    #10;

    $display("------------------------------------");
    $display("AES-128 Decryption Test");
    $display("Ciphertext = %h", ciphertext_in);
    $display("Key        = %h", key);
    $display("Plaintext  = %h", plaintext_out);
    $display("Expected   = %h", EXPECTED);

    if (plaintext_out == EXPECTED)
        $display("RESULT: PASS");
    else
        $display("RESULT: FAIL");

    $display("------------------------------------");

    #20;
    $finish;
end

endmodule