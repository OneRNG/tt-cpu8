![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg)

# tiny 8-bit CPU

From Paul Campbell - Moonbase Otago - visit [VROOM!](https://moonbaseotago.github.io/) for something slightly bigger

This is a 8-bit CPU in verilog designed for tiny-tapeout.

It has a 8-bit accumulator, a 7-bit PC, 2 8-bit index registers and a carry bit.

The main limitations are the 6/8-bit bus - it's designed to run with an external SRAM and a 7-bit address latch, code is loaded externally. Accesses are 3 beats:

- strobe loads the address latch
- next clock loads/stores the high nibble
- next clock loads/stores the low nibble

There are 33 instructions. each 1 or 2 bytes:

    0v:		add a, v(x/y)	- sets C
    1v: 	sub a, v(x/y)	- sets C
    2v:		or a, v(x/y)
    3v:		and a, v(x/y)
    4v:		xor a, v(x/y)
    5v:		mov a, v(x/y)
    6v:		movd a, v(x/y)
    77:		swap x, y
    71:		add a, c
    72:		mov x.l, a
    73:		ret
    74:		add y, a
    75:		add x, a
    76:		add y, #1
    77:		add x, #1
    78:		mov a, y
    79:		mov a, x
    7a:		mov b, a
    7b:		swap b, a
    7c:		mov a, y
    7d:		mov a, x
    7e:		clr a
    7f:		mov pc, a
    8v:		nop
    9v:		nop
    av:		movd v(x/y), a
    bv:		mov  v(x/y), a
    cv:		nop
    dv:		nop
    ev:		nop
    f0 HL:	mov a, #HL
    f1 HL:	add a, #HL
    f2 HL:	mov y, #hl
    f3 HL:	mov x, #hl
    f4 HL:	jne a/c, hl	if h[3] the test c otherwise test a
    f5 HL:	jeq a/c, hl	if h[3] the test c otherwise test a
    f6 HL:	jmp/call hl
    f7 HL:	nop
    
Memory is 128/256 (128 unified or 128xcode+128xdata) 4-bit nibbles, references are a 3 bit (8 byte) offset from the X or Y index registers - the general idea is that the Y register points to an 8 register scratch pad block (a bit like an 8051) but can also be repurposed for copies when required. There is an on-chip SRAM block for data access only (addressed with the MSB of the data address) - mostly just to soak up any additional gates.

There is a 4-deep hardware call stack.


# What is Tiny Tapeout?

TinyTapeout is an educational project that aims to make it easier and cheaper than ever to get your digital designs manufactured on a real chip!

Go to https://tinytapeout.com for instructions!

## How to change the Wokwi project

Edit the [info.yaml](info.yaml) and change the wokwi_id to match your project.

## How to enable the GitHub actions to build the ASIC files

Please see the instructions for:

* [Enabling GitHub Actions](https://tinytapeout.com/faq/#when-i-commit-my-change-the-gds-action-isnt-running)
* [Enabling GitHub Pages](https://tinytapeout.com/faq/#my-github-action-is-failing-on-the-pages-part)

## How does it work?

When you edit the info.yaml to choose a different ID, the [GitHub Action](.github/workflows/gds.yaml) will fetch the digital netlist of your design from Wokwi.

After that, the action uses the open source ASIC tool called [OpenLane](https://www.zerotoasiccourse.com/terminology/openlane/) to build the files needed to fabricate an ASIC.

## Resources

* [FAQ](https://tinytapeout.com/faq/)
* [Digital design lessons](https://tinytapeout.com/digital_design/)
* [Join the community](https://discord.gg/rPK2nSjxy8)

## What next?

* Share your GDS on Twitter, tag it [#tinytapeout](https://twitter.com/hashtag/tinytapeout?src=hashtag_click) and [link me](https://twitter.com/matthewvenn)!
