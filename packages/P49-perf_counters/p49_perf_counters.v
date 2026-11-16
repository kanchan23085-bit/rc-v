module p49_perf_counters (
  input wire clk,
  input wire rst,
  input wire sel,
  input wire re,
  input wire we,
  input wire [3:0] ridx,
  input wire [31:0] wdata,
  input wire commit,
  output wire [31:0] rdata
);

  reg [31:0] cycle_cnt;
  reg [31:0] instret_cnt;

  always @(posedge clk) begin
    if (rst) begin
      cycle_cnt <= 32'd0;
      instret_cnt <= 32'd0;
    end else if (sel && we && (ridx == 4'd2)) begin
      cycle_cnt <= 32'd0;
      instret_cnt <= 32'd0;
       end else if (sel && we && (ridx == 4'd2)) begin
      cycle_cnt <= 32'd0;
      instret_cnt <= 32'd0;
    end else begin 
    end else begin
      cycle_cnt <= cycle_cnt + 32'd1;
      if (commit)
        instret_cnt <= instret_cnt + 32'd1;
    end
  end

  assign rdata = 
    (ridx == 4'd0) ? cycle_cnt :
    (ridx == 4'd1) ? instret_cnt :
    (ridx == 4'd15) ? 32'd49 :
    32'd0;

endmodule
