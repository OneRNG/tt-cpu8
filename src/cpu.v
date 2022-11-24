`default_nettype none

module moonbase_cpu_4bit #( parameter MAX_COUNT = 1000 ) (
  input [7:0] io_in,
  output [7:0] io_out
);
    
    wire clk = io_in[0];
    wire reset = io_in[1];
    wire [3:0]ram_in = io_in[5:2];
    wire [1:0]data_in = io_in[7:6];
    
    wire [6:0] addr_out;
    reg       strobe_out;	// address strobe		- designed to be wired to a 7 bit latch and a MWS5101AEL3
    reg       write_data_n;	// write enable for data
    reg       write_ram_n;	// write enable for ram
    reg	      addr_pc;
    assign addr_out = addr_pc ? r_pc : ((r_tmp[3]?r_y:r_x)+{4'b000, r_tmp[2:0]});
    assign io_out = {strobe_out, strobe_out? addr_out : {1'bx, write_ram_n, write_data_n, r_a}};

    reg [6:0]r_pc, c_pc;
    reg [6:0]r_x, c_x;
    reg [6:0]r_y, c_y;
    reg [3:0]r_a, c_a;	
    reg [2:0]r_tmp2, c_tmp2;	
    reg [3:0]r_tmp, c_tmp;	

    //
    //	phase:
    //		0 - instruction fetch addr
    //		1 - instruction fetch data
    //		2 - data fetch addr 
    //		3 - data fetch data 
    //		4 - data fetch addr 
    //		5 - data fetch data 
    //		6 - execute/data store addr
    //		7 - data store data (might not do this)
    //
    reg    [2:0]r_phase, c_phase;
	

    // instructions
    //
    //  0:	add a, v(x/y)
    //  1: 	sub a, v(x/y)
    //  2:	or a, v(x/y)
    //  3:	and a, v(x/y)
    //  4:	xor a, v(x/y)
    //  5:	mov a, v(x/y)
    //  6:	movd a, v(x/y)
    //  7: 0	mov y, x
    //	   1    mov x, y
    //	   2    add y, #1
    //	   3    add x, #1
    //	   4    add y, a
    //	   5    add x, a
    //	   6    mov x[3:0], a
    //	   7    mov a, x[3:0]
    //	8:	mov a, #v
    //  9:	add a, #v 
    //  a:	movd v(x/y), a
    //  b:	mov  v(x/y), a
    //  c:	mov x, #vv
    //  d:	jne a, vv
    //  e:	jeq a, vv
    //  f:	jmp vv
    //
    //  Memory access - addresses are 7 bits - v(x/y) is a 3-bit offset v[2:0]
    //  	if  v[3] it's y+v[2:0]
    //  	if !v[3] it's x+v[2:0]
    //
    //	The general idea is that y normally points to a bank of in sram 8 'registers' while
    //		x is a more general index register (but you can use both if you need to do
    //		some copying)
    //		


    reg [3:0]r_ins, c_ins;
	
    always @(*) begin
	c_ins = r_ins;
	c_x = r_x;
	c_y = r_y;
	c_a = r_a;
	c_tmp = r_tmp;
	c_tmp2 = r_tmp2;
	c_pc = r_pc;
	write_data_n = 1;
	write_ram_n = 1;
	addr_pc = 'bx;
    	if (reset) begin
		c_pc <= 0;
		c_ins <= 'bx;
		c_x <= 'bx;
		c_a <= 'bx;
		c_phase <= 0;
		strobe_out = 1;
    	end else 
    	case (r_phase) // synthesis full_case parallel_case
    	0:	begin
	  		strobe_out = 1;
			addr_pc = 1;
			c_phase = 1;
		end
    	1:	begin
	  		strobe_out = 0;
			c_ins = ram_in;
			c_pc = r_pc+1;
			c_phase = 2;
		end
	2:	begin
			strobe_out = 1;
	  		addr_pc = 1;
			c_phase = 3;
		end
	3:	begin
	  		strobe_out = 0;
			c_tmp = ram_in;
			c_pc = r_pc+1;
			case (r_ins) // synthesis full_case parallel_case
			7, 8, 9, 10, 11: c_phase = 6;
			default:c_phase = 4;
			endcase
		end
	4:	begin
			strobe_out = 1;
	  		addr_pc = r_ins[3:2] == 3;
			c_phase = 5;
		end
	5:	begin
	  		strobe_out = 0;
			c_tmp2 = r_tmp[2:0];
			c_tmp = (r_ins[3:1] == 3?{2'b0,data_in}:ram_in);
			if (r_ins[3:2] == 3)
				c_pc = r_pc+1;
			c_phase = 6;
		end
	6:	begin
	  		strobe_out = r_ins[3:1] == 5;	// write to anything
	  		addr_pc = 0;
			c_phase = 0;
			case (r_ins)// synthesis full_case parallel_case
			0, 9:	c_a = r_a+r_tmp;
			1:	c_a = r_a-r_tmp;
			2:	c_a = r_a|r_tmp;
			3:	c_a = r_a&r_tmp;
			4:	c_a = r_a^r_tmp;
			5, 6, 8:c_a = r_tmp;
			7:	case (r_tmp) // synthesis full_case parallel_case
				0: c_y = r_x;			// 0	mov y, x
    				1: c_x = r_y;			// 1    mov x, y
    				2: c_y = r_y+1;			// 2    add y, #1
    				3: c_x = r_x+1;			// 3    add x, #1
    				4: c_y = r_y+{3'b0, r_a};	// 4    add y, a
    				5: c_x = r_x+{3'b0, r_a};	// 5    add x, a
    				6: c_x[3:0] = r_a;		// 6    mov x[3:0], a
    				7: c_a = r_x[3:0];		// 7    mov a, x[3:0]
				endcase
			10, 11: c_phase = 7;
			12:	c_x = {r_tmp2, r_tmp};
			13:	c_pc = (r_a != 0) ? {r_tmp2, r_tmp} : r_pc; 
			14:	c_pc = (r_a == 0) ? {r_tmp2, r_tmp} : r_pc; 
			15:	c_pc = {r_tmp2, r_tmp}; 
			endcase
		end
	7:	begin
	  		strobe_out = 0;
			write_data_n = r_ins[0];
			write_ram_n = ~r_ins[0];
			c_phase = 0;
		end
    	endcase
    end

    always @(posedge clk) begin
	r_a <= c_a;
	r_x <= c_x;
	r_y <= c_y;
	r_ins <= c_ins;
	r_tmp <= c_tmp;
	r_tmp2 <= c_tmp2;
	r_pc <= c_pc;
	r_phase = c_phase;
    end

endmodule
