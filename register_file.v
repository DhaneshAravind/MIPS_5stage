module register_file(
    input clk, reset, reg_write,
    input [4:0] read_reg1, read_reg2, write_reg,
    input [31:0] write_data,
    output [31:0] read_data1, read_data2
);

reg [31:0] registers [31:0];
integer i;

assign read_data1 = (read_reg1 == 0) ? 32'b0 : registers[read_reg1];
assign read_data2 = (read_reg2 == 0) ? 32'b0 : registers[read_reg2];

always @(negedge clk or posedge reset) begin
    if (reset) begin
        for(i=0;i<32;i=i+1)
            registers[i] <= 32'b0;
    end
    else if(reg_write && write_reg!=0)
        registers[write_reg] <= write_data;
end

endmodule