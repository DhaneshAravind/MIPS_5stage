`timescale 1ns / 1ps

module forwarding_unit(

    input [4:0] id_ex_rs,
    input [4:0] id_ex_rt,

    input [4:0] ex_mem_rd,
    input [4:0] mem_wb_rd,

    input ex_mem_reg_write,
    input mem_wb_reg_write,

    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);

always @(*) begin

    forward_a = 2'b00;
    forward_b = 2'b00;

    if(ex_mem_reg_write &&
       ex_mem_rd != 0 &&
       ex_mem_rd == id_ex_rs)
        forward_a = 2'b10;

    if(ex_mem_reg_write &&
       ex_mem_rd != 0 &&
       ex_mem_rd == id_ex_rt)
        forward_b = 2'b10;

    if(mem_wb_reg_write &&
       mem_wb_rd != 0 &&
       !(ex_mem_reg_write &&
         ex_mem_rd != 0 &&
         ex_mem_rd == id_ex_rs) &&
       mem_wb_rd == id_ex_rs)
        forward_a = 2'b01;

    if(mem_wb_reg_write &&
       mem_wb_rd != 0 &&
       !(ex_mem_reg_write &&
         ex_mem_rd != 0 &&
         ex_mem_rd == id_ex_rt) &&
       mem_wb_rd == id_ex_rt)
        forward_b = 2'b01;

end

endmodule