module pe #(
    parameter DW   = 8,
    parameter ACCW = 32
)(
    input                   clk,
    input                   rst_n,
    input                   acc_clear,

    input  [DW-1:0]         a_in,
    input  [DW-1:0]         b_in,

    output reg [DW-1:0]     a_out,
    output reg [ACCW-1:0]   acc_out
);

    reg [DW-1:0]   a_reg;
    reg [DW-1:0]   b_reg;
    reg [2*DW-1:0] mult_reg;
    reg            clear_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg     <= {DW{1'b0}};
            b_reg     <= {DW{1'b0}};
            a_out     <= {DW{1'b0}};
            mult_reg  <= {2*DW{1'b0}};
            clear_reg <= 1'b0;
            acc_out   <= {ACCW{1'b0}};
        end else begin
            a_reg     <= a_in;
            b_reg     <= b_in;
            a_out     <= a_reg;
            mult_reg  <= a_reg * b_reg;
            clear_reg <= acc_clear;
            acc_out   <= clear_reg ? {{ACCW-2*DW{1'b0}}, mult_reg}
                                   : acc_out + {{ACCW-2*DW{1'b0}}, mult_reg};
        end
    end

endmodule
