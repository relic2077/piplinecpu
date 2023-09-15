  module  IF_ID(input         clk, 
               input         rst,
               input         IF_ID_write, 
               input         FLUSH,
               //input         Stall, 
               input  [31:0] inst_in,
               input  [31:0] PC_in,
               output reg[31:0] PC_toID,
               output reg[31:0] inst_toID);

  
  always @(posedge clk, posedge rst)
    if (rst||FLUSH) begin    //  reset
        PC_toID <=32'b0;
        inst_toID <=32'b0;
    end
      
    else 
      if (IF_ID_write) begin
          PC_toID <=PC_in;
          inst_toID <=inst_in;
        
      end
    

endmodule 
