module systolic_array_32x32 #(
    parameter ROWS = 32,
    parameter COLS = 32,
    parameter DW   = 8,
    parameter ACCW = 32
)(
    input                        clk,
    input                        rst_n,
    input                        acc_clear,

    input  [ROWS*DW-1:0]         row_data,
    input  [COLS*DW-1:0]         col_data,

    input  [4:0]                 row_sel,
    input  [4:0]                 col_sel,
    output reg [ACCW-1:0]        result_out,

    // Scan ports — added for DFT
    input                        test_se,
    input                        test_si,
    output                       test_so
);

    wire [DW-1:0]   a_bus [0:ROWS-1][0:COLS];
    reg  [DW-1:0]   b_bus [0:ROWS][0:COLS-1];
    wire [ACCW-1:0] acc   [0:ROWS-1][0:COLS-1];

    genvar i, j;

    generate
        for (i = 0; i < ROWS; i = i+1) begin : ROW_FEED
            assign a_bus[i][0] = row_data[(i*DW) +: DW];
        end

        for (j = 0; j < COLS; j = j+1) begin : COL_FEED
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) b_bus[0][j] <= {DW{1'b0}};
                else        b_bus[0][j] <= col_data[(j*DW) +: DW];
            end
        end

        for (i = 1; i <= ROWS; i = i+1) begin : B_PROP_ROW
            for (j = 0; j < COLS; j = j+1) begin : B_PROP_COL
                always @(posedge clk or negedge rst_n) begin
                    if (!rst_n) b_bus[i][j] <= {DW{1'b0}};
                    else        b_bus[i][j] <= b_bus[i-1][j];
                end
            end
        end

        for (i = 0; i < ROWS; i = i+1) begin : ROW
            for (j = 0; j < COLS; j = j+1) begin : COL
                pe #(
                    .DW  (DW),
                    .ACCW(ACCW)
                ) u_pe (
                    .clk      (clk),
                    .rst_n    (rst_n),
                    .acc_clear(acc_clear),
                    .a_in     (a_bus[i][j]),
                    .b_in     (b_bus[i][j]),
                    .a_out    (a_bus[i][j+1]),
                    .acc_out  (acc[i][j])
                );
            end
        end
    endgenerate

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) result_out <= {ACCW{1'b0}};
        else        result_out <= acc[row_sel][col_sel];
    end

endmodule
