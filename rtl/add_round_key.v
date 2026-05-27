module add_round_key(
    input wire [127:0] state,
    input wire [127:0] round_key,
    output wire [127:0] out
);

assign out = state ^ round_key;

endmodule
