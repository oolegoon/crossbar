// Quartus II Verilog Template

// Single port RAM with single read/write address module single_port_ram
`timescale 1ns / 10 ps

module single_port_ram
#(parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 32)
	(
	input [(DATA_WIDTH-1):0] data,
	input [(ADDR_WIDTH-1):0] addr,
	input we, clock,
	output [(DATA_WIDTH-1):0] q,
	output reg [(ADDR_WIDTH-1):0] addr_reg
);
// Declare the RAM variable

	reg [DATA_WIDTH-1:0] ram [ADDR_WIDTH-1:0];

	// Variable to hold the registered read address 
	//reg [ADDR_WIDTH-1:0] addr_reg;
	always @ (posedge clock) 
	begin
		// Write 
		if (we)
			ram[addr] <= data;
			addr_reg <= addr;
	end
	// Continuous assignment implies read returns NEW data. This is the natural behavior of the TriMatrix memory 
	// blocks in Single Port mode
	//assign q = ram[addr];
	assign q = ram[addr_reg];
endmodule