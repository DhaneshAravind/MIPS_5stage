`timescale 1ns / 1ps

module id_forwarding_unit(

    input [4:0] rs,
    input [4:0] rt,

    input [4:0] ex_mem_rd,
    input [4:0] mem_wb_rd,

    input ex_mem_reg_write,
    input mem_wb_reg_write,

    output reg [1:0] forward_a_id,
    output reg [1:0] forward_b_id
);

always @(*) begin

    forward_a_id = 2'b00;
    forward_b_id = 2'b00;

    if(ex_mem_reg_write &&
       ex_mem_rd != 0 &&
       ex_mem_rd == rs)
        forward_a_id = 2'b10;

    else if(mem_wb_reg_write &&
            mem_wb_rd != 0 &&
            mem_wb_rd == rs)
        forward_a_id = 2'b01;

    if(ex_mem_reg_write &&
       ex_mem_rd != 0 &&
       ex_mem_rd == rt)
        forward_b_id = 2'b10;

    else if(mem_wb_reg_write &&
            mem_wb_rd != 0 &&
            mem_wb_rd == rt)
        forward_b_id = 2'b01;

end

endmodule