// ReLU Activation and Fixed-Point Re-Quantization (INT32 Accumulator -> INT8)
module relu_quant #(
    parameter SHIFT_BITS = 7
)(
    input  wire signed [31:0] data_in,
    output reg  signed [7:0]  data_out
);

    wire signed [31:0] relu_val    = (data_in[31] == 1'b1) ? 32'sd0 : data_in;
    wire signed [31:0] scaled_val  = relu_val >>> SHIFT_BITS;

    always @(*) begin
        if (scaled_val > 32'sd127)
            data_out = 8'sd127;
        else
            data_out = scaled_val[7:0];
    end

endmodule
