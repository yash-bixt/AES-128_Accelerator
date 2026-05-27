module uart_tx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 115200
)(
    input  wire       clk,
    input  wire       rst,

    input  wire [7:0] data_in,
    input  wire       start,

    output reg        tx,
    output reg        busy,
    output reg        done
);

localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD;

localparam IDLE  = 3'd0;
localparam START = 3'd1;
localparam DATA  = 3'd2;
localparam STOP  = 3'd3;
localparam DONE  = 3'd4;

reg [2:0] state;
reg [31:0] clk_count;
reg [2:0] bit_index;
reg [7:0] tx_shift;

always @(posedge clk) begin
    if (rst) begin
        state     <= IDLE;
        tx        <= 1'b1;
        busy      <= 1'b0;
        done      <= 1'b0;
        clk_count <= 0;
        bit_index <= 0;
        tx_shift  <= 8'd0;
    end else begin
        done <= 1'b0;

        case (state)

            IDLE: begin
                tx        <= 1'b1;
                busy      <= 1'b0;
                clk_count <= 0;
                bit_index <= 0;

                if (start) begin
                    tx_shift <= data_in;
                    busy <= 1'b1;
                    state <= START;
                end
            end

            START: begin
                tx <= 1'b0;

                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0;
                    state <= DATA;
                end else begin
                    clk_count <= clk_count + 1;
                end
            end

            DATA: begin
                tx <= tx_shift[bit_index];

                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0;

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
                tx <= 1'b1;

                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0;
                    state <= DONE;
                end else begin
                    clk_count <= clk_count + 1;
                end
            end

            DONE: begin
                done <= 1'b1;
                busy <= 1'b0;
                state <= IDLE;
            end

            default: begin
                state <= IDLE;
            end

        endcase
    end
end

endmodule

