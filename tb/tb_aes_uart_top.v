`timescale 1ns/1ps

module tb_aes_uart_top;

reg clk;
reg rst_n;
reg uart_rxd;
wire uart_txd;
wire [15:0] LED;

localparam CLK_PERIOD = 10;
localparam BAUD       = 115200;
localparam BIT_TIME   = 8680; // ns approx for 115200 baud

aes_uart_top dut (
    .CLK100MHZ(clk),
    .CPU_RESETN(rst_n),
    .UART_RXD(uart_rxd),
    .UART_TXD(uart_txd),
    .LED(LED)
);

always #(CLK_PERIOD/2) clk = ~clk;

task uart_send_byte;
    input [7:0] data;
    integer i;
    begin
        uart_rxd = 1'b0;      // start bit
        #(BIT_TIME);

        for (i = 0; i < 8; i = i + 1) begin
            uart_rxd = data[i];
            #(BIT_TIME);
        end

        uart_rxd = 1'b1;      // stop bit
        #(BIT_TIME);
    end
endtask
always @(posedge dut.tx_start) begin
    $write("%c", dut.tx_byte);
end

task uart_send_string;
    input [8*80-1:0] str;
    integer i;
    reg [7:0] ch;
    begin
        for (i = 79; i >= 0; i = i - 1) begin
            ch = str[i*8 +: 8];
            if (ch != 8'h00)
                uart_send_byte(ch);
        end
    end
endtask

task uart_read_byte;
    output [7:0] data;
    integer i;
    begin
        wait(uart_txd == 1'b0); // start bit
        #(BIT_TIME + BIT_TIME/2);

        for (i = 0; i < 8; i = i + 1) begin
            data[i] = uart_txd;
            #(BIT_TIME);
        end

        #(BIT_TIME); // stop bit
    end
endtask

integer k;
reg [7:0] rx_char;
reg [8*40-1:0] received;

initial begin
    clk = 0;
    rst_n = 0;
    uart_rxd = 1'b1;
    received = 0;

    #1000;
    rst_n = 1;
    #1000;

    $display("Sending encryption command...");

    uart_send_string("E 000102030405060708090A0B0C0D0E0F Cat");
    uart_send_byte(8'h0D);
#5000000; // wait 5 ms for FPGA to transmit result

    $display("");
    $display("Expected: C6720370F726CFBF8E04641F3B45CF850");

    #100000;

    $display("Sending decryption command...");

    received = 0;

    uart_send_string("D 000102030405060708090A0B0C0D0E0F 6720370F726CFBF8E04641F3B45CF850");
    uart_send_byte(8'h0D);

 #2000000; // wait 2 ms

    $display("");
    $display("Expected: PCat");

    #100000;
    $finish;
end

endmodule