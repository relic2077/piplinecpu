`include "ctrl_encode_def.v"

module NPC(PC,PC_EX, NPCOp, IMM,aluout, NPC);  // next pc module
    
   input  [31:0] PC;        // pc
   input  [31:0] PC_EX;
   input  [2:0]  NPCOp;     // next pc operation
   input  [31:0] IMM;       // immediate
	input [31:0] aluout;
   //input [31:0] rs1_value;
   output reg [31:0] NPC;   // next pc
   
   wire [31:0] PCPLUS4;
   
   assign PCPLUS4 = PC + 4; // pc + 4
   
   always @(*) begin
      //begin $display("NPCop%h",NPCOp); end
      case (NPCOp)
          `NPC_PLUS4:  NPC <= PCPLUS4;
          `NPC_BRANCH: NPC <= (PC_EX+IMM)& 32'hfffffffc;
          `NPC_JUMP:   NPC <= (PC_EX+IMM)& 32'hfffffffc;
		  `NPC_JALR:	  NPC <=aluout& 32'hfffffffc;  
		  `NPC_STOP:	  NPC <=PC;  
          default:     NPC <= PCPLUS4;
      endcase
   end // end always
   
endmodule
