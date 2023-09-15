module ID_EX(
    input         clk,
    input         rst,
    input         flush,

    input  [31:0] PC_in,
    
    input  [4:0] RS1_in,         // read register id
    input  [4:0] RS2_in,         // read register id
    input  [31:0] RS1_value,         // read register value
    input  [31:0] RS2_value,         // read register value
    input  [4:0] rd_in,
    input [4:0] ALUOp_in,
    input MemWrite_in,
    input MemRead_in,
    input RegWrite_in,
    input [2:0] DMType_in,
    input [31:0] imm_in,
    input  [1:0]  WDSel_in,
    input hasrs2_in,
    input without_rs_in,
    input ALUsrc_in,
    input        is_jump_in,
    input[7:0]   jump_type_in,


    output reg [31:0] PC_out,
    output reg[4:0]  rs1_out,         // read register id
    output reg[4:0]  rs2_out,         // read register id
    output reg[31:0]  rs1_value_out,         // read register value
    output reg[31:0]  rs2_value_out,         // read register value
    output reg [4:0]  rd_out,          // write register id
    
    output reg [4:0]  ALUOp_out,       // ALU opertion
    output reg        MemWrite_out,    // output: memory write signal
    output reg        MemRead_out,
    output reg        RegWrite_out,    // control signal to register write
    output reg [2:0]  DMType_out,      // read/write data length
    output reg [31:0] imm_out,      // imm_out
    output reg [1:0]  WDSel_out,        // (register) write data selection
    output reg hasrs2_out,
    output reg without_rs_out,
    output reg ALUsrc_out,
    output reg is_jump_out,
    output reg [7:0]jump_type_out
    //output reg [2:0]  NPCOp,       // next PC operation
    // to WB
    //output reg [6:0]  type,
);

    
    always @(posedge clk, posedge rst) begin
        if (rst || flush) begin
            PC_out <= 32'b0;
            rs1_out <= 5'b0;
            rs2_out <= 5'b0;
  
            rs1_value_out <= 32'b0;
            rs2_value_out <= 32'b0;
            rd_out <= 5'b0;
           
           
            
            //NPCOp <= 3'b0;
            ALUOp_out<= 5'b0;
            MemWrite_out <= 1'b0;
            MemRead_out<=1'b0;
            RegWrite_out <= 1'b0;

            DMType_out <= 3'b0;
            imm_out <= 32'b0;
            WDSel_out <= 2'b0;
            hasrs2_out<= 1'b0;
            without_rs_out<= 1'b0;
            ALUsrc_out<=1'b0;
            is_jump_out<=1'b0;
            jump_type_out<=8'b0;
        end
        else begin
            PC_out <= PC_in;
            rs1_out <= RS1_in;
            rs2_out <= RS2_in;
            
            rs1_value_out <= RS1_value;
            rs2_value_out <= RS2_value;
            rd_out <= rd_in;

            ALUOp_out<= ALUOp_in;
            MemWrite_out <= MemWrite_in;
            MemRead_out<=MemRead_in;
            RegWrite_out <=  RegWrite_in;

            DMType_out <= DMType_in;
            imm_out <= imm_in;
            WDSel_out <= WDSel_in;
            hasrs2_out<= hasrs2_in;
            without_rs_out<= without_rs_in;
            ALUsrc_out<=ALUsrc_in;
            is_jump_out<=is_jump_in;
            jump_type_out<=jump_type_in;
        end
    end
endmodule
