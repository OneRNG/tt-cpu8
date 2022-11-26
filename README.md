![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg)

# tiny 4-bit CPU

From Paul Campbell - Moonbase Otago - visit [VROOM!](https://moonbaseotago.github.io/) for something slightly bigger

This is a 4-bit CPU in verilog designed for tiny-tapeout.

It has a 4-bit accumulator, a 7-bit PC, 2 7-bit index registers and a carry bit.

The main limitations are the 6/8-bit bus - it's designed to run with an external SRAM and a 7-bit address latch, code is loaded externally.

There are 25 instructions:

- 0 v:	 add a, v(x/y)	- sets C
- 1 v: 	 sub a, v(x/y)	- sets C
- 2 v:	 or a, v(x/y)
- 3 v:	 and a, v(x/y)
- 4 v:	 xor a, v(x/y)
- 5 v:	 mov a, v(x/y)
- 6 v:	 movd a, v(x/y)
- 7 0:	 swap x, y
- 7 1:   add a, c
- 7 2:   mov x.l, a
- 7 3:   mov a, x[3:0]
- 7 4:   add y, a
￼- 7 5:   add x, a
￼- 7 6:   add y, #1
- 7 6:   add x, #1
- 8 v:	 mov a, #v
- 9 v:	 add a, #v 
- a v:	 movd v(x/y), a
- b v: 	 mov  v(x/y), a
- c h l: mov x, #hl
- d h l: jne a/c, hl	if h[3] the test c otherwise test a
- e h l: jeq a/c, hl	if h[3] the test c otherwise test a
- f h l: jmp hl

Memory references are a 3 bit (8 byte) offset from the x or y index registers - the general idea is that the y register points to an 8 register scratch pad block (a bit like an 8051) but can also be repurposed for copies when required.


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
