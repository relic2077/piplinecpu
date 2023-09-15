`include "ctrl_encode_def.v"
`include "ctrl.v"
`include "PC.v"
`include "NPC.v"
`include "EXT.v"
`include "RF.v"
`include "alu.v"
`include "IF_ID.v"
`include "ID_EX.v"
`include "EX_MEM.v"
`include "MEM_WB.v"
`include "Hazard_Unit.v"
`include "Forwarding_Unit.v"

module SCPU(
    input      clk,            // clock
    input      reset,          // reset
    input [31:0]  inst_in,     // instruction
    input [31:0]  Data_in,     // data from data memory
    input MIO_ready,
    input INT,
    output CPU_MIO,
    output    mem_w_todmctrl,          // output: memory write signal
    output [31:0] PC_out,     // PC address
    output [31:0] pcW,     // PC address
      // memory write
    output [31:0] Addr_out,   // ALU output
    output [31:0] Data_out,// data to data memory
    output [2:0] DMType_todmctrl  //output [2:0] DMType
);
    wire        RegWrite;    // control signal to register write
    wire [5:0]       EXTOp;       // control signal to signed extension
    wire [4:0]  ALUOp;       // ALU opertion
    wire [2:0]  NPCOp;       // next PC operation

    wire [1:0]  WDSel;       // (register) write data selection
    //wire [1:0]  GPRSel;      // general purpose register selection
    
    
    wire        Zero;        // ALU ouput zero

    wire [31:0] NPC;         // next PC
     
    wire [4:0]  rs1;          // rs
    wire [4:0]  rs2;          // rt
    wire [4:0]  rd;          // rd
    wire [6:0]  Op;          // opcode
    wire [6:0]  Funct7;       // funct7
    wire [2:0]  Funct3;       // funct3
    wire [11:0] Imm12;       // 12-bit immediate
    wire [31:0] Imm32;       // 32-bit immediate
    wire [19:0] IMM;         // 20-bit immediate (address)
    wire [4:0]  A3;          // register address for write
    reg [31:0] WD;          // register write data
    wire [31:0] RD1,RD2;         // register data specified by rs
    wire [31:0] A;
    wire [31:0] B1;           // operator for ALU B
	wire [31:0] B2;
	wire [4:0] iimm_shamt;
	wire [11:0] iimm,simm,bimm;
	wire [19:0] uimm,jimm;
	wire [31:0] immout;
    wire[31:0] aluout;
    //wire[1:0] lbop;
    //wire  lhop;
    wire   IF_ID_Write; 
    wire   IF_ID_Flush;  
    wire[31:0]  PC_toID;
    wire[31:0]  inst_toID;

    wire ID_EX_Flush;
    wire[2:0] DMType;
    wire mem_w;
    wire hasrs2_in;
    wire without_rs_in;

    wire[31:0]  PC_toEX;
    wire[4:0]   rs1_toEX;         // read register id
    wire[4:0]   rs2_toEX;         // read register id
    wire[31:0]  rs1_value_toEX;         // read register value
    wire[31:0]  rs2_value_toEX;         // read register value
    wire[4:0]   rd_toEX;          // write register id
    wire[4:0]   ALUOp_toEX;       // ALU opertion
    wire        MemWrite_toEX;    // output: memory write signal
    wire        RegWrite_toEX;    // control signal to register write
    wire[2:0]   DMType_toEX;      // read/write data length
    wire[31:0]  imm_toEX;      // imm_out
    wire[1:0]   WDSel_toEX;        // (register) write data selection
    wire        hasrs2_toEX;
    wire        without_rs_toEX;
    wire        ALUSrc;
    wire        ALUSrc_toEX;
    wire        is_jump;
    wire[7:0]   jump_type;
    wire        is_jump_toEX;
    wire[7:0]   jump_type_toEX;
    wire        MemRead_toEX;
    wire PC_Write;
    wire MEM_Read;
	wire ForwardA;
    wire ForwardB;
    wire[31:0] Forward_data1;
    wire[31:0] Forward_data2;
    wire[4:0]   rs1_toMEM;         // read register id
    wire[4:0]   rs2_toMEM;         // read register id
    wire[31:0]  rs1_value_toMEM;         // read register value
    wire[31:0]  rs2_value_toMEM;         // read register value
    wire[4:0]   rd_toMEM;          // write register id
    wire[4:0]   ALUOp_toMEM;       // ALU opertion
    wire        MemWrite_toMEM;    // output: memory write signal
    wire        RegWrite_toMEM;    // control signal to register write
    wire[2:0]   DMType_toMEM;      // read/write data length
    wire[31:0]  imm_toMEM;      // imm_out
    wire[1:0]   WDSel_toMEM;        // (register) write data selection
    wire[31:0]  ALU_Result_toMEM;
    wire [4:0] rd_toRF;
    wire [31:0] ALU_Result_toRF;
    wire RegWrite_toRF; 
    wire [1:0] WDSel_toWB;
    wire[31:0] DM_to_reg;
  
    //assign lbop=Addr_out[1:0];
    //assign lhop=Addr_out[1];
    wire[31:0]rs2_value_toEX1;
    wire[31:0]PC_toMEM;
    wire[31:0]PC_toRF;
	
   
	
   // instantiation of control unit

   IF_ID U_IF_ID(.clk(clk), 
                 .rst(reset),
                 .IF_ID_write(IF_ID_Write), 
                 .FLUSH(IF_ID_Flush),
               //input         Stall, 
                 .inst_in(inst_in),
                 .PC_in(PC_out),
                 .PC_toID(PC_toID),
                 .inst_toID(inst_toID));

    assign iimm_shamt=inst_toID[24:20];
	assign iimm=inst_toID[31:20];
	assign simm={inst_toID[31:25],inst_toID[11:7]};
	assign bimm={inst_toID[31],inst_toID[7],inst_toID[30:25],inst_toID[11:8]};
	assign uimm=inst_toID[31:12];
	assign jimm={inst_toID[31],inst_toID[19:12],inst_toID[20],inst_toID[30:21]};
   
    assign Op = inst_toID[6:0];  // instruction
    assign Funct7 = inst_toID[31:25]; // funct7
    assign Funct3 = inst_toID[14:12]; // funct3
    assign rs1 = inst_toID[19:15];  // rs1
    assign rs2 = inst_toID[24:20];  // rs2
    assign rd = inst_toID[11:7];  // rd

    
	ctrl U_ctrl(
		.Op(Op), .Funct7(Funct7), .Funct3(Funct3), .Zero(Zero),//.aluout(aluout), 
		.RegWrite(RegWrite), .MemWrite(mem_w),
		.EXTOp(EXTOp), .ALUOp(ALUOp), .NPCOp(NPCOp), 
		.ALUSrc(ALUSrc), .WDSel(WDSel),.DMType(DMType),
        .has_rs2(has_rs2),.without_rs(without_rs),.is_jump(is_jump),.jump_type(jump_type),.memread(MEM_Read)
	);
    RF U_RF(
		.clk(clk), .rst(reset),
		.RFWr(RegWrite_toRF), 
		.A1(rs1), .A2(rs2), .A3(rd_toRF), 
        //.J(jump_type_toEX[7:6]),
        //.PCtoRF(PC_toEX+4),
        //.j_rd(rd_toEX),
		.WD(WD), 
		.RD1(RD1), .RD2(RD2)
		//.reg_sel(reg_sel),
		//.reg_data(reg_data)
	);
    EXT U_EXT(
		.iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
		.uimm(uimm), .jimm(jimm),
		.EXTOp(EXTOp), .immout(immout)
	);
    Hazard_Unit U_Hazard(.clk(clk), 
                         .rst(reset),
                         .IF_ID_RS1(rs1), 
                         .IF_ID_RS2(rs2), 
                         .ID_EX_RD(rd_toEX),
                         .ID_EX_MemRead(MemRead_toEX),
                         .ID_EX_RegWrite(RegWrite_toEX),
                         //.rs1_value(RD1),
                         //.rs2_value(RD2),
                         .ALU_result(aluout),
                         .IF_ID_hasrs2(has_rs2),
                         .IF_ID_without_rs(without_rs),
                         .is_jump(is_jump_toEX),
                         .jump_type(jump_type_toEX),
                         .NPCOp(NPCOp),
                         .PC_Write(PC_Write),
                         .IF_ID_Flush(IF_ID_Flush),
                         .IF_ID_Write(IF_ID_Write),
                         .ID_EX_Flush(ID_EX_Flush));
	NPC U_NPC(.PC(PC_out), .NPCOp(NPCOp),.PC_EX(PC_toEX), .IMM(imm_toEX),.aluout(aluout), .NPC(NPC));
    PC U_PC(.clk(clk), .rst(reset), .NPC(NPC), .PC(PC_out),.pcW(pcW),.PCWrite(PC_Write) );

    ID_EX U_ID_EX(.clk(clk),
                  .rst(reset),
                  .flush(ID_EX_Flush),
                  .PC_in(PC_toID),
                  .RS1_in(rs1),         // read register id
                  .RS2_in(rs2),         // read register id
                  .RS1_value(RD1),         // read register value
                  .RS2_value(RD2),         // read register value
                  .rd_in(rd),
                  .ALUOp_in(ALUOp),
                  .MemWrite_in(mem_w),
                  .MemRead_in(MEM_Read),
                  .RegWrite_in(RegWrite),
                  .DMType_in(DMType),
                  .imm_in(immout),  //immout from ext
                  .WDSel_in(WDSel),
                  .hasrs2_in(has_rs2),
                  .without_rs_in(without_rs),
                  .ALUsrc_in(ALUSrc),
                  .is_jump_in(is_jump),
                  .jump_type_in(jump_type),
                  .PC_out(PC_toEX),
                  .rs1_out(rs1_toEX),         // read register id
                  .rs2_out(rs2_toEX),         // read register id
                  .rs1_value_out(rs1_value_toEX),         // read register value
                  .rs2_value_out(rs2_value_toEX),         // read register value
                  .rd_out(rd_toEX),          // write register id
                  .ALUOp_out(ALUOp_toEX),       // ALU opertion
                  .MemWrite_out(MemWrite_toEX),    // output: memory write signal
                  .MemRead_out(MemRead_toEX),
                  .RegWrite_out(RegWrite_toEX),    // control signal to register write
                  .DMType_out(DMType_toEX),      // read/write data length
                  .imm_out(imm_toEX),      // imm_out
                  .WDSel_out(WDSel_toEX),        // (register) write data selection
                  .hasrs2_out(hasrs2_toEX),
                  .without_rs_out(without_rs_toEX),
                  .ALUsrc_out(ALUSrc_toEX),
                  .is_jump_out(is_jump_toEX),
                  .jump_type_out(jump_type_toEX));
    //always @(ID_EX_Flush) begin
        //$display("ID_EX_Flush=%h",ID_EX_Flush);
    //end

    

    Forwarding_Unit U_Forwarding(.rst(reset),
               .ID_EX_RS1(rs1_toEX), 
               .ID_EX_RS2(rs2_toEX), 
               .EX_MEM_RD(rd_toMEM),
               .MEM_WB_RD(rd_toRF),
               //.EX_MEM_MemRead(),
               //.MEM_WB_MemRead(),
               .EX_MEM_RegWrite(RegWrite_toMEM),
               .MEM_WB_RegWrite(RegWrite_toRF),
               .DataFromEX_MEM(ALU_Result_toMEM),
               .DataFromMEM_WB(WD),
               .ID_EX_hasrs2(hasrs2_toEX),
               .ID_EX_without_rs(without_rs_toEX),
               .ForwardA(ForwardA),
               .ForwardB(ForwardB),
               .Forward_data1(Forward_data1),
               .Forward_data2(Forward_data2));

    
    
 // instantiation of pc unit
	assign A  = (ForwardA) ? Forward_data1 : rs1_value_toEX;
	assign B1 = (ALUSrc_toEX) ? imm_toEX : rs2_value_toEX;
	assign B2 = (ForwardB) ? Forward_data2 : B1;

   
   
// instantiation of alu unit
	alu U_alu(.A(A), .B(B2), .ALUOp(ALUOp_toEX), .C(aluout), .Zero(Zero), .PC(PC_toEX));
    
    //always @(A,B1,B2,aluout) begin
      //$display("A=%h",A);
      //$display("B1=%h",B1);
      //$display("B2=%h",B2);
      //$display("aluout=%h",aluout);
    //end
    

    
    assign rs2_value_toEX1=(ForwardB) ? Forward_data2 : rs2_value_toEX;
    EX_MEM U_EX_MEM(.clk(clk),
    .rst(reset),
    .RS1_in(rs1_toEX),         // read register id
    .RS2_in(rs2_toEX),         // read register id
    .RS1_value(rs1_value_toEX),         // read register value
    .RS2_value(rs2_value_toEX1),         // read register value
    .rd_in(rd_toEX),
    .ALU_Result_in(aluout),
    //.ALUOp_in(ALUOp_toEX),
    .MemWrite_in(MemWrite_toEX),
    .RegWrite_in(RegWrite_toEX),
    .DMType_in(DMType_toEX),
    .WDSel_in(WDSel_toEX),
    .pc_in(PC_toEX),
    .rs1_out(rs1_toMEM),         // read register id
    .rs2_out(rs2_toMEM),         // read register id    
    .rs1_value_out(rs1_value_toMEM),         // read register value
    .rs2_value_out(rs2_value_toMEM),         // read register value
    .rd_out(rd_toMEM),          // write register id
    .ALU_Result_out(ALU_Result_toMEM),
    //.ALUOp_out(),       // ALU opertion
    .MemWrite_out(MemWrite_toMEM),    // output: memory write signal
    .RegWrite_out(RegWrite_toMEM),    // control signal to register write
    .DMType_out(DMType_toMEM),     // read/write data length
    
    .WDSel_out(WDSel_toMEM),        // (register) write data selection
    .pc_out(PC_toMEM)
    );
    assign Data_out = rs2_value_toMEM; 
    assign DMType_todmctrl=DMType_toMEM;
    assign mem_w_todmctrl=MemWrite_toMEM;
    assign Addr_out=ALU_Result_toMEM;
//please connnect the CPU by yourself



//always @(Data_in) begin
    //$display("Data_in=%h",Data_in);
//end
MEM_WB U_MEM_WB(.clk(clk),
                .rst(reset),
                .rd_in(rd_toMEM),
                .ALU_Result_in(ALU_Result_toMEM),
                //.ALUOp_in,
                .RegWrite_in(RegWrite_toMEM),
                //.DMType_in(DMType_toMEM),
                .DM_output(Data_in),
                .WDSel_in(WDSel_toMEM),
                .pc_in(PC_toMEM),
                .rd_out(rd_toRF),          // write register id
                .ALU_Result_out(ALU_Result_toRF),
                //.ALUOp_out,       // ALU opertion
                .RegWrite_out(RegWrite_toRF),    // control signal to register write
                //.DMType_out,     // read/write data length
                .DM_to_reg(DM_to_reg),
                .WDSel_out(WDSel_toWB),
                .pc_out(PC_toRF));



always @*
begin
	case(WDSel_toWB)
		`WDSel_FromALU: WD=ALU_Result_toRF;
		`WDSel_FromMEM: WD=DM_to_reg;
        `WDSel_FromPC:WD=PC_toRF+4;
	endcase
end


endmodule