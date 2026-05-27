module hex_to_nibble(
    input  wire [7:0] ascii,
    output reg  [3:0] nibble,
    output reg        valid
);

always @(*) begin
    valid  = 1'b1;
    nibble = 4'h0;

    if (ascii >= "0" && ascii <= "9")
        nibble = ascii - "0";
    else if (ascii >= "A" && ascii <= "F")
        nibble = ascii - "A" + 4'd10;
    else if (ascii >= "a" && ascii <= "f")
        nibble = ascii - "a" + 4'd10;
    else begin
        valid  = 1'b0;
        nibble = 4'h0;
    end
end

endmodule