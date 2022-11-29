`default_nettype none
`timescale 1ns/1ps

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

module tb (
    // testbench is controlled by test.py
    input clk,
    input rst,
    output data_write,
    output data_choose,
    output [3:0] data_out
   );

    

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
`include "testcode.v"

`ifdef LOCAL_TEST
        $dumpfile ("tb.vcd");
        $dumpvars (0, tb);
`endif
        #1;
    end

    // wire up the inputs and outputs
    reg  [1:0]data_in;
    wire [7:0]sram_out;
    wire [7:0] inputs = {data_in, !outputs[6]?sram_out[7:4]:sram_out[3:0], rst, clk};
    wire [7:0] outputs;
    assign data_out = outputs[3:0];
    assign data_write = outputs[7] ? 1 : outputs[4]; // negative data strobe

    // instantiate the DUT
    moonbase_cpu_8bit #(.MAX_COUNT(100)) cpu(
`ifdef GL_TEST
        .vccd1( 1'b1),
        .vssd1( 1'b0),
`endif

        .io_in  (inputs),
        .io_out (outputs)
        );

    reg [11:0]latch;
    always @(*)
    if (outputs[7] && !clk)
    if (outputs[6]) begin
	latch[11:6] = outputs[5:0];
    end else begin
	latch[5:0] = outputs[5:0];
    end

    assign data_choose = outputs[6];

    reg [7:0]sram[0:4095];
    reg [3:0]tmp;
    assign sram_out = sram[latch];
    always @(posedge clk) 
    if (!outputs[5] && !outputs[7]) begin
	if (!outputs[6]) begin
		tmp <= outputs[3:0];
	end else begin
		sram[latch] <= {outputs[3:0], tmp};
	end
    end


endmodule
