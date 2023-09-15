  module EX_MEM(   input         clk,
    input         rst,
    //input         flush,
    //input  [31:0] PC_in,
    
    input  [4:0] RS1_in,         // read register id
    input  [4:0] RS2_in,         // read register id
    input  [31:0] RS1_value,         // read register value
    input  [31:0] RS2_value,         // read register value
    input  [4:0] rd_in,
    input  [31:0] ALU_Result_in,
    //input [4:0] ALUOp_in,
    input MemWrite_in,
    input RegWrite_in,
    input [2:0] DMType_in,
    
    input  [1:0]  WDSel_in,
    input  [31:0] pc_in,
    //output reg [31:0] PC_out,

    output reg[4:0]  rs1_out,         // read register id
    output reg[4:0]  rs2_out,         // read register id    
    output reg[31:0]  rs1_value_out,         // read register value
    output reg[31:0]  rs2_value_out,         // read register value
    output reg [4:0]  rd_out,          // write register id
    output reg [31:0] ALU_Result_out,
    //output reg [4:0]  ALUOp_out,       // ALU opertion
    output reg        MemWrite_out,    // output: memory write signal
    output reg        RegWrite_out,    // control signal to register write
    output reg [2:0]  DMType_out,     // read/write data length
    
    output reg [1:0]  WDSel_out,        // (register) write data selection
    output reg[31:0] pc_out
    //output reg [2:0]  NPCOp,       // next PC operation
    // to WB
    //output reg [6:0]  type
    );

  always @(posedge clk, posedge rst) begin
        if (rst ) begin
            rs1_out = 5'b0;
            rs2_out = 5'b0;

            rs1_value_out = 32'b0;
            rs2_value_out = 32'b0;
            rd_out = 5'b0;

            
            //NPCOp = 3'b0;
            ALU_Result_out= 32'b0;
            MemWrite_out = 1'b0;
            
            RegWrite_out = 1'b0;

            DMType_out = 3'b0;
            WDSel_out = 2'b0;
            pc_out=32'b0;
        end
        else begin
            rs1_out <= RS1_in;
            rs2_out <= RS2_in;

            rs1_value_out <= RS1_value;
            rs2_value_out <= RS2_value;
            rd_out <= rd_in;

            ALU_Result_out<= ALU_Result_in;
            //$display("ALU_Result_in = %h",ALU_Result_in);
            //$display("ALU_Result_out = %h",ALU_Result_out);
            //$display("rd_in = %h",rd_in);
            //$display("rd_out = %h",rd_out);
            MemWrite_out <= MemWrite_in;
            
            RegWrite_out <=  RegWrite_in;

            DMType_out <= DMType_in;
            WDSel_out <=WDSel_in;   
            pc_out<=pc_in;         
        end
    end

endmodule 
