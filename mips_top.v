`timescale 1ns/1ps


module mips_top(
    input clk,
    input reset
);

    // =======================================================
    // INTERNAL WIRES AND REGS
    // =======================================================
    wire [31:0] pc_current, pc_plus_4_if, pc_next, instruction_if;
    wire [31:0] pc_plus_4_id, instruction_id, sign_ext_id, read_data1_id, read_data2_id, branch_target_id;
    reg  [31:0] cmp_in_a, cmp_in_b; // Changed to reg for always block
    wire [5:0] opcode_id, funct_id;
    wire [4:0] rs_id, rt_id, rd_id;
    wire pc_write, if_id_write, control_mux_sel, pc_src_id, if_flush_id;
    wire branch_id, mem_read_id_raw, mem_write_id_raw, reg_dst_id_raw, alu_src_id_raw, mem_to_reg_id_raw, reg_write_id_raw;
    wire [1:0] alu_op_id_raw, forward_a_id, forward_b_id;
    wire branch_id_muxed, mem_read_id_muxed, mem_write_id_muxed, reg_dst_id_muxed, alu_src_id_muxed, mem_to_reg_id_muxed, reg_write_id_muxed;
    wire [1:0] alu_op_id_muxed;
    
    wire [31:0] pc_plus_4_ex, read_data1_ex, read_data2_ex, sign_ext_ex;
    wire [4:0] rs_ex, rt_ex, rd_ex, write_reg_ex;
    wire reg_write_ex, mem_to_reg_ex, mem_read_ex, mem_write_ex, reg_dst_ex, alu_src_ex;
    wire [1:0] alu_op_ex, forward_a, forward_b;
    wire [3:0] alu_control_ex;
    reg  [31:0] alu_in_a, alu_in_b_forwarded; // Changed to reg for always block
    wire [31:0] alu_in_b_final, alu_result_ex;
    
    wire reg_write_mem, mem_to_reg_mem, mem_read_mem, mem_write_mem;
    wire [31:0] alu_result_mem, write_data_mem, read_data_mem;
    wire [4:0] write_reg_mem;
    
    wire reg_write_wb, mem_to_reg_wb;
    wire [31:0] read_data_wb, alu_result_wb, write_data_wb;
    wire [4:0] write_reg_wb;

    // =======================================================
    // STAGE 1: INSTRUCTION FETCH (IF)
    // =======================================================
    assign pc_plus_4_if = pc_current + 32'd4;
    assign pc_next = (pc_src_id) ? branch_target_id : pc_plus_4_if;

    reg [31:0] pc_reg;
    assign pc_current = pc_reg;
    always @(posedge clk or posedge reset) begin
        if (reset) pc_reg <= 32'b0;
        else if (pc_write) pc_reg <= pc_next;
    end

    instruction_memory imem (.pc(pc_current), .instruction(instruction_if));

    if_id_reg IF_ID (
        .clk(clk), .reset(reset), .write_en(if_id_write), .flush(if_flush_id),
        .pc_plus_4_in(pc_plus_4_if), .inst_in(instruction_if),
        .pc_plus_4_out(pc_plus_4_id), .inst_out(instruction_id)
    );

    // =======================================================
    // STAGE 2: INSTRUCTION DECODE (ID)
    // =======================================================
    assign opcode_id = instruction_id[31:26];
    assign rs_id     = instruction_id[25:21];
    assign rt_id     = instruction_id[20:16];
    assign rd_id     = instruction_id[15:11];
    assign sign_ext_id = {{16{instruction_id[15]}}, instruction_id[15:0]};

    hazard_detection_unit hazard_unit (
        .branch(branch_id), .if_id_rs(rs_id), .if_id_rt(rt_id),
        .id_ex_mem_read(mem_read_ex), .id_ex_reg_write(reg_write_ex), .id_ex_rt(rt_ex), .id_ex_write_reg(write_reg_ex),
        .ex_mem_mem_read(mem_read_mem), .ex_mem_write_reg(write_reg_mem),
        .pc_write(pc_write), .if_id_write(if_id_write), .control_mux_sel(control_mux_sel)
    );

    main_control control_unit (
        .opcode(opcode_id), .reg_dst(reg_dst_id_raw), .alu_src(alu_src_id_raw), .mem_to_reg(mem_to_reg_id_raw),
        .reg_write(reg_write_id_raw), .mem_read(mem_read_id_raw), .mem_write(mem_write_id_raw),
        .branch(branch_id), .alu_op(alu_op_id_raw)
    );

    assign reg_write_id_muxed  = control_mux_sel ? reg_write_id_raw  : 1'b0;
    assign mem_to_reg_id_muxed = control_mux_sel ? mem_to_reg_id_raw : 1'b0;
    assign mem_read_id_muxed   = control_mux_sel ? mem_read_id_raw   : 1'b0;
    assign mem_write_id_muxed  = control_mux_sel ? mem_write_id_raw  : 1'b0;
    assign reg_dst_id_muxed    = control_mux_sel ? reg_dst_id_raw    : 1'b0;
    assign alu_src_id_muxed    = control_mux_sel ? alu_src_id_raw    : 1'b0;
    assign alu_op_id_muxed     = control_mux_sel ? alu_op_id_raw     : 2'b00;

    register_file reg_file (
        .clk(clk), .reset(reset), .reg_write(reg_write_wb),
        .read_reg1(rs_id), .read_reg2(rt_id), .write_reg(write_reg_wb), .write_data(write_data_wb),
        .read_data1(read_data1_id), .read_data2(read_data2_id)
    );

    id_forwarding_unit id_fwd (
        .rs(rs_id), .rt(rt_id), .ex_mem_rd(write_reg_mem), .mem_wb_rd(write_reg_wb),
        .ex_mem_reg_write(reg_write_mem), .mem_wb_reg_write(reg_write_wb),
        .forward_a_id(forward_a_id), .forward_b_id(forward_b_id)
    );

    // Cleaned up ID Stage Forwarding Muxes
    always @(*) begin
        case(forward_a_id)
            2'b10:   cmp_in_a = alu_result_mem;
            2'b01:   cmp_in_a = write_data_wb;
            default: cmp_in_a = read_data1_id;
        endcase

        case(forward_b_id)
            2'b10:   cmp_in_b = alu_result_mem;
            2'b01:   cmp_in_b = write_data_wb;
            default: cmp_in_b = read_data2_id;
        endcase
    end

    branch_hardware branch_hw (
        .pc_plus_4(pc_plus_4_id), .sign_ext_imm(sign_ext_id),
        .cmp_in_a(cmp_in_a), .cmp_in_b(cmp_in_b), .branch_control(branch_id),
        .branch_target(branch_target_id), .pc_src(pc_src_id), .if_flush(if_flush_id)
    );

    id_ex_reg ID_EX (
        .clk(clk), .reset(reset),
        .reg_write_in(reg_write_id_muxed), .mem_to_reg_in(mem_to_reg_id_muxed), .mem_read_in(mem_read_id_muxed),
        .mem_write_in(mem_write_id_muxed), .reg_dst_in(reg_dst_id_muxed), .alu_src_in(alu_src_id_muxed), .alu_op_in(alu_op_id_muxed),
        .pc_plus_4_in(pc_plus_4_id), .rdata1_in(read_data1_id), .rdata2_in(read_data2_id), .sign_ext_in(sign_ext_id),
        .rs_in(rs_id), .rt_in(rt_id), .rd_in(rd_id),
        .reg_write_out(reg_write_ex), .mem_to_reg_out(mem_to_reg_ex), .mem_read_out(mem_read_ex),
        .mem_write_out(mem_write_ex), .reg_dst_out(reg_dst_ex), .alu_src_out(alu_src_ex), .alu_op_out(alu_op_ex),
        .pc_plus_4_out(pc_plus_4_ex), .rdata1_out(read_data1_ex), .rdata2_out(read_data2_ex), .sign_ext_out(sign_ext_ex),
        .rs_out(rs_ex), .rt_out(rt_ex), .rd_out(rd_ex)
    );

    // =======================================================
    // STAGE 3: EXECUTE (EX)
    // =======================================================
    assign write_reg_ex = (reg_dst_ex) ? rd_ex : rt_ex;

    forwarding_unit fwd_unit (
        .id_ex_rs(rs_ex), .id_ex_rt(rt_ex), .ex_mem_rd(write_reg_mem), .mem_wb_rd(write_reg_wb),
        .ex_mem_reg_write(reg_write_mem), .mem_wb_reg_write(reg_write_wb),
        .forward_a(forward_a), .forward_b(forward_b)
    );

    // Cleaned up EX Stage Forwarding Muxes
    always @(*) begin
        case(forward_a)
            2'b10:   alu_in_a = alu_result_mem;
            2'b01:   alu_in_a = write_data_wb;
            default: alu_in_a = read_data1_ex;
        endcase

        case(forward_b)
            2'b10:   alu_in_b_forwarded = alu_result_mem;
            2'b01:   alu_in_b_forwarded = write_data_wb;
            default: alu_in_b_forwarded = read_data2_ex;
        endcase
    end

    // ALU Src Mux (2-to-1)
    assign alu_in_b_final = (alu_src_ex) ? sign_ext_ex : alu_in_b_forwarded;

    alu_control alu_ctrl_unit (.alu_op(alu_op_ex), .funct(sign_ext_ex[5:0]), .alu_ctrl(alu_control_ex));
    alu main_alu (.a(alu_in_a), .b(alu_in_b_final), .alu_control(alu_control_ex), .result(alu_result_ex));

    ex_mem_reg EX_MEM (
        .clk(clk), .reset(reset),
        .reg_write_in(reg_write_ex), .mem_to_reg_in(mem_to_reg_ex), .mem_read_in(mem_read_ex), .mem_write_in(mem_write_ex),
        .alu_result_in(alu_result_ex), .write_data_in(alu_in_b_forwarded), .dest_reg_in(write_reg_ex),
        .reg_write_out(reg_write_mem), .mem_to_reg_out(mem_to_reg_mem), .mem_read_out(mem_read_mem), .mem_write_out(mem_write_mem),
        .alu_result_out(alu_result_mem), .write_data_out(write_data_mem), .dest_reg_out(write_reg_mem)
    );

    // =======================================================
    // STAGE 4: MEMORY (MEM)
    // =======================================================
    data_memory dmem (
        .clk(clk), .mem_read(mem_read_mem), .mem_write(mem_write_mem),
        .address(alu_result_mem), .write_data(write_data_mem), .read_data(read_data_mem)
    );

    mem_wb_reg MEM_WB (
        .clk(clk), .reset(reset),
        .reg_write_in(reg_write_mem), .mem_to_reg_in(mem_to_reg_mem),
        .read_data_in(read_data_mem), .alu_result_in(alu_result_mem), .dest_reg_in(write_reg_mem),
        .reg_write_out(reg_write_wb), .mem_to_reg_out(mem_to_reg_wb),
        .read_data_out(read_data_wb), .alu_result_out(alu_result_wb), .dest_reg_out(write_reg_wb)
    );

    // =======================================================
    // STAGE 5: WRITEBACK (WB)
    // =======================================================
    assign write_data_wb = (mem_to_reg_wb) ? read_data_wb : alu_result_wb;

endmodule