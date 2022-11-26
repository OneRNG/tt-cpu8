![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg)

# tiny 4-bit CPU

From Paul Campbell - Moonbase Otago - visit [VROOM!](https://moonbaseotago.github.io/) for something slightly bigger

This is a 4-bit CPU in verilog designed for tiny-tapeout.

It has a 4-bit accumulator, a 7-bit PC, 2 7-bit index registers and a carry bit.

The main limitations are the 6/8-bit bus - it's designed to run with an external SRAM and a 7-bit address latch, code is loaded externally.

There are 25 instructions. each 2 or 3 nibbles:

- 0 V:	 add a, V(x/y)	- sets C
- 1 V: 	 sub a, V(x/y)	- sets C
- 2 V:	 or a, V(x/y)
- 3 V:	 and a, V(x/y)
- 4 V:	 xor a, V(x/y)
- 5 V:	 mov a, V(x/y)
- 6 V:	 movd a, V(x/y)
- 7 0:	 swap x, y
- 7 1:   add a, c
- 7 2:   mov x.l, a
- 7 3:   ret
- 7 4:   add y, a
- 7 5:   add x, a
- 7 6:   add y, #1
- 7 6:   add x, #1
- 8 V:	 mov a, #V
- 9 V:	 add a, #V 
- a V:	 movd V(x/y), a
- b V: 	 mov  V(x/y), a
- c H L: mov x, #hl
- d H L: jne a/c, hl	if H[3] the test c otherwise test a
- e H L: jeq a/c, hl	if H[3] the test c otherwise test a
- f H L: jmp/call hl    if H[3] call else jmp

Memory is 128/256 (128 unified or 128xcode+128xdata) 4-bit nibbles, references are a 3 bit (8 nibble) offset from the X or Y index registers - the general idea is that the Y register points to an 8 register scratch pad block (a bit like an 8051) but can also be repurposed for copies when required. There is an on-chip SRAM block for data access only (addressed with the MSB of the data address) - mostly just to soak up any additional gates.

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
