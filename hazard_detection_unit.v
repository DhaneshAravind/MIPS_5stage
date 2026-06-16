`timescale 1ns / 1ps

module hazard_detection_unit(
    input branch,
    input [4:0] if_id_rs,
    input [4:0] if_id_rt,

    input id_ex_mem_read,
    input id_ex_reg_write,
    input [4:0] id_ex_rt,
    input [4:0] id_ex_write_reg,

    input ex_mem_mem_read,
    input [4:0] ex_mem_write_reg,

    output reg pc_write,
    output reg if_id_write,
    output reg control_mux_sel
);

always @(*) begin

    if(id_ex_mem_read &&
      ((id_ex_rt == if_id_rs) ||
       (id_ex_rt == if_id_rt)))
    begin
        pc_write = 0;
        if_id_write = 0;
        control_mux_sel = 0;
    end

    else if(branch &&
            id_ex_reg_write &&
            id_ex_write_reg != 0 &&
            ((id_ex_write_reg == if_id_rs) ||
             (id_ex_write_reg == if_id_rt)))
    begin
        pc_write = 0;
        if_id_write = 0;
        control_mux_sel = 0;
    end

    else if(branch &&
            ex_mem_mem_read &&
            ex_mem_write_reg != 0 &&
            ((ex_mem_write_reg == if_id_rs) ||
             (ex_mem_write_reg == if_id_rt)))
    begin
        pc_write = 0;
        if_id_write = 0;
        control_mux_sel = 0;
    end

    else begin
        pc_write = 1;
        if_id_write = 1;
        control_mux_sel = 1;
    end

end

endmodule