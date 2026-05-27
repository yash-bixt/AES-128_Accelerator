`timescale 1ns/1ps

module uart_result_sender(
    input  wire         clk,
    input  wire         rst,

    input  wire         start,
    input  wire         mode, // 0=encrypt HEX, 1=decrypt ASCII
    input  wire [127:0] result_block,

    output reg  [7:0]   tx_byte,
    output reg          tx_start,

    input  wire         tx_busy,
    input  wire         tx_done,

    output reg          busy,
    output reg          done
);

localparam IDLE       = 3'd0;
localparam SET_BYTE   = 3'd1;
localparam START_BYTE = 3'd2;
localparam WAIT_DONE  = 3'd3;
localparam FINISH     = 3'd4;

reg [2:0] state;
reg [5:0] index;

reg [7:0] current_byte;

function [7:0] nibble_ascii;
    input [3:0] nib;
    begin
        if (nib < 10)
            nibble_ascii = "0" + nib;
        else
            nibble_ascii = "A" + nib - 10;
    end
endfunction

always @(*) begin
    current_byte = 8'h00;

    if (mode == 1'b0) begin
        if (index == 0)
            current_byte = "C";
        else if (index >= 1 && index <= 32)
            current_byte = nibble_ascii(result_block[(127 - (index-1)*4) -: 4]);
        else if (index == 33)
            current_byte = 8'h0D;
        else
            current_byte = 8'h0A;
    end
    else begin
        if (index == 0)
            current_byte = "P";
        else if (index >= 1 && index <= 16)
            current_byte = result_block[(127 - (index-1)*8) -: 8];
        else if (index == 17)
            current_byte = 8'h0D;
        else
            current_byte = 8'h0A;
    end
end

always @(posedge clk) begin
    if (rst) begin
        state    <= IDLE;
        index    <= 0;
        tx_byte  <= 8'd0;
        tx_start <= 1'b0;
        busy     <= 1'b0;
        done     <= 1'b0;
    end
    else begin
        tx_start <= 1'b0;
        done     <= 1'b0;

        case (state)

            IDLE: begin
                busy  <= 1'b0;
                index <= 0;

                if (start) begin
                    busy  <= 1'b1;
                    state <= SET_BYTE;
                end
            end

            SET_BYTE: begin
                // Skip null bytes during ASCII plaintext output
                if (mode == 1'b1 && index >= 1 && index <= 16 && current_byte == 8'h00) begin
                    index <= index + 1;
                end
                else begin
                    tx_byte <= current_byte;
                    state   <= START_BYTE;
                end
            end

            START_BYTE: begin
                if (!tx_busy) begin
                    tx_start <= 1'b1;
                    state    <= WAIT_DONE;
                end
            end

            WAIT_DONE: begin
                if (tx_done) begin
                    if (mode == 1'b0) begin
                        if (index == 34)
                            state <= FINISH;
                        else begin
                            index <= index + 1;
                            state <= SET_BYTE;
                        end
                    end
                    else begin
                        if (index == 18)
                            state <= FINISH;
                        else begin
                            index <= index + 1;
                            state <= SET_BYTE;
                        end
                    end
                end
            end

            FINISH: begin
                busy  <= 1'b0;
                done  <= 1'b1;
                state <= IDLE;
            end

            default: state <= IDLE;

        endcase
    end
end

endmodule