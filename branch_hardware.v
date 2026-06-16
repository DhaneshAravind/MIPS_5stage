`timescale 1ns / 1ps

module branch_hardware(

    input [31:0] pc_plus_4,
    input [31:0] sign_ext_imm,

    input [31:0] cmp_in_a,
    input [31:0] cmp_in_b,

    input branch_control,

    output [31:0] branch_target,
    output pc_src,
    output if_flush
);

assign branch_target =
       pc_plus_4 + (sign_ext_imm << 2);

assign pc_src =
       branch_control &&
       (cmp_in_a == cmp_in_b);

assign if_flush = pc_src;

endmodule