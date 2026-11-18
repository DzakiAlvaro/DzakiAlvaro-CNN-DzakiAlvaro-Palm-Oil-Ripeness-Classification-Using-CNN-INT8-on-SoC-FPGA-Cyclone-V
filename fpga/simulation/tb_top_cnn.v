`timescale 1ns / 1ps

module tb_top_cnn;
    reg clk;
    reg rst_n;
    reg start;

    reg signed [7:0] r0, r1, r2, r3, r4, r5, r6, r7, r8;
    reg signed [7:0] g0, g1, g2, g3, g4, g5, g6, g7, g8;
    reg signed [7:0] b0, b1, b2, b3, b4, b5, b6, b7, b8;
    reg signed [31:0] score_unripe, score_ripe, score_overripe;

    wire signed [7:0] conv_feat_out;
    wire [1:0]        ripeness_class;
    wire              done;

    top_cnn_cyclonev uut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .r0(r0), .r1(r1), .r2(r2), .r3(r3), .r4(r4), .r5(r5), .r6(r6), .r7(r7), .r8(r8),
        .g0(g0), .g1(g1), .g2(g2), .g3(g3), .g4(g4), .g5(g5), .g6(g6), .g7(g7), .g8(g8),
        .b0(b0), .b1(b1), .b2(b2), .b3(b3), .b4(b4), .b5(b5), .b6(b6), .b7(b7), .b8(b8),
        .score_unripe(score_unripe),
        .score_ripe(score_ripe),
        .score_overripe(score_overripe),
        .conv_feat_out(conv_feat_out),
        .ripeness_class(ripeness_class),
        .done(done)
    );

    always #10 clk = ~clk; // 50 MHz Cyclone V Clock

    initial begin
        clk = 0; rst_n = 0; start = 0;
        #30 rst_n = 1;

        // Test Case: Ripe Palm Oil Bunch (High Red channel, Moderate Green, Low Blue)
        @(posedge clk);
        start = 1;
        r0 = 8'sd95;  r1 = 8'sd100; r2 = 8'sd90;
        r3 = 8'sd88;  r4 = 8'sd110; r5 = 8'sd92;
        r6 = 8'sd85;  r7 = 8'sd98;  r8 = 8'sd94;

        g0 = -8'sd20; g1 = -8'sd15; g2 = -8'sd25;
        g3 = -8'sd18; g4 = -8'sd10; g5 = -8'sd22;
        g6 = -8'sd24; g7 = -8'sd12; g8 = -8'sd19;

        b0 = -8'sd90; b1 = -8'sd85; b2 = -8'sd95;
        b3 = -8'sd88; b4 = -8'sd80; b5 = -8'sd92;
        b6 = -8'sd94; b7 = -8'sd86; b8 = -8'sd90;

        score_unripe   = 32'sd45;
        score_ripe     = 32'sd310;
        score_overripe = 32'sd110;

        @(posedge clk);
        start = 0;
        #30;
        $display("Cyclone V CNN Output -> Conv Feature: %d | Predicted Class: %b (01=Ripe)",
                 conv_feat_out, ripeness_class);
        #20 $finish;
    end
endmodule
