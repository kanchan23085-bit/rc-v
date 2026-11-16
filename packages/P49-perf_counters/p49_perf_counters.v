// P49 Performance counters
// cycle har clock pe +1, instret sirf jab commit ho

module p49_perf_counters (
    input wire clk,
    input wire rst,
    input wire sel,
    input wire we,
    input wire re,
    input wire [1:0] ridx,
    input wire [31:0] wdata,
    output wire [31:0] rdata,
    input wire clear
);

    reg [31:0] cycle_count;
    reg [31:0] instret_count;

    // read: ridx 0 = cycle, 1 = instret
    assign rdata = (re && sel) ? ((ridx == 2'd0) ? cycle_count : instret_count) : 32'd0;

    always @(posedge clk) begin
        if (rst || clear) begin
            cycle_count <= 32'd0;
            instret_count <= 32'd0;
        end else if (sel) begin
            if (we) begin
                // software write: ridx 0 = cycle, 1 = instret
                if (ridx == 2'd0)
                    cycle_count <= wdata;
                else
                    instret_count <= wdata;
            end else begin
                // normal counting
                cycle_count <= cycle_count + 32'd1;
                // sel = commit, jab instruction poori ho
                instret_count <= instret_count + 32'd1;
            end
        end else begin
            cycle_count <= cycle_count + 32'd1;
        end
    end

endmodule
