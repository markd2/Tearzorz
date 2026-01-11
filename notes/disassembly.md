# Disassembly

Seat of the pants, no looking into prior art or looking at good ways to do
thing. Disassembling 6502 machine code.

### Instructions and Addressing modes

There's a number of opcodes (~56), and a number of addressing modes (13),
for a number (~150) of distinct instruction bytes.

Each byte of an instruction encodes:

* opcode
* addressing mode

Followed by sufficient bytes to satisfy the addresing mode.

Not all opcodes support all addressing modes.

Given a byte, I want to know:

* what its opcode is
* what addresing mode is, which gives how many more bytes to consume
* how to interpret the additional bytes
* how to display them in ascii
* if we make an interpreter, enough info to easily execute them.

so, 

* enum of opcodes (LDA, STX, etc). Don't mind this being huge.
* enum of addressing modes.  it's only 13
* structure / class of opcode and addressing mode pair
* the instruction bytes (up to 3) so it can be torn apart
* logic to tear apart those bytes, given the addressing mode

Planning on doing this in objective-C land because doing pointer stuff
in Swift is a pain.  Can't really use Range because I don't want
to be dragged into Tahoe when Xcode inevitablily drops support
of a perfectly servicable operating system.

