module Reg_Mux (rst,clk,sel,enable,in,out);

parameter RST_TYPE = "SYNC";
parameter size = 18;
input rst,clk,sel,enable;
input [size-1:0] in;
output [size-1:0] out;
reg [size-1:0] out_reg;

generate
    if (RST_TYPE == "SYNC") begin : sync_reset_block
        always @(posedge clk) begin
            if (enable) begin
                out_reg <= in;
            end
        end
    end else if (RST_TYPE == "ASYNC") begin : async_reset_block
        always @(posedge clk or posedge rst) begin
            if (rst) begin
                out_reg <= {size{1'b0}};
            end else if (enable) begin
                out_reg <= in;
            end
        end
    end
endgenerate

assign out = (sel == 1'b1) ? out_reg : {size{1'b0}};

endmodule
