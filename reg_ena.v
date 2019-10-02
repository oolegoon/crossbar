////////////////////////////////////////////////////////////////////////
//   Name File     : reg_ena.v
//   Autor         : Oleg Krivoruka
//   Company       : 
//
//   Description   : Test  
//   Start design  : 26.08.2019
//   Last revision :  
///////////////////////////////////////////////////////////////////////

`timescale 1ns / 10 ps

//==================================================
// Verilog код, описывающий регистр, со входом разрешения загрузки данных  и асинхронным сбросом.

module reg_ena (clock, reset, ena, data, out);

parameter WIDTH = 32;

input  clock, reset, ena;
input  [WIDTH-1:0] data;

output [WIDTH-1:0] out;
reg    [WIDTH-1:0] out;


always @(posedge clock or posedge reset)
    if(reset)
     out = {WIDTH{1'b0}} ;  // записано столько 0, сколько разрядности в WIDTH 
    else if(ena)
     out = data;

endmodule
//==================================================