// `include "ctrl_encode_def.v"

//123
module ctrl(Op, Funct7, Funct3, Zero,//aluout, 
            RegWrite, MemWrite,
            EXTOp, ALUOp, NPCOp, 
            ALUSrc,  WDSel,DMType,
            has_rs2,without_rs,is_jump,jump_type,memread
            );
            
   input  [6:0] Op;       // opcode
   input  [6:0] Funct7;    // funct7
   input  [2:0] Funct3;    // funct3
   input        Zero;
   //input  [31:0]aluout;
   output       RegWrite; // control signal for register write
   output       MemWrite; // control signal for memory write
   output [5:0] EXTOp;    // control signal to signed extension
   output [4:0] ALUOp;    // ALU opertion
   output [2:0] NPCOp;    // next pc operation
   output       ALUSrc;   // ALU source for A
	 output [2:0] DMType;
    // output [1:0] GPRSel;   // general purpose register selection
   output [1:0] WDSel;    // (register) write data selection
   output has_rs2;
   output without_rs;
   output is_jump;
   output [7:0]jump_type;
   output memread;
  // r format
    wire rtype  = ~Op[6]&Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0110011
    wire i_add  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // add 0000000 000
    wire i_sub  = rtype& ~Funct7[6]& Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // sub 0100000 000
    wire i_or   = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& Funct3[1]&~Funct3[0]; // or 0000000 110
    wire i_and  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& Funct3[1]& Funct3[0]; // and 0000000 111
    wire i_xor  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& ~Funct3[1]& ~Funct3[0]; // xor 0000000 100
    wire i_sll  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& ~Funct3[2]& ~Funct3[1]& Funct3[0]; // sll 0000000 001
    wire i_sra  = rtype& ~Funct7[6]&Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& ~Funct3[1]& Funct3[0]; // sra 0100000 101
    wire i_srl  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& ~Funct3[1]& Funct3[0]; // srl 0000000 101
    wire i_slt  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& ~Funct3[2]& Funct3[1]& ~Funct3[0]; // slt 0000000 010
    wire i_sltu  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& ~Funct3[2]& Funct3[1]& Funct3[0]; // sltu 0000000 011
 // i format
   wire itype_l  = ~Op[6]&~Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0000011
   wire i_lw  = itype_l& ~Funct3[2]& Funct3[1]& ~Funct3[0]; // lw 010
   wire i_lb  = itype_l& ~Funct3[2]& ~Funct3[1]& ~Funct3[0]; // lb 000
   wire i_lh  = itype_l& ~Funct3[2]& ~Funct3[1]& Funct3[0]; // lh 001
   wire i_lbu  = itype_l& Funct3[2]& ~Funct3[1]& ~Funct3[0]; // lbu 100
   wire i_lhu  = itype_l& Funct3[2]& ~Funct3[1]& Funct3[0]; // lwu 101

// i format
    wire itype_r  = ~Op[6]&~Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0010011
    wire i_addi  =  itype_r& ~Funct3[2]& ~Funct3[1]& ~Funct3[0]; // addi 000
    wire i_ori  =  itype_r& Funct3[2]& Funct3[1]&~Funct3[0]; // ori 110
	  wire i_andi  =  itype_r& Funct3[2]& Funct3[1]& Funct3[0]; // andi 111
    wire i_xori  =  itype_r& Funct3[2]& ~Funct3[1]&~Funct3[0]; // xori 100
    wire i_srai  = itype_r& ~Funct7[6]&Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& ~Funct3[1]& Funct3[0]; // srai 0100000 101
    wire i_srli  = itype_r& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& ~Funct3[1]& Funct3[0]; // srli 0000000 101
    wire i_slli  = itype_r& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& ~Funct3[2]& ~Funct3[1]& Funct3[0]; // slli 0000000 001
    wire i_slti  = itype_r& ~Funct3[2]& Funct3[1]& ~Funct3[0]; // slti 010
    wire i_sltiu  = itype_r& ~Funct3[2]& Funct3[1]& Funct3[0]; // sltiu 011
 //jalr
	wire i_jalr =Op[6]&Op[5]&~Op[4]&~Op[3]&Op[2]&Op[1]&Op[0];//jalr 1100111

  // s format
   wire stype  = ~Op[6]&Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];//0100011
   wire i_sw   =  stype& ~Funct3[2]& Funct3[1]&~Funct3[0]; // sw 010
   wire i_sb   =  stype& ~Funct3[2]& ~Funct3[1]&~Funct3[0]; // sb 000
   wire i_sh   =  stype& ~Funct3[2]& ~Funct3[1]& Funct3[0]; // sh 001

  // sb format
   wire sbtype  = Op[6]&Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];//1100011
   wire i_beq  = sbtype& ~Funct3[2]& ~Funct3[1]&~Funct3[0]; // beq
   wire i_bne  = sbtype& ~Funct3[2]& ~Funct3[1]&Funct3[0]; // bne
   wire i_blt  = sbtype&  Funct3[2]& ~Funct3[1]&~Funct3[0]; // blt
   wire i_bge  = sbtype&  Funct3[2]& ~Funct3[1]& Funct3[0]; // bge
   wire i_bltu  = sbtype& Funct3[2]&  Funct3[1]&~Funct3[0]; // bltu
   wire i_bgeu  = sbtype& Funct3[2]&  Funct3[1]& Funct3[0]; // bgeu
	
 // j format
   wire i_jal  = Op[6]& Op[5]&~Op[4]& Op[3]& Op[2]& Op[1]& Op[0];  // jal 1101111
 // u format
   wire i_lui=~Op[6]&Op[5]&Op[4]&~Op[3]&Op[2]&Op[1]&Op[0]; //0110111
   wire i_auipc=~Op[6]&~Op[5]&Op[4]&~Op[3]&Op[2]&Op[1]&Op[0]; //0010111
   
  // generate control signals
  assign RegWrite   = rtype | itype_r | i_lui|i_auipc|itype_l| i_slli| i_jal | i_jalr; // register write
  assign MemWrite   = stype;                           // memory write
  assign ALUSrc     = itype_r | stype | i_jal | i_jalr|i_lui|i_auipc|itype_l;   // ALU B is from instruction immediate

  // signed extension
  // EXT_CTRL_ITYPE_SHAMT 6'b100000
  // EXT_CTRL_ITYPE	      6'b010000
  // EXT_CTRL_STYPE	      6'b001000
  // EXT_CTRL_BTYPE	      6'b000100
  // EXT_CTRL_UTYPE	      6'b000010
  // EXT_CTRL_JTYPE	      6'b000001
  assign EXTOp[5] = i_srli|i_srai|i_slli;
  assign EXTOp[4]    =  i_ori | i_andi | i_jalr|i_addi|i_xori|i_slti|i_sltiu|itype_l;  
  assign EXTOp[3]    = stype; 
  assign EXTOp[2]    = sbtype; 
  assign EXTOp[1]    = i_lui|i_auipc;   
  assign EXTOp[0]    = i_jal;         


  
  
  // WDSel_FromALU 2'b00
  // WDSel_FromMEM 2'b01
  // WDSel_FromPC  2'b10 
  assign WDSel[0] = itype_l;
  assign WDSel[1] = i_jal|i_jalr;
  // loadop_lw 3'b000
  // loadop_lb 3'b010
  // loadop_lbu 3'b011
  // loadop_lh 3'b100
  // loadop_lhu 3'b110 
  assign DMType[0] = i_lb|i_lh|i_sh|i_sb;
  assign DMType[1] = i_lb |i_lhu|i_sb;
  assign DMType[2] = i_lbu;
  // NPC_PLUS4   3'b000
  // NPC_BRANCH  3'b001
  // NPC_JUMP    3'b010
  // NPC_JALR	3'b100
  //assign NPCOp[0] = (i_beq & Zero)|(i_bne & !aluout[0])|(i_bge&!aluout[0])|(i_blt&!aluout[0])|(i_bgeu&!aluout[0])|(i_bltu&!aluout[0]);
  //assign NPCOp[1] = i_jal;
	//assign NPCOp[2]=i_jalr;
  

 
	assign ALUOp[0] = itype_l| i_jalr|stype|i_addi|i_ori|i_add|i_or|i_sll|i_slli|i_sra|i_srai|i_sltu|i_sltiu|i_lui|i_bne|i_bge|i_bgeu;
	assign ALUOp[1] = i_andi|i_jalr|itype_l|stype|i_addi|i_add|i_and|i_sll|i_slli|i_slt|i_sltu|i_slti|i_sltiu|i_auipc|i_blt|i_bge;
	assign ALUOp[2] = i_andi|i_and|i_ori|i_or|i_beq|i_bne|i_sub|i_xor|i_xori|i_sll|i_slli|i_blt|i_bge;
	assign ALUOp[3] = i_andi|i_and|i_ori|i_or|i_xor|i_xori|i_sll|i_slli|i_slt|i_sltu|i_slti|i_sltiu|i_bltu|i_bgeu;
	assign ALUOp[4] = i_sra|i_srl|i_srai|i_srli;

  assign has_rs2=rtype||stype||sbtype;
  assign without_rs=i_jal||i_lui||i_auipc;
  assign is_jump=i_jal|i_jalr|sbtype;
  assign jump_type[0]=i_beq;
  assign jump_type[1]=i_bne;
  assign jump_type[2]=i_bge;
  assign jump_type[3]=i_blt;
  assign jump_type[4]=i_bgeu;
  assign jump_type[5]=i_bltu;
  assign jump_type[6]=i_jal;
  assign jump_type[7]=i_jalr;
  assign memread=itype_l;

endmodule
