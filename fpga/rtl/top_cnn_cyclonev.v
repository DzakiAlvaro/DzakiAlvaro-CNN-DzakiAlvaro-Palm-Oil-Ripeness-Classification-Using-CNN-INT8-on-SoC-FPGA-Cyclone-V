// Top-Level CNN INT8 Inference Core for Intel SoC FPGA Cyclone V
module top_cnn_cyclonev (
    input  wire               clk,          // 50 MHz Cyclone V Clock
    input  wire               rst_n,        // Active-Low Reset
    input  wire               start,        // Trigger from HPS (ARM Cortex-A9)
    input  wire signed [7:0]  r0, r1, r2, r3, r4, r5, r6, r7, r8,
    input  wire signed [7:0]  g0, g1, g2, g3, g4, g5, g6, g7, g8,
    input  wire signed [7:0]  b0, b1, b2, b3, b4, b5, b6, b7, b8,
    input  wire signed [31:0] score_unripe,
    input  wire signed [31:0] score_ripe,
    input  wire signed [31:0] score_overripe,
    output wire signed [7:0]  conv_feat_out,
    output reg  [1:0]         ripeness_class, // 00: Unripe, 01: Ripe, 10: Overripe
    output reg                done
);

    // Weight ROM loaded from INT8 quantized hex file
    reg signed [7:0] weight_rom [0:107];
    initial begin
        $readmemh("weights_conv1.hex", weight_rom);
    end

    wire signed [31:0] conv_acc;
    wire               conv_valid;

    conv2d_int8 u_conv2d (
        .clk(clk), .rst_n(rst_n), .valid_in(start),
        .r0(r0), .r1(r1), .r2(r2), .r3(r3), .r4(r4), .r5(r5), .r6(r6), .r7(r7), .r8(r8),
        .g0(g0), .g1(g1), .g2(g2), .g3(g3), .g4(g4), .g5(g5), .g6(g6), .g7(g7), .g8(g8),
        .b0(b0), .b1(b1), .b2(b2), .b3(b3), .b4(b4), .b5(b5), .b6(b6), .b7(b7), .b8(b8),
        .wr0(weight_rom[0]),  .wr1(weight_rom[1]),  .wr2(weight_rom[2]),
        .wr3(weight_rom[3]),  .wr4(weight_rom[4]),  .wr5(weight_rom[5]),
        .wr6(weight_rom[6]),  .wr7(weight_rom[7]),  .wr8(weight_rom[8]),
        .wg0(weight_rom[9]),  .wg1(weight_rom[10]), .wg2(weight_rom[11]),
        .wg3(weight_rom[12]), .wg4(weight_rom[13]), .wg5(weight_rom[14]),
        .wg6(weight_rom[15]), .wg7(weight_rom[16]), .wg8(weight_rom[17]),
        .wb0(weight_rom[18]), .wb1(weight_rom[19]), .wb2(weight_rom[20]),
        .wb3(weight_rom[21]), .wb4(weight_rom[22]), .wb5(weight_rom[23]),
        .wb6(weight_rom[24]), .wb7(weight_rom[25]), .wb8(weight_rom[26]),
        .bias(16'sd12),
        .acc_out(conv_acc),
        .valid_out(conv_valid)
    );

    relu_quant #(.SHIFT_BITS(7)) u_relu_q (
        .data_in(conv_acc),
        .data_out(conv_feat_out)
    );

    // Argmax Classifier Output
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ripeness_class <= 2'b00;
            done           <= 1'b0;
        end else if (conv_valid) begin
            if (score_unripe >= score_ripe && score_unripe >= score_overripe)
                ripeness_class <= 2'b00; // Unripe
            else if (score_ripe >= score_unripe && score_ripe >= score_overripe)
                ripeness_class <= 2'b01; // Ripe
            else
                ripeness_class <= 2'b10; // Overripe
            done <= 1'b1;
        end else begin
            done <= 1'b0;
        end
    end

endmodule
