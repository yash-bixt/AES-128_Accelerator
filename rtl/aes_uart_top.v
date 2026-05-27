module aes_uart_top #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 115200
)(
    input  wire CLK100MHZ,
    input  wire CPU_RESETN,

    input  wire UART_RXD,
    output wire UART_TXD,

    output wire [15:0] LED
);

// IMPORTANT:
// This top assumes these AES files are already in your Vivado project:
// aes128_core.v
// aes128_encrypt_core.v
// aes128_decrypt_core.v
// key_expansion.v
// all AES transform modules.

wire clk = CLK100MHZ;
wire rst = ~CPU_RESETN;

wire [7:0] rx_byte;
wire rx_valid;

uart_rx #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD(BAUD)
) RX (
    .clk(clk),
    .rst(rst),
    .rx(UART_RXD),
    .data_out(rx_byte),
    .data_valid(rx_valid)
);

wire cmd_valid;
wire cmd_mode;
wire [127:0] cmd_block;
wire [127:0] key_block;

command_parser PARSER (
    .clk(clk),
    .rst(rst),
    .rx_byte(rx_byte),
    .rx_valid(rx_valid),
    .cmd_valid(cmd_valid),
    .mode(cmd_mode),
    .data_block(cmd_block),
    .key_block(key_block)
);




reg aes_start;
reg [127:0] aes_key;
reg aes_mode;
reg [127:0] aes_data;

wire [127:0] aes_result;
wire aes_done;
wire aes_busy;

aes128_core AES_CORE (
    .clk(clk),
    .rst(rst),
    .start(aes_start),
    .mode(aes_mode),
    .data_in(aes_data),
    .data_out(aes_result),
    .done(aes_done),
    .busy(aes_busy),
    .key(aes_key)
);

wire [7:0] tx_byte;
wire tx_start;
wire tx_busy;
wire tx_done;

uart_tx #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD(BAUD)
) TX (
    .clk(clk),
    .rst(rst),
    .data_in(tx_byte),
    .start(tx_start),
    .tx(UART_TXD),
    .busy(tx_busy),
    .done(tx_done)
);

reg sender_start;

wire sender_busy;
wire sender_done;

uart_result_sender SENDER (
    .clk(clk),
    .rst(rst),
    .start(sender_start),
    .mode(aes_mode),
    .result_block(aes_result),
    .tx_byte(tx_byte),
    .tx_start(tx_start),
    .tx_busy(tx_busy),
    .tx_done(tx_done),
    .busy(sender_busy),
    .done(sender_done)
);

localparam IDLE      = 3'd0;
localparam START_AES = 3'd1;
localparam WAIT_AES  = 3'd2;
localparam SEND_RES  = 3'd3;
localparam WAIT_SEND = 3'd4;

reg [2:0] state;

always @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
        aes_start <= 1'b0;
        sender_start <= 1'b0;
        aes_mode <= 1'b0;
        aes_data <= 128'd0;
    end else begin
        aes_start <= 1'b0;
        sender_start <= 1'b0;

        case (state)

            IDLE: begin
                if (cmd_valid) begin
                    aes_mode <= cmd_mode;
                   aes_data <= cmd_block;
                   aes_key  <= key_block;
                    state <= START_AES;
                end
            end

            START_AES: begin
                aes_start <= 1'b1;
                state <= WAIT_AES;
            end

            WAIT_AES: begin
                if (aes_done) begin
                    state <= SEND_RES;
                end
            end

            SEND_RES: begin
                sender_start <= 1'b1;
                state <= WAIT_SEND;
            end

            WAIT_SEND: begin
                if (sender_done) begin
                    state <= IDLE;
                end
            end

            default: state <= IDLE;

        endcase
    end
end

assign LED[0] = aes_busy;
assign LED[1] = aes_done;
assign LED[2] = cmd_valid;
assign LED[3] = sender_busy;
assign LED[15:4] = 12'd0;

endmodule