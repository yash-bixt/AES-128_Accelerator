module uart_rx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 115200
)(
    input  wire clk,
    input  wire rst,
    input  wire rx,

    output reg  [7:0] data_out,
    output reg        data_valid
);

localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD;
localparam integer HALF_BIT     = CLKS_PER_BIT / 2;

localparam IDLE  = 3'd0;
localparam START = 3'd1;
localparam DATA  = 3'd2;
localparam STOP  = 3'd3;
localparam DONE  = 3'd4;

reg [2:0] state;
reg [31:0] clk_count;
reg [2:0] bit_index;
reg [7:0] rx_shift;

// Two-flop synchronizer for UART RX
reg rx_sync1, rx_sync2;

always @(posedge clk) begin
    if (rst) begin
        rx_sync1 <= 1'b1;
        rx_sync2 <= 1'b1;
    end else begin
        rx_sync1 <= rx;
        rx_sync2 <= rx_sync1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        state      <= IDLE;
        clk_count  <= 0;
        bit_index  <= 0;
        rx_shift   <= 8'd0;
        data_out   <= 8'd0;
        data_valid <= 1'b0;
    end else begin
        data_valid <= 1'b0;

        case (state)

            IDLE: begin
                clk_count <= 0;
                bit_index <= 0;

                if (rx_sync2 == 1'b0) begin
                    state <= START;
                end
            end

            START: begin
                if (clk_count == HALF_BIT) begin
                    if (rx_sync2 == 1'b0) begin
                        clk_count <= 0;
                        state <= DATA;
                    end else begin
                        state <= IDLE;
                    end
                end else begin
                    clk_count <= clk_count + 1;
                end
            end

            DATA: begin
                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0;
                    rx_shift[bit_index] <= rx_sync2;

                    if (bit_index == 3'd7) begin
                        bit_index <= 0;
                        state <= STOP;
                    end else begin
                        bit_index <= bit_index + 1;
                    end
                end else begin
                    clk_count <= clk_count + 1;
                end
            end

            STOP: begin
                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0;
                    state <= DONE;
                end else begin
                    clk_count <= clk_count + 1;
                end
            end

            DONE: begin
                data_out   <= rx_shift;
                data_valid <= 1'b1;
                state      <= IDLE;
            end

            default: begin
                state <= IDLE;
            end

        endcase
    end
end

endmodule