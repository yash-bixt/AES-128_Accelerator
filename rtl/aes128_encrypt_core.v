module aes128_encrypt_core(
    input  wire         clk,
    input  wire         rst,
    input  wire         start,
    input  wire [127:0] plaintext,
    input  wire [127:0] key,
    output reg  [127:0] ciphertext,
    output reg          done
);

wire [1407:0] round_keys;

wire [127:0] rk0;
wire [127:0] rk1;
wire [127:0] rk2;
wire [127:0] rk3;
wire [127:0] rk4;
wire [127:0] rk5;
wire [127:0] rk6;
wire [127:0] rk7;
wire [127:0] rk8;
wire [127:0] rk9;
wire [127:0] rk10;

assign rk0  = round_keys[1407:1280];
assign rk1  = round_keys[1279:1152];
assign rk2  = round_keys[1151:1024];
assign rk3  = round_keys[1023:896];
assign rk4  = round_keys[895:768];
assign rk5  = round_keys[767:640];
assign rk6  = round_keys[639:512];
assign rk7  = round_keys[511:384];
assign rk8  = round_keys[383:256];
assign rk9  = round_keys[255:128];
assign rk10 = round_keys[127:0];

key_expansion KE (
    .key(key),
    .round_keys(round_keys)
);

wire [127:0] s0;

add_round_key ARK0 (
    .state(plaintext),
    .round_key(rk0),
    .out(s0)
);

// Round 1
wire [127:0] r1_sub, r1_shift, r1_mix, r1_out;

sub_bytes SB1 (.state_in(s0), .state_out(r1_sub));
shift_rows SR1 (.state_in(r1_sub), .state_out(r1_shift));
mix_columns MC1 (.state_in(r1_shift), .state_out(r1_mix));
add_round_key ARK1 (.state(r1_mix), .round_key(rk1), .out(r1_out));

// Round 2
wire [127:0] r2_sub, r2_shift, r2_mix, r2_out;

sub_bytes SB2 (.state_in(r1_out), .state_out(r2_sub));
shift_rows SR2 (.state_in(r2_sub), .state_out(r2_shift));
mix_columns MC2 (.state_in(r2_shift), .state_out(r2_mix));
add_round_key ARK2 (.state(r2_mix), .round_key(rk2), .out(r2_out));

// Round 3
wire [127:0] r3_sub, r3_shift, r3_mix, r3_out;

sub_bytes SB3 (.state_in(r2_out), .state_out(r3_sub));
shift_rows SR3 (.state_in(r3_sub), .state_out(r3_shift));
mix_columns MC3 (.state_in(r3_shift), .state_out(r3_mix));
add_round_key ARK3 (.state(r3_mix), .round_key(rk3), .out(r3_out));

// Round 4
wire [127:0] r4_sub, r4_shift, r4_mix, r4_out;

sub_bytes SB4 (.state_in(r3_out), .state_out(r4_sub));
shift_rows SR4 (.state_in(r4_sub), .state_out(r4_shift));
mix_columns MC4 (.state_in(r4_shift), .state_out(r4_mix));
add_round_key ARK4 (.state(r4_mix), .round_key(rk4), .out(r4_out));

// Round 5
wire [127:0] r5_sub, r5_shift, r5_mix, r5_out;

sub_bytes SB5 (.state_in(r4_out), .state_out(r5_sub));
shift_rows SR5 (.state_in(r5_sub), .state_out(r5_shift));
mix_columns MC5 (.state_in(r5_shift), .state_out(r5_mix));
add_round_key ARK5 (.state(r5_mix), .round_key(rk5), .out(r5_out));

// Round 6
wire [127:0] r6_sub, r6_shift, r6_mix, r6_out;

sub_bytes SB6 (.state_in(r5_out), .state_out(r6_sub));
shift_rows SR6 (.state_in(r6_sub), .state_out(r6_shift));
mix_columns MC6 (.state_in(r6_shift), .state_out(r6_mix));
add_round_key ARK6 (.state(r6_mix), .round_key(rk6), .out(r6_out));

// Round 7
wire [127:0] r7_sub, r7_shift, r7_mix, r7_out;

sub_bytes SB7 (.state_in(r6_out), .state_out(r7_sub));
shift_rows SR7 (.state_in(r7_sub), .state_out(r7_shift));
mix_columns MC7 (.state_in(r7_shift), .state_out(r7_mix));
add_round_key ARK7 (.state(r7_mix), .round_key(rk7), .out(r7_out));

// Round 8
wire [127:0] r8_sub, r8_shift, r8_mix, r8_out;

sub_bytes SB8 (.state_in(r7_out), .state_out(r8_sub));
shift_rows SR8 (.state_in(r8_sub), .state_out(r8_shift));
mix_columns MC8 (.state_in(r8_shift), .state_out(r8_mix));
add_round_key ARK8 (.state(r8_mix), .round_key(rk8), .out(r8_out));

// Round 9
wire [127:0] r9_sub, r9_shift, r9_mix, r9_out;

sub_bytes SB9 (.state_in(r8_out), .state_out(r9_sub));
shift_rows SR9 (.state_in(r9_sub), .state_out(r9_shift));
mix_columns MC9 (.state_in(r9_shift), .state_out(r9_mix));
add_round_key ARK9 (.state(r9_mix), .round_key(rk9), .out(r9_out));

// Final Round 10: No MixColumns
wire [127:0] r10_sub, r10_shift, r10_out;

sub_bytes SB10 (.state_in(r9_out), .state_out(r10_sub));
shift_rows SR10 (.state_in(r10_sub), .state_out(r10_shift));
add_round_key ARK10 (.state(r10_shift), .round_key(rk10), .out(r10_out));

always @(posedge clk) begin
    if (rst) begin
        ciphertext <= 128'd0;
        done       <= 1'b0;
    end
    else begin
        done <= 1'b0;

        if (start) begin
            ciphertext <= r10_out;
            done       <= 1'b1;
        end
    end
end

endmodule