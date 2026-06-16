`timescale 1ns / 1ps

module id_ex_reg(

    input clk,
    input reset,

    input reg_write_in,
    input mem_to_reg_in,
    input mem_read_in,
    input mem_write_in,
    input reg_dst_in,
    input alu_src_in,

    input [1:0] alu_op_in,

    input [31:0] pc_plus_4_in,
    input [31:0] rdata1_in,
    input [31:0] rdata2_in,
    input [31:0] sign_ext_in,

    input [4:0] rs_in,
    input [4:0] rt_in,
    input [4:0] rd_in,

    output reg reg_write_out,
    output reg mem_to_reg_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg reg_dst_out,
    output reg alu_src_out,

    output reg [1:0] alu_op_out,

    output reg [31:0] pc_plus_4_out,
    output reg [31:0] rdata1_out,
    output reg [31:0] rdata2_out,
    output reg [31:0] sign_ext_out,

    output reg [4:0] rs_out,
    output reg [4:0] rt_out,
    output reg [4:0] rd_out
);

always @(posedge clk or posedge reset)
begin

    if(reset)
    begin
        reg_write_out <= 0;
        mem_to_reg_out <= 0;
        mem_read_out <= 0;
        mem_write_out <= 0;
        reg_dst_out <= 0;
        alu_src_out <= 0;
        alu_op_out <= 0;

        pc_plus_4_out <= 0;
        rdata1_out <= 0;
        rdata2_out <= 0;
        sign_ext_out <= 0;

        rs_out <= 0;
        rt_out <= 0;
        rd_out <= 0;
    end

    else
    begin
        reg_write_out <= reg_write_in;
        mem_to_reg_out <= mem_to_reg_in;
        mem_read_out <= mem_read_in;
        mem_write_out <= mem_write_in;
        reg_dst_out <= reg_dst_in;
        alu_src_out <= alu_src_in;
        alu_op_out <= alu_op_in;

        pc_plus_4_out <= pc_plus_4_in;
        rdata1_out <= rdata1_in;
        rdata2_out <= rdata2_in;
        sign_ext_out <= sign_ext_in;

        rs_out <= rs_in;
        rt_out <= rt_in;
        rd_out <= rd_in;
    end

end

endmodule