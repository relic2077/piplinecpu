  module MEM_WB(   input         clk,
    input         rst,
    input  [4:0] rd_in,
    input  [31:0] ALU_Result_in,
    input [4:0] ALUOp_in,
    input RegWrite_in,
    input [2:0] DMType_in,
    input [31:0] DM_output,
    input [1:0]  WDSel_in,
    input [31:0] pc_in,
    output reg [4:0]  rd_out,          // write register id
    output reg [31:0] ALU_Result_out,
    output reg [4:0]  ALUOp_out,       // ALU opertion
    output reg        RegWrite_out,    // control signal to register write
    output reg [2:0]  DMType_out,     // read/write data length
    output reg [31:0] DM_to_reg,
    output reg [1:0]  WDSel_out,        // (register) write data selection
    output reg[31:0]  pc_out
    );

  always @(posedge clk, posedge rst) begin
        if (rst ) begin
            //rs1_out <= 5'b0;
            //rs2_out <= 5'b0;
            //rs1_value_out <= 32'b0;
            //rs2_value_out <= 32'b0;
            rd_out = 5'b0;
            //NPCOp = 3'b0;
            ALU_Result_out= 32'b0;
            //MemWrite_out = 1'b0;
            RegWrite_out = 1'b0;
            DMType_out = 3'b0;
            DM_to_reg = 32'b0;
            WDSel_out= 2'b0;
            pc_out=32'b0;
        end
        else begin
            //rs1_out = RS1_in;
            //rs2_out = RS2_in;
            //rs1_value_out = RS1_value;
            //rs2_value_out = RS2_value;
            rd_out <= rd_in;
            ALU_Result_out<= ALU_Result_in;
            //MemWrite_out = MemWrite_in;
            RegWrite_out <=  RegWrite_in;
            DMType_out <= DMType_in;
            DM_to_reg  <=DM_output;
            WDSel_out<= WDSel_in;
            pc_out<=pc_in;
        end
    end

endmodule 
