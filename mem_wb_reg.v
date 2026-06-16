`timescale 1ns / 1ps

module mem_wb_reg(

    input clk,
    input reset,

    input reg_write_in,
    input mem_to_reg_in,

    input [31:0] read_data_in,
    input [31:0] alu_result_in,

    input [4:0] dest_reg_in,

    output reg reg_write_out,
    output reg mem_to_reg_out,

    output reg [31:0] read_data_out,
    output reg [31:0] alu_result_out,

    output reg [4:0] dest_reg_out
);

always @(posedge clk or posedge reset)
begin

    if(reset)
    begin
        reg_write_out <= 0;
        mem_to_reg_out <= 0;

        read_data_out <= 0;
        alu_result_out <= 0;
        dest_reg_out <= 0;
    end

    else
    begin
        reg_write_out <= reg_write_in;
        mem_to_reg_out <= mem_to_reg_in;

        read_data_out <= read_data_in;
        alu_result_out <= alu_result_in;
        dest_reg_out <= dest_reg_in;
    end

end

endmodule