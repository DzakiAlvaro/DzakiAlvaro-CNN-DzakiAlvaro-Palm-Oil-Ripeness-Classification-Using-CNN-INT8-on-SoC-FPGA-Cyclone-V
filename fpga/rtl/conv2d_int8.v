// 3x3 RGB (3-Channel) INT8 Convolution MAC Unit for Cyclone V DSP Blocks
module conv2d_int8 (
    input  wire               clk,
    input  wire               rst_n,
    input  wire               valid_in,
    // 3x3 window for R, G, B channels (9 pixels x 3 channels = 27 INT8 inputs)
    input  wire signed [7:0]  r0, r1, r2, r3, r4, r5, r6, r7, r8,
    input  wire signed [7:0]  g0, g1, g2, g3, g4, g5, g6, g7, g8,
    input  wire signed [7:0]  b0, b1, b2, b3, b4, b5, b6, b7, b8,
    // Corresponding 3x3x3 INT8 filter weights
    input  wire signed [7:0]  wr0, wr1, wr2, wr3, wr4, wr5, wr6, wr7, wr8,
    input  wire signed [7:0]  wg0, wg1, wg2, wg3, wg4, wg5, wg6, wg7, wg8,
    input  wire signed [7:0]  wb0, wb1, wb2, wb3, wb4, wb5, wb6, wb7, wb8,
    input  wire signed [15:0] bias,
    output reg  signed [31:0] acc_out,
    output reg                valid_out
);

    wire signed [31:0] sum_r = (r0*wr0) + (r1*wr1) + (r2*wr2) +
                               (r3*wr3) + (r4*wr4) + (r5*wr5) +
                               (r6*wr6) + (r7*wr7) + (r8*wr8);

    wire signed [31:0] sum_g = (g0*wg0) + (g1*wg1) + (g2*wg2) +
                               (g3*wg3) + (g4*wg4) + (g5*wg5) +
                               (g6*wg6) + (g7*wg7) + (g8*wg8);

    wire signed [31:0] sum_b = (b0*wb0) + (b1*wb1) + (b2*wb2) +
                               (b3*wb3) + (b4*wb4) + (b5*wb5) +
                               (b6*wb6) + (b7*wb7) + (b8*wb8);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_out   <= 32'sd0;
            valid_out <= 1'b0;
        end else if (valid_in) begin
            acc_out   <= sum_r + sum_g + sum_b + {{16{bias[15]}}, bias};
            valid_out <= 1'b1;
        end else begin
            valid_out <= 1'b0;
        end
    end

endmodule
