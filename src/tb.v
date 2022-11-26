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
    output [3:0] data_out
   );

    

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
	sram[8'h00] = 'h8;	// mov a, #0
	sram[8'h01] = 'h0;
	sram[8'h02] = 'hc;	// mov x, #0x50
	sram[8'h03] = 'hf;
	sram[8'h04] = 'h0;
	sram[8'h05] = 'ha;	// movd	7(x), a    a->f7
	sram[8'h06] = 'h7;	
	sram[8'h07] = 'hb;	// mov 0(x), a
	sram[8'h08] = 'h0;	
	sram[8'h09] = 'h8;	// mov	a, #1
	sram[8'h0a] = 'h1;	
	sram[8'h0b] = 'h0;	// add	a, 0(x)
	sram[8'h0c] = 'h0;	
	sram[8'h0d] = 'hd;	// jne a, 0x05
	sram[8'h0e] = 'h0;
	sram[8'h0f] = 'h5;

	sram[8'h10] = 'h8;	// mov a, #a
	sram[8'h11] = 'ha;
	sram[8'h12] = 'hb;	// mov	0(x), a    
	sram[8'h13] = 'h0;	

	sram[8'h14] = 'h8;	// mov a, #c
	sram[8'h15] = 'hc;
	sram[8'h16] = 'h1;	// sub	a, 0(x)
	sram[8'h17] = 'h0;	
	sram[8'h18] = 'ha;	// movd	7(x), a    a->f7
	sram[8'h19] = 'h7;	
	
	sram[8'h1a] = 'h8;	// mov a, #c
	sram[8'h1b] = 'hc;
	sram[8'h1c] = 'h2;	// or	a, 0(x)
	sram[8'h1d] = 'h0;	
	sram[8'h1e] = 'ha;	// movd	7(x), a    a->f7
	sram[8'h1f] = 'h7;	
	
	sram[8'h20] = 'h8;	// mov a, #c
	sram[8'h21] = 'hc;
	sram[8'h22] = 'h3;	// and	a, 0(x)
	sram[8'h23] = 'h0;	
	sram[8'h24] = 'ha;	// movd	7(x), a    a->f7
	sram[8'h25] = 'h7;	
	
	sram[8'h26] = 'h8;	// mov a, #c
	sram[8'h27] = 'hc;
	sram[8'h28] = 'h4;	// xor	a, 0(x)
	sram[8'h29] = 'h0;	
	sram[8'h2a] = 'ha;	// movd	7(x), a    a->f7
	sram[8'h2b] = 'h7;	
	
	sram[8'h2c] = 'h5;	// mov	a, 0(x)
	sram[8'h2d] = 'h0;	
	sram[8'h2e] = 'ha;	// movd	7(x), a    a->f7
	sram[8'h2f] = 'h7;	

	sram[8'h30] = 'h9;	// add	a, #5
	sram[8'h31] = 'h5;	
	sram[8'h32] = 'ha;	// movd	7(x), a    f->f7
	sram[8'h33] = 'h7;	
	
	sram[8'h34] = 'hc;	// mov	x, #20
	sram[8'h35] = 'h2;
	sram[8'h36] = 'h0;
	sram[8'h37] = 'h7;	// mov	y, x
	sram[8'h38] = 'h0;
	sram[8'h39] = 'h5;	// mov	a, 0(y)
	sram[8'h3a] = 'h8;	
	sram[8'h3b] = 'ha;	// movd	7(x), a    8->f7
	sram[8'h3c] = 'h7;	
	sram[8'h3d] = 'h5;	// mov	a, 1(y)
	sram[8'h3e] = 'h9;	
	sram[8'h3f] = 'ha;	// movd	7(x), a    c->f7
	sram[8'h40] = 'h7;	

	sram[8'h41] = 'hf;	// call XX
	sram[8'h42] = 'hc;
	sram[8'h43] = 'h9;
	sram[8'h44] = 'ha;	// movd	7(x), a    f->f7
	sram[8'h45] = 'h7;	

	sram[8'h46] = 'hf;	// jmp NN
	sram[8'h47] = 'h5;
	sram[8'h48] = 'ha;
	
	sram[8'h49] = 'h9;	//XX: add	a, #1
	sram[8'h4a] = 'h1;	
	sram[8'h4b] = 'ha;	//    movd	7(x), a    d->f7
	sram[8'h4c] = 'h7;	
	sram[8'h4d] = 'hf;	//    call YY
	sram[8'h4e] = 'hd;
	sram[8'h4f] = 'h4;
	sram[8'h50] = 'h9;	//    add	a, #1
	sram[8'h51] = 'h1;	
	sram[8'h52] = 'h7;	//    ret
	sram[8'h53] = 'h3;	

	sram[8'h54] = 'h9;	//YY:    add	a, #1
	sram[8'h55] = 'h1;	
	sram[8'h56] = 'ha;	//       movd	7(x), a    e->f7
	sram[8'h57] = 'h7;	
	sram[8'h58] = 'h7;	//       ret
	sram[8'h59] = 'h3;	

				//NN:
	
	sram[8'h5a] = 'hf;	// jmp 0x41
	sram[8'h5b] = 'h5;
	sram[8'h5c] = 'ha;

`ifdef LOCAL_TEST
        $dumpfile ("tb.vcd");
        $dumpvars (0, tb);
`endif
        #1;
    end

    // wire up the inputs and outputs
    reg  [1:0]data_in;
    wire [3:0]sram_out;
    wire [7:0] inputs = {data_in, sram_out, rst, clk};
    wire [7:0] outputs;
    assign data_out = outputs[3:0];
    assign data_write = outputs[7] ? 1 : outputs[4]; // negative data strobe

    // instantiate the DUT
    moonbase_cpu_4bit #(.MAX_COUNT(100)) cpu(
`ifdef GL_TEST
        .vccd1( 1'b1),
        .vssd1( 1'b0),
`endif

        .io_in  (inputs),
        .io_out (outputs)
        );

    reg [6:0]latch;
    always @(*)
    if (outputs[7])
	latch = outputs[6:0];

    reg [3:0]sram[0:127];
    assign sram_out = sram[latch];
    always @(outputs) #0.01
    if (!outputs[5] && !outputs[7])
	sram[latch] = outputs[3:0];



endmodule
