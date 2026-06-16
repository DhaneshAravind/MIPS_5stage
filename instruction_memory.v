`timescale 1ns / 1ps
module instruction_memory(
    input [31:0] pc,
    output [31:0] instruction
);

reg [31:0] rom [0:255];

initial
    $readmemh("machine_code.mem",rom);

assign instruction = rom[pc[9:2]];

endmodule
