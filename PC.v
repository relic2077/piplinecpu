module PC( clk, rst, NPC, PC,pcW,PCWrite );

  input              clk;
  input              rst;
  input       [31:0] NPC;
  input       PCWrite;
  output reg  [31:0] PC;
  output reg  [31:0] pcW;
  always @(posedge clk, posedge rst)
    begin
    if (rst) begin
      PC = 32'h0000_0000;
      pcW=32'h0000_0000;
//      PC <= 32'h0000_3000;
     end
    else if(PCWrite)
      begin
      pcW = PC;
      PC = NPC;
      end
     else begin
        PC =NPC;
     end
    end
endmodule

