// 2x2 Spatial Max-Pooling Unit for INT8 Feature Maps
module maxpool2x2 (
    input  wire              clk,
    input  wire              rst_n,
    input  wire              valid_in,
    input  wire signed [7:0] in0, in1, in2, in3,
    output reg  signed [7:0] max_out,
    output reg               valid_out
);

    wire signed [7:0] max_top = (in0 > in1) ? in0 : in1;
    wire signed [7:0] max_bot = (in2 > in3) ? in2 : in3;
    wire signed [7:0] max_all = (max_top > max_bot) ? max_top : max_bot;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            max_out   <= 8'sd0;
            valid_out <= 1'b0;
        end else if (valid_in) begin
            max_out   <= max_all;
            valid_out <= 1'b1;
        end else begin
            valid_out <= 1'b0;
        end
    end

endmodule
