  `include "ctrl_encode_def.v"
  module Forwarding_Unit( 
               input         rst,
               input  [4:0]  ID_EX_RS1, 
               input  [4:0]  ID_EX_RS2, 
               input  [4:0]  EX_MEM_RD,
               input  [4:0]  MEM_WB_RD,
               //input  EX_MEM_MemRead,
               //input  MEM_WB_MemRead,
               input  EX_MEM_RegWrite,
               input  MEM_WB_RegWrite,
               input [31:0] DataFromEX_MEM,
               input [31:0] DataFromMEM_WB,
               input ID_EX_hasrs2,
               input ID_EX_without_rs,
               output reg ForwardA,
               output reg ForwardB,
               output reg [31:0] Forward_data1,
               output reg [31:0] Forward_data2
               );

  reg [31:0] rf[31:0];

  integer i;

  always @(*) begin
    if (rst) begin    //  reset
       ForwardA=1'b0;
       ForwardB=1'b0;
       Forward_data1=32'b0;
       Forward_data2=32'b0;
    end
    else if(!ID_EX_without_rs) begin 
    begin
      if (ID_EX_RS1==EX_MEM_RD&&EX_MEM_RegWrite&&EX_MEM_RD!=5'b0) begin
          ForwardA=1'b1;
          Forward_data1=DataFromEX_MEM;
           //$display("Forward_data1 = %h",Forward_data1);
           //$display("ForwardA = %h",ForwardA);
      end
      else if(ID_EX_RS1==MEM_WB_RD&&MEM_WB_RegWrite&&MEM_WB_RD!=5'b0) begin
          ForwardA=1'b1;
          Forward_data1=DataFromMEM_WB;
           //$display("Forward_data1 = %h",Forward_data1);
           //$display("ForwardA = %h",ForwardA);
      end
      else begin ForwardA=1'b0; Forward_data1=32'b0; end end
      begin
      if (ID_EX_RS2==EX_MEM_RD&&ID_EX_hasrs2&&EX_MEM_RegWrite&&EX_MEM_RD!=5'b0) begin
          ForwardB=1'b1;
          Forward_data2=DataFromEX_MEM;
           //$display("Forward_data2 = %h",Forward_data2);
           //$display("ForwardB = %h",ForwardB);
           //$display("hasrs2= %h",ID_EX_hasrs2);
      end
      else if(ID_EX_RS2==MEM_WB_RD&&ID_EX_hasrs2&&MEM_WB_RegWrite&&MEM_WB_RD!=5'b0) begin
          ForwardB=1'b1;
          Forward_data2=DataFromMEM_WB;
          //$display("Forward_data2 = %h",Forward_data2);
          //$display("ForwardB = %h",ForwardB);
      end
      else begin ForwardB=1'b0;  Forward_data2=32'b0; end end end
    else begin ForwardA=1'b0; Forward_data1=32'b0;ForwardB=1'b0;  Forward_data2=32'b0; end
  end
  

  

endmodule