`timescale 1ns/1ps

module command_parser(
    input  wire        clk,
    input  wire        rst,

    input  wire [7:0]  rx_byte,
    input  wire        rx_valid,

    output reg         cmd_valid,
    output reg         mode,       // 0 = Encrypt ASCII, 1 = Decrypt HEX
    output reg [127:0] data_block,
    output reg [127:0] key_block
);

localparam WAIT_MODE     = 3'd0;
localparam WAIT_KEY      = 3'd1;
localparam READ_KEY_HEX  = 3'd2;
localparam WAIT_DATA     = 3'd3;
localparam READ_ASCII    = 3'd4;
localparam READ_DATA_HEX = 3'd5;

reg [2:0] state;
reg [4:0] ascii_count;
reg [5:0] key_hex_count;
reg [5:0] data_hex_count;

wire [3:0] hex_nibble;
wire hex_valid;

hex_to_nibble H2N(
    .ascii(rx_byte),
    .nibble(hex_nibble),
    .valid(hex_valid)
);

wire is_enter = (rx_byte == 8'h0D) || (rx_byte == 8'h0A);
wire is_space = (rx_byte == " ");

always @(posedge clk) begin
    if (rst) begin
        state          <= WAIT_MODE;
        cmd_valid      <= 1'b0;
        mode           <= 1'b0;
        data_block     <= 128'd0;
        key_block      <= 128'd0;
        ascii_count    <= 0;
        key_hex_count  <= 0;
        data_hex_count <= 0;
    end else begin
        cmd_valid <= 1'b0;

        case (state)

            WAIT_MODE: begin
                data_block     <= 128'd0;
                key_block      <= 128'd0;
                ascii_count    <= 0;
                key_hex_count  <= 0;
                data_hex_count <= 0;

                if (rx_valid) begin
                    if (rx_byte == "E" || rx_byte == "e") begin
                        mode  <= 1'b0;
                        state <= WAIT_KEY;
                    end
                    else if (rx_byte == "D" || rx_byte == "d") begin
                        mode  <= 1'b1;
                        state <= WAIT_KEY;
                    end
                end
            end

WAIT_KEY: begin
    if (rx_valid) begin
        if (hex_valid) begin
            key_block[127:124] <= hex_nibble;
            key_hex_count <= 1;
            state <= READ_KEY_HEX;
        end
    end
end

            READ_KEY_HEX: begin
                if (rx_valid) begin
                    if (key_hex_count < 32) begin
                        if (hex_valid) begin
                            key_block[(127 - key_hex_count*4) -: 4] <= hex_nibble;
                            key_hex_count <= key_hex_count + 1;
                        end else begin
                            state <= WAIT_MODE;
                        end
                    end
                    else begin
                        if (is_space)
                            state <= WAIT_DATA;
                        else
                            state <= WAIT_MODE;
                    end
                end
            end

            WAIT_DATA: begin
                if (rx_valid) begin
                    if (!is_space && !is_enter) begin
                        if (mode == 1'b0) begin
                            data_block[127:120] <= rx_byte;
                            ascii_count <= 1;
                            state <= READ_ASCII;
                        end
                        else begin
                            if (hex_valid) begin
                                data_block[127:124] <= hex_nibble;
                                data_hex_count <= 1;
                                state <= READ_DATA_HEX;
                            end else begin
                                state <= WAIT_MODE;
                            end
                        end
                    end
                end
            end

            READ_ASCII: begin
                if (rx_valid) begin
                    if (is_enter) begin
                        cmd_valid <= 1'b1;
                        state <= WAIT_MODE;
                    end
                    else begin
                        if (ascii_count < 16) begin
                            data_block[(127 - ascii_count*8) -: 8] <= rx_byte;
                            ascii_count <= ascii_count + 1;
                        end
                    end
                end
            end

            READ_DATA_HEX: begin
                if (rx_valid) begin
                    if (data_hex_count < 32) begin
                        if (hex_valid) begin
                            data_block[(127 - data_hex_count*4) -: 4] <= hex_nibble;
                            data_hex_count <= data_hex_count + 1;
                        end else begin
                            state <= WAIT_MODE;
                        end
                    end
                    else begin
                        if (is_enter)
                            cmd_valid <= 1'b1;

                        state <= WAIT_MODE;
                    end
                end
            end

            default: state <= WAIT_MODE;

        endcase
    end
end

endmodule