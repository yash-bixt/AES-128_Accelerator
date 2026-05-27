module key_expansion(
    input  wire [127:0] key,
    output wire [1407:0] round_keys
);

// AES-128 generates 44 words.
// Each word = 32 bits.
// 4 words = one 128-bit round key.
// 11 round keys = 11 × 128 = 1408 bits.

wire [31:0] w [0:43];

assign w[0] = key[127:96];
assign w[1] = key[95:64];
assign w[2] = key[63:32];
assign w[3] = key[31:0];

genvar i;

generate
    for (i = 4; i < 44; i = i + 1) begin : KEY_WORD_GEN

        wire [31:0] temp;
        wire [31:0] rotated;
        wire [31:0] subbed;
        wire [31:0] rcon_val;
        wire [3:0] round_num;

        assign temp = w[i-1];

        assign round_num = i / 4;

        rot_word RW (
            .in(temp),
            .out(rotated)
        );

        sub_word SW (
            .in(rotated),
            .out(subbed)
        );

        rcon RC (
            .round(round_num),
            .rcon_out(rcon_val)
        );

        if (i % 4 == 0) begin : SPECIAL_WORD
            assign w[i] = w[i-4] ^ subbed ^ rcon_val;
        end
        else begin : NORMAL_WORD
            assign w[i] = w[i-4] ^ temp;
        end

    end
endgenerate

assign round_keys = {
    w[0],  w[1],  w[2],  w[3],
    w[4],  w[5],  w[6],  w[7],
    w[8],  w[9],  w[10], w[11],
    w[12], w[13], w[14], w[15],
    w[16], w[17], w[18], w[19],
    w[20], w[21], w[22], w[23],
    w[24], w[25], w[26], w[27],
    w[28], w[29], w[30], w[31],
    w[32], w[33], w[34], w[35],
    w[36], w[37], w[38], w[39],
    w[40], w[41], w[42], w[43]
};

endmodule