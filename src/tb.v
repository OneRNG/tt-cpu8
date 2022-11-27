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
	sram[8'h00] = 'hf0;	// mov a, #15
	sram[8'h01] = 'h0f;	
	sram[8'h02] = 'hf3;	// mov x, #0x80
	sram[8'h03] = 'h80;
	sram[8'h04] = 'ha7;	// gg:	movd	7(x), a    0->f7
	sram[8'h05] = 'hb0;	//	mov 0(x), a
	sram[8'h06] = 'hf0;	//	mov	a, #-1
	sram[8'h07] = 'hff;	
	sram[8'h08] = 'h00;	//	add	a, 0(x)
	sram[8'h09] = 'hf4;	//	jne a, gg
	sram[8'h0a] = 'h04;	

	sram[8'h0b] = 'hf0;	// mov a, #aa
	sram[8'h0c] = 'haa;
	sram[8'h0d] = 'hb0;	// mov	0(x), a    

	sram[8'h0e] = 'hf0;	// mov a, #cc
	sram[8'h0f] = 'hcc;
	sram[8'h10] = 'h10;	// sub	a, 0(x)
	sram[8'h11] = 'ha7;	// movd	7(x), a    22->f7
	
	sram[8'h12] = 'hf0;	// mov a, #cc
	sram[8'h13] = 'hcc;
	sram[8'h14] = 'h20;	// or	a, 0(x)
	sram[8'h15] = 'ha7;	// movd	7(x), a    ee->f7
	
	sram[8'h16] = 'hf0;	// mov a, #c
	sram[8'h17] = 'hcc;
	sram[8'h18] = 'h30;	// and	a, 0(x)
	sram[8'h19] = 'ha7;	// movd	7(x), a    88->f7
	
	sram[8'h1a] = 'hf0;	// mov a, #cc
	sram[8'h1b] = 'hcc;
	sram[8'h1c] = 'h40;	// xor	a, 0(x)
	sram[8'h1d] = 'ha7;	// movd	7(x), a    66->f7
	
	sram[8'h1e] = 'h50;	// mov	a, 0(x)
	sram[8'h1f] = 'ha7;	// movd	7(x), a    aa->f7

	sram[8'h20] = 'hf1;	// add	a, #5
	sram[8'h21] = 'h05;	
	sram[8'h22] = 'ha7;	// movd	7(x), a    f->f7
	
	sram[8'h23] = 'h70;	// swap	y, x	   y-f7
	sram[8'h24] = 'hf3;	// mov	x, #20
	sram[8'h25] = 'h20;
	sram[8'h26] = 'h70;	// swap	y, x
	sram[8'h27] = 'h58;	// mov	a, 0(y)
	sram[8'h28] = 'ha7;	// movd	7(x), a    f1->f7
	sram[8'h29] = 'h59;	// mov	a, 1(y)
	sram[8'h2a] = 'ha7;	// movd	7(x), a    05->f7

	sram[8'h2b] = 'hf6;	// call XX
	sram[8'h2c] = 'hb0;
	sram[8'h2d] = 'ha7;	// movd	7(x), a    f->f7

	sram[8'h2e] = 'hf5;	// jmp NN
	sram[8'h2f] = 'h3c;
	
	sram[8'h30] = 'hf1;	//XX: add	a, #1
	sram[8'h31] = 'h01;	
	sram[8'h32] = 'ha7;	//    movd	7(x), a    d->f7
	sram[8'h33] = 'hf6;	//    call YY
	sram[8'h34] = 'hb8;
	sram[8'h35] = 'hf1;	//    add	a, #1
	sram[8'h36] = 'h01;	
	sram[8'h37] = 'h73;	//    ret

	sram[8'h38] = 'hf1;	//YY:    add	a, #1
	sram[8'h39] = 'h01;	
	sram[8'h3a] = 'ha7;	//       movd	7(x), a    e->f7
	sram[8'h3b] = 'h73;	//       ret

				//NN:
	
	sram[8'h3c] = 'hf5;	// jmp 0x41
	sram[8'h3d] = 'h3c;

`ifdef LOCAL_TEST
        $dumpfile ("tb.vcd");
        $dumpvars (0, tb);
`endif
        #1;
    end

    // wire up the inputs and outputs
    reg  [1:0]data_in;
    wire [7:0]sram_out;
    wire [7:0] inputs = {data_in, !choose?sram_out[7:4]:sram_out[3:0], rst, clk};
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

    reg [6:0]latch;
    always @(*)
    if (outputs[7])
	latch = outputs[6:0];

    reg choose;
    assign data_choose = choose;
    always @(posedge clk)
    if (outputs[7]) begin
	choose <= 0;
    end else begin
	choose <= ~choose;
    end

    reg [7:0]sram[0:127];
    reg [3:0]tmp;
    assign sram_out = sram[latch];
    always @(posedge clk) 
    if (!outputs[5] && !outputs[7]) begin
	if (choose) begin
		tmp <= outputs[3:0];
	end else begin
		sram[latch] <= {outputs[3:0], tmp};
	end
    end


endmodule
