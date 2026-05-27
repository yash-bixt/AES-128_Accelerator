module aes128_core(
    input  wire         clk,
    input  wire         rst,
    input  wire         start,

    // mode = 0 ? encrypt
    // mode = 1 ? decrypt
    input  wire         mode,

    input  wire [127:0] data_in,
    input  wire [127:0] key,

    output reg  [127:0] data_out,
    output reg          done,
    output reg          busy
);

wire [127:0] enc_out;
wire [127:0] dec_out;

wire enc_done;
wire dec_done;

reg enc_start;
reg dec_start;

aes128_encrypt_core ENC_CORE (
    .clk(clk),
    .rst(rst),
    .start(enc_start),
    .plaintext(data_in),
    .key(key),
    .ciphertext(enc_out),
    .done(enc_done)
);

aes128_decrypt_core DEC_CORE (
    .clk(clk),
    .rst(rst),
    .start(dec_start),
    .ciphertext_in(data_in),
    .key(key),
    .plaintext_out(dec_out),
    .done(dec_done)
);

localparam IDLE      = 2'd0;
localparam START_AES = 2'd1;
localparam WAIT_AES  = 2'd2;
localparam DONE_ST   = 2'd3;

reg [1:0] state;
reg mode_latched;

always @(posedge clk) begin
    if (rst) begin
        state        <= IDLE;
        data_out     <= 128'd0;
        done         <= 1'b0;
        busy         <= 1'b0;
        enc_start    <= 1'b0;
        dec_start    <= 1'b0;
        mode_latched <= 1'b0;
    end
    else begin
        done      <= 1'b0;
        enc_start <= 1'b0;
        dec_start <= 1'b0;

        case (state)

            IDLE: begin
                busy <= 1'b0;

                if (start) begin
                    busy         <= 1'b1;
                    mode_latched <= mode;
                    state        <= START_AES;
                end
            end

            START_AES: begin
                if (mode_latched == 1'b0) begin
                    enc_start <= 1'b1;
                end
                else begin
                    dec_start <= 1'b1;
                end

                state <= WAIT_AES;
            end

            WAIT_AES: begin
                if (mode_latched == 1'b0) begin
                    if (enc_done) begin
                        data_out <= enc_out;
                        state    <= DONE_ST;
                    end
                end
                else begin
                    if (dec_done) begin
                        data_out <= dec_out;
                        state    <= DONE_ST;
                    end
                end
            end

            DONE_ST: begin
                done  <= 1'b1;
                busy  <= 1'b0;
                state <= IDLE;
            end

            default: begin
                state <= IDLE;
            end

        endcase
    end
end

endmodule