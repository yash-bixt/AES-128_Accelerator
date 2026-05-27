`timescale 1ns/1ps

module tb_aes128_core;

reg clk;
reg rst;
reg start;
reg mode;

reg [127:0] data_in;
reg [127:0] key;

wire [127:0] data_out;
wire done;
wire busy;

localparam [127:0] PLAIN  = 128'h00112233445566778899AABBCCDDEEFF;
localparam [127:0] KEY    = 128'h000102030405060708090A0B0C0D0E0F;
localparam [127:0] CIPHER = 128'h69C4E0D86A7B0430D8CDB78070B4C55A;

aes128_core dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .mode(mode),
    .data_in(data_in),
    .key(key),
    .data_out(data_out),
    .done(done),
    .busy(busy)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    start = 0;
    mode = 0;
    data_in = 0;
    key = KEY;

    #30;
    rst = 0;

    // Encryption test
    data_in = PLAIN;
    mode = 1'b0;

    #20;
    start = 1;
    #10;
    start = 0;

    wait(done == 1'b1);
    #10;

    $display("------------------------------------");
    $display("AES-128 Combined Core Encryption Test");
    $display("Input      = %h", PLAIN);
    $display("Output     = %h", data_out);
    $display("Expected   = %h", CIPHER);

    if (data_out == CIPHER)
        $display("ENCRYPT RESULT: PASS");
    else
        $display("ENCRYPT RESULT: FAIL");

    // Decryption test
    #30;
    data_in = CIPHER;
    mode = 1'b1;

    #20;
    start = 1;
    #10;
    start = 0;

    wait(done == 1'b1);
    #10;

    $display("------------------------------------");
    $display("AES-128 Combined Core Decryption Test");
    $display("Input      = %h", CIPHER);
    $display("Output     = %h", data_out);
    $display("Expected   = %h", PLAIN);

    if (data_out == PLAIN)
        $display("DECRYPT RESULT: PASS");
    else
        $display("DECRYPT RESULT: FAIL");

    $display("------------------------------------");

    #30;
    $finish;
end

endmodule