module aes128_decrypt_core(
    input  wire         clk,
    input  wire         rst,
    input  wire         start,
    input  wire [127:0] ciphertext_in,
    input  wire [127:0] key,
    output reg  [127:0] plaintext_out,
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

key_expansion KE(
    .key(key),
    .round_keys(round_keys)
);

wire [127:0] s0;
add_round_key ARK_INIT(.state(ciphertext_in), .round_key(rk10), .out(s0));

// Round 9
wire [127:0] r9_shift, r9_sub, r9_add, r9_mix;
inv_shift_rows ISR9(.state_in(s0), .state_out(r9_shift));
inv_sub_bytes  ISB9(.state_in(r9_shift), .state_out(r9_sub));
add_round_key  ARK9(.state(r9_sub), .round_key(rk9), .out(r9_add));
inv_mix_columns IMC9(.state_in(r9_add), .state_out(r9_mix));

// Round 8
wire [127:0] r8_shift, r8_sub, r8_add, r8_mix;
inv_shift_rows ISR8(.state_in(r9_mix), .state_out(r8_shift));
inv_sub_bytes  ISB8(.state_in(r8_shift), .state_out(r8_sub));
add_round_key  ARK8(.state(r8_sub), .round_key(rk8), .out(r8_add));
inv_mix_columns IMC8(.state_in(r8_add), .state_out(r8_mix));

// Round 7
wire [127:0] r7_shift, r7_sub, r7_add, r7_mix;
inv_shift_rows ISR7(.state_in(r8_mix), .state_out(r7_shift));
inv_sub_bytes  ISB7(.state_in(r7_shift), .state_out(r7_sub));
add_round_key  ARK7(.state(r7_sub), .round_key(rk7), .out(r7_add));
inv_mix_columns IMC7(.state_in(r7_add), .state_out(r7_mix));

// Round 6
wire [127:0] r6_shift, r6_sub, r6_add, r6_mix;
inv_shift_rows ISR6(.state_in(r7_mix), .state_out(r6_shift));
inv_sub_bytes  ISB6(.state_in(r6_shift), .state_out(r6_sub));
add_round_key  ARK6(.state(r6_sub), .round_key(rk6), .out(r6_add));
inv_mix_columns IMC6(.state_in(r6_add), .state_out(r6_mix));

// Round 5
wire [127:0] r5_shift, r5_sub, r5_add, r5_mix;
inv_shift_rows ISR5(.state_in(r6_mix), .state_out(r5_shift));
inv_sub_bytes  ISB5(.state_in(r5_shift), .state_out(r5_sub));
add_round_key  ARK5(.state(r5_sub), .round_key(rk5), .out(r5_add));
inv_mix_columns IMC5(.state_in(r5_add), .state_out(r5_mix));

// Round 4
wire [127:0] r4_shift, r4_sub, r4_add, r4_mix;
inv_shift_rows ISR4(.state_in(r5_mix), .state_out(r4_shift));
inv_sub_bytes  ISB4(.state_in(r4_shift), .state_out(r4_sub));
add_round_key  ARK4(.state(r4_sub), .round_key(rk4), .out(r4_add));
inv_mix_columns IMC4(.state_in(r4_add), .state_out(r4_mix));

// Round 3
wire [127:0] r3_shift, r3_sub, r3_add, r3_mix;
inv_shift_rows ISR3(.state_in(r4_mix), .state_out(r3_shift));
inv_sub_bytes  ISB3(.state_in(r3_shift), .state_out(r3_sub));
add_round_key  ARK3(.state(r3_sub), .round_key(rk3), .out(r3_add));
inv_mix_columns IMC3(.state_in(r3_add), .state_out(r3_mix));

// Round 2
wire [127:0] r2_shift, r2_sub, r2_add, r2_mix;
inv_shift_rows ISR2(.state_in(r3_mix), .state_out(r2_shift));
inv_sub_bytes  ISB2(.state_in(r2_shift), .state_out(r2_sub));
add_round_key  ARK2(.state(r2_sub), .round_key(rk2), .out(r2_add));
inv_mix_columns IMC2(.state_in(r2_add), .state_out(r2_mix));

// Round 1
wire [127:0] r1_shift, r1_sub, r1_add, r1_mix;
inv_shift_rows ISR1(.state_in(r2_mix), .state_out(r1_shift));
inv_sub_bytes  ISB1(.state_in(r1_shift), .state_out(r1_sub));
add_round_key  ARK1(.state(r1_sub), .round_key(rk1), .out(r1_add));
inv_mix_columns IMC1(.state_in(r1_add), .state_out(r1_mix));

// Final round
wire [127:0] rf_shift, rf_sub, rf_out;
inv_shift_rows ISRF(.state_in(r1_mix), .state_out(rf_shift));
inv_sub_bytes  ISBF(.state_in(rf_shift), .state_out(rf_sub));
add_round_key  ARKF(.state(rf_sub), .round_key(rk0), .out(rf_out));

always @(posedge clk) begin
    if (rst) begin
        plaintext_out <= 128'd0;
        done <= 1'b0;
    end else begin
        done <= 1'b0;
        if (start) begin
            plaintext_out <= rf_out;
            done <= 1'b1;
        end
    end
end

endmodule