  `include "ctrl_encode_def.v"
  module Hazard_Unit(input         clk, 
               input         rst,
               input  [4:0]  IF_ID_RS1, 
               input  [4:0]  IF_ID_RS2, 
               input  [4:0]  ID_EX_RD,
               input  ID_EX_MemRead,
               input  ID_EX_RegWrite,
               input  [31:0]ALU_result,
               input IF_ID_hasrs2,
               input IF_ID_without_rs,
               input is_jump,
               input [7:0]jump_type,
               output reg [2:0]NPCOp,
               output reg PC_Write,
               output reg IF_ID_Flush,
               output reg IF_ID_Write,
               output reg ID_EX_Flush
               );

  always @(*) begin
    if (rst) begin    //  reset
       PC_Write=1'b0;
       NPCOp=3'b000;
       IF_ID_Write=1'b0;
       IF_ID_Flush=1'b0;
       ID_EX_Flush=1'b0;
    end
    else 
      if ((!IF_ID_without_rs)&&(IF_ID_RS1==ID_EX_RD||(IF_ID_hasrs2&&IF_ID_RS2==ID_EX_RD))&&ID_EX_RD!=5'b0&&ID_EX_RegWrite&&ID_EX_MemRead) begin
          PC_Write=1'b0;
          IF_ID_Write=1'b0;
          ID_EX_Flush=1'b1;
          IF_ID_Flush=1'b0;
          NPCOp=3'b111;
      end
      else if(is_jump) begin
         case (jump_type)
		      `beq_type:  begin if(ALU_result==32'b0)begin
                               NPCOp=3'b001;
                               PC_Write=1'b1;
                               IF_ID_Write=1'b0;
                               ID_EX_Flush=1'b1;
                               IF_ID_Flush=1'b1;
                               //$display("beq");
                            end
                            else begin
                               NPCOp=3'b000; 
                               PC_Write=1'b1;
                               IF_ID_Write=1'b1;
                               ID_EX_Flush=1'b0;
                               IF_ID_Flush=1'b0;
                            end
                      end
		      `bne_type:	begin if(!ALU_result[0])begin
                               NPCOp=3'b001;
                               PC_Write=1'b1;
                               IF_ID_Write=1'b0;
                               ID_EX_Flush=1'b1;
                               IF_ID_Flush=1'b1;  
                               //$display("bne");
                            end
                            else begin
                               NPCOp=3'b000; 
                               PC_Write=1'b1;
                               IF_ID_Write=1'b1;
                               ID_EX_Flush=1'b0;
                               IF_ID_Flush=1'b0;
                            end
                      end
 		      `bge_type:	begin if(!ALU_result[0])begin
                               NPCOp=3'b001;
                               PC_Write=1'b1;
                               IF_ID_Write=1'b0;
                               ID_EX_Flush=1'b1;
                               IF_ID_Flush=1'b1;
                               //$display("ALU_result=%h",ALU_result);
                               //$display("bge");
                            end
                            else begin
                               NPCOp=3'b000; 
                               PC_Write=1'b1;
                               IF_ID_Write=1'b1;
                               ID_EX_Flush=1'b0;
                               IF_ID_Flush=1'b0;
                            end
                            
                      end
		      `blt_type:  begin if(!ALU_result[0])begin
                               NPCOp=3'b001;
                               PC_Write=1'b1;
                               IF_ID_Write=1'b0;
                               ID_EX_Flush=1'b1;
                               IF_ID_Flush=1'b1;
                               //$display("blt");
                            end
                            else begin
                               NPCOp=3'b000; 
                               PC_Write=1'b1;
                               IF_ID_Write=1'b1;
                               ID_EX_Flush=1'b0;
                               IF_ID_Flush=1'b0;
                            end
                            
                      end
		      `bgeu_type:	begin if(!ALU_result[0])begin
                               NPCOp=3'b001;
                               PC_Write=1'b1;
                               IF_ID_Write=1'b0;
                               ID_EX_Flush=1'b1;
                               IF_ID_Flush=1'b1;
                               //$display("bgeu");
                            end
                            else begin
                               NPCOp=3'b000; 
                               PC_Write=1'b1;
                               IF_ID_Write=1'b1;
                               ID_EX_Flush=1'b0;
                               IF_ID_Flush=1'b0;
                            end
                      end
		      `bltu_type:	begin if(!ALU_result[0])begin
                               NPCOp=3'b001;
                               PC_Write=1'b1;
                               IF_ID_Write=1'b0;
                               ID_EX_Flush=1'b1;
                               IF_ID_Flush=1'b1;
                               //$display("bltu");
                            end
                            else begin
                               NPCOp=3'b000; 
                               PC_Write=1'b1;
                               IF_ID_Write=1'b1;
                               ID_EX_Flush=1'b0;
                               IF_ID_Flush=1'b0;
                            end
                      end
          `jal_type:	begin     NPCOp=3'b010;
                               PC_Write=1'b1;
                               IF_ID_Write=1'b0;
                               ID_EX_Flush=1'b1;
                               IF_ID_Flush=1'b1;
                               //$display("jal");
                      end
          `jalr_type:	begin 
                               NPCOp=3'b100;
                               PC_Write=1'b1;
                               IF_ID_Write=1'b0;
                               ID_EX_Flush=1'b1;
                               IF_ID_Flush=1'b1;
                               //$display("jalr");
                      end
		      default:	  begin      NPCOp=3'b000;
                                     PC_Write=1'b1;
                                     IF_ID_Write=1'b0;
                                     ID_EX_Flush=1'b0;
                                     IF_ID_Flush=1'b0; end
	        endcase
      end
      else begin
          NPCOp=3'b000; 
          PC_Write=1'b1;
          IF_ID_Write=1'b1;
          ID_EX_Flush=1'b0;
          IF_ID_Flush=1'b0;
      end
  end


endmodule 
