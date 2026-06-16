`timescale 1ns / 1ps

module if_id_reg(

    input clk,
    input reset,
    input write_en,
    input flush,

    input [31:0] pc_plus_4_in,
    input [31:0] inst_in,

    output reg [31:0] pc_plus_4_out,
    output reg [31:0] inst_out
);

always @(posedge clk or posedge reset)
begin

    if(reset || flush)
    begin
        pc_plus_4_out <= 32'b0;
        inst_out      <= 32'b0;
    end

    else if(write_en)
    begin
        pc_plus_4_out <= pc_plus_4_in;
        inst_out      <= inst_in;
    end

end

endmodule