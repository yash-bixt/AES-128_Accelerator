`timescale 1ns/1ps

module tb_command_parser;

reg clk;
reg rst;
reg [7:0] rx_byte;
reg rx_valid;

wire cmd_valid;
wire mode;
wire [127:0] data_block;

command_parser dut(
    .clk(clk),
    .rst(rst),
    .rx_byte(rx_byte),
    .rx_valid(rx_valid),
    .cmd_valid(cmd_valid),
    .mode(mode),
    .data_block(data_block)
);

always #5 clk = ~clk;

task send_byte;
    input [7:0] b;
    begin
        rx_byte = b;
        rx_valid = 1;
        #10;
        rx_valid = 0;
        #20;
    end
endtask

initial begin
    clk = 0;
    rst = 1;
    rx_byte = 0;
    rx_valid = 0;

    #30;
    rst = 0;

    send_byte("E");
    send_byte(" ");
    send_byte("C");
    send_byte("a");
    send_byte("t");
    send_byte(8'h0D);

    wait(cmd_valid);
    #10;

    $display("Mode = %0d", mode);
    $display("Block = %h", data_block);

    if (mode == 1'b0 && data_block == 128'h43617400000000000000000000000000)
        $display("ASCII PARSER PASS");
    else
        $display("ASCII PARSER FAIL");

    #50;
    rst = 1;
    #20;
    rst = 0;

    send_byte("D");
    send_byte(" ");
    send_byte("6"); send_byte("7"); send_byte("2"); send_byte("0");
    send_byte("3"); send_byte("7"); send_byte("0"); send_byte("F");
    send_byte("7"); send_byte("2"); send_byte("6"); send_byte("C");
    send_byte("F"); send_byte("B"); send_byte("F"); send_byte("8");
    send_byte("E"); send_byte("0"); send_byte("4"); send_byte("6");
    send_byte("4"); send_byte("1"); send_byte("F"); send_byte("3");
    send_byte("B"); send_byte("4"); send_byte("5"); send_byte("C");
    send_byte("F"); send_byte("8"); send_byte("5"); send_byte("0");
    send_byte(8'h0D);

    wait(cmd_valid);
    #10;

    $display("Mode = %0d", mode);
    $display("Block = %h", data_block);

    if (mode == 1'b1 && data_block == 128'h6720370F726CFBF8E04641F3B45CF850)
        $display("HEX PARSER PASS");
    else
        $display("HEX PARSER FAIL");

    #50;
    $finish;
end

endmodule