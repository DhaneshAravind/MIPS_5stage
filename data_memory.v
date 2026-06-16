`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module data_memory(
    input clk,
    input mem_read,
    input mem_write,
    input [31:0] address,
    input [31:0] write_data,
    output [31:0] read_data
);

reg [31:0] ram [0:255];

assign read_data = mem_read ? ram[address[9:2]] : 32'b0;

always @(posedge clk)
begin
    if(mem_write)
        ram[address[9:2]] <= write_data;
end

endmodule
