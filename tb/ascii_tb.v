`timescale 1ns/1ps

module tb_ascii_aes;

reg clk;
reg rst;
reg start;
reg mode;

reg [127:0] data_in;
reg [127:0] key;

wire [127:0] data_out;
wire done;
wire busy;

// ASCII unpack wires
wire [7:0] c0;
wire [7:0] c1;
wire [7:0] c2;
wire [7:0] c3;
wire [7:0] c4;
wire [7:0] c5;
wire [7:0] c6;
wire [7:0] c7;
wire [7:0] c8;
wire [7:0] c9;
wire [7:0] c10;
wire [7:0] c11;
wire [7:0] c12;
wire [7:0] c13;
wire [7:0] c14;
wire [7:0] c15;

// AES key
localparam [127:0] KEY =
    128'h000102030405060708090A0B0C0D0E0F;

// Test word: "Cat"
//
// ASCII:
// C = 43
// a = 61
// t = 74

wire [127:0] ascii_block;

ascii_pack_128 packer (
    .char0 (8'h43), // C
    .char1 (8'h61), // a
    .char2 (8'h74), // t
    .char3 (8'h00),
    .char4 (8'h00),
    .char5 (8'h00),
    .char6 (8'h00),
    .char7 (8'h00),
    .char8 (8'h00),
    .char9 (8'h00),
    .char10(8'h00),
    .char11(8'h00),
    .char12(8'h00),
    .char13(8'h00),
    .char14(8'h00),
    .char15(8'h00),

    .block_out(ascii_block)
);

aes128_core DUT (
    .clk(clk),
    .rst(rst),
    .start(start),
    .mode(mode),
    .data_in(data_in),
    .key(KEY),
    .data_out(data_out),
    .done(done),
    .busy(busy)
);

ascii_unpack_128 unpacker (
    .block_in(data_out),

    .char0(c0),
    .char1(c1),
    .char2(c2),
    .char3(c3),
    .char4(c4),
    .char5(c5),
    .char6(c6),
    .char7(c7),
    .char8(c8),
    .char9(c9),
    .char10(c10),
    .char11(c11),
    .char12(c12),
    .char13(c13),
    .char14(c14),
    .char15(c15)
);

// Clock generation
always #5 clk = ~clk;

reg [127:0] saved_cipher;

initial begin

    clk   = 0;
    rst   = 1;
    start = 0;
    mode  = 0;
    data_in = 0;

    #30;
    rst = 0;

    //------------------------------------
    // ENCRYPT ASCII
    //------------------------------------

    data_in = ascii_block;

    mode = 1'b0; // Encrypt

    #20;
    start = 1;

    #10;
    start = 0;

    wait(done == 1'b1);

    saved_cipher = data_out;

    #20;

    $display("------------------------------------");
    $display("ASCII AES ENCRYPTION");
    $display("Original ASCII = Cat");
    $display("Packed Block   = %h", ascii_block);
    $display("Ciphertext     = %h", data_out);
    $display("------------------------------------");

    //------------------------------------
    // DECRYPT BACK
    //------------------------------------

    data_in = saved_cipher;

    mode = 1'b1; // Decrypt

    #20;
    start = 1;

    #10;
    start = 0;

    wait(done == 1'b1);

    #20;

    $display("------------------------------------");
    $display("ASCII AES DECRYPTION");
    $display("Decrypted Block = %h", data_out);

    $write("Recovered Text  = ");

    if (c0  != 8'h00) $write("%c", c0);
    if (c1  != 8'h00) $write("%c", c1);
    if (c2  != 8'h00) $write("%c", c2);
    if (c3  != 8'h00) $write("%c", c3);
    if (c4  != 8'h00) $write("%c", c4);
    if (c5  != 8'h00) $write("%c", c5);
    if (c6  != 8'h00) $write("%c", c6);
    if (c7  != 8'h00) $write("%c", c7);
    if (c8  != 8'h00) $write("%c", c8);
    if (c9  != 8'h00) $write("%c", c9);
    if (c10 != 8'h00) $write("%c", c10);
    if (c11 != 8'h00) $write("%c", c11);
    if (c12 != 8'h00) $write("%c", c12);
    if (c13 != 8'h00) $write("%c", c13);
    if (c14 != 8'h00) $write("%c", c14);
    if (c15 != 8'h00) $write("%c", c15);

    $display("");

    if (c0 == "C" &&
        c1 == "a" &&
        c2 == "t")
    begin
        $display("RESULT: PASS");
    end
    else begin
        $display("RESULT: FAIL");
    end

    $display("------------------------------------");

    #50;
    $finish;

end

endmodule