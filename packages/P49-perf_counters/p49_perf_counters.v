reg [31:0] cycle_cnt;
reg [31:0] instret_cnt;

always @(posedge clk) begin
  if (rst) begin
    cycle_cnt <= 32'd0;
    instret_cnt <= 32'd0;
  end else if (sel && we && (ridx == 4'd2)) begin
    cycle_cnt <= 32'd0;
    instret_cnt <= 32'd0;
  end else begin
    cycle_cnt <= cycle_cnt + 32'd1;
    if (commit)
      instret_cnt <= instret_cnt + 32'd1;
  end
end

assign rdata = (!sel) ? 32'd0 :
  (ridx == 4'd0) ?  cycle_cnt :
  (ridx == 4'd1) ? instret_cnt :
               (ridx == 4'd15) ? 32'd49 :
               32'd0;
