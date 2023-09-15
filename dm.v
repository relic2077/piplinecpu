`include "ctrl_encode_def.v"
// data memory
module dm(clk, DMWr, addr, din,DMType,pc,dout);
   input          clk;
   input          DMWr;
   input  [31:0]   addr;
   input  [31:0]  din;
   input  [2:0]   DMType;
   input  [31:0]   pc;
   output [31:0]  dout;
   wire[1:0] sbop;
   wire swop;
   reg [31:0] dmem[1023:0];
   assign sbop=addr[1:0];
   assign swop=addr[1];
   always @(posedge clk)
      if (DMWr) begin
          begin  $display("din = %h",din);  end
         case(DMType)
            `dm_byte: 
               begin
                  case(sbop)
                  2'b00: dmem[addr[11:2]][7:0] <= din[7:0];
                  2'b01: dmem[addr[11:2]][15:8] <= din[7:0];
                  2'b10: dmem[addr[11:2]][23:16] <= din[7:0];
                  2'b11: dmem[addr[11:2]][31:24] <= din[7:0];
                  endcase
               end
            
            `dm_halfword: 
               begin
                  case(swop)
                  1'b0: dmem[addr[11:2]][15:0] <= din[15:0];
                  1'b1: dmem[addr[11:2]][31:16] <= din[15:0];
                  endcase
               end
            
            default:   dmem[addr[11:2]] <= din; 
         endcase
      end
   assign dout=dmem[addr[11:2]];
    
endmodule    
