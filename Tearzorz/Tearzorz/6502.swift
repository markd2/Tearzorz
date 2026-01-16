// 6502.swift - main glue class for the 6502. Holds the moving pieces.

import Foundation

typealias InstructionHandler = (Instruction) -> Void

class MOS6502 {
    var instructions: [Instruction] = []

    let accumulator: Register<UInt8> = Register()
    let Xregister: Register<UInt8> = Register()
    let Yregister: Register<UInt8> = Register()
    let stackPointer: Register<UInt8> = Register()

    let psw: ProcessorStatusWord = ProcessorStatusWord()

    let programCounter: Register<UInt16> = Register()

    // can have some "overlays" over RAM for device I/O, ROM, text page, etc
    // Eventually this will break out into "outside the 6502". maybe.
    let memory: Memory = Memory()

    var handlers: [Opcode: InstructionHandler] = [:]

    init() {
        setupHandlers()
        memory.randomizeBytes()
        reset()

        // set up for exercising Indirect Indexed (Y) mode
        memory.setByte(0x10, at: 0x42)
        memory.setByte(0x01, at: 0x43)
        Yregister.value = 0x55
    }

    func reset() {
        // ideally, a ROM routine (function) pointer at (FFFC/D) will clear
        // the CPU state (set A,X,Y to zero, SP to 0xFD because it's cleared,
        // and RESET does the "push three things on the stack".  The first
        // writes to zero and wraps around, then two more.
        // Resumably the code pointed to by the reset vector can change SP to
        // 0xFF and get those two bytes back
        accumulator.value = 0
        Xregister.value = 0
        Yregister.value = 0
        stackPointer.value = 0xFD

        // start the PC at (0xFFFC) when things get real
    }

    // for extension
    let bit0: UInt8 = 1 << 0
    let bit1: UInt8 = 1 << 1
    let bit2: UInt8 = 1 << 2
    let bit3: UInt8 = 1 << 3
    let bit4: UInt8 = 1 << 4
    let bit5: UInt8 = 1 << 5
    let bit6: UInt8 = 1 << 6
    let bit7: UInt8 = 1 << 7
}

/// instruction execution
extension MOS6502 {

    func addressFor(_ instruction: Instruction) -> UInt16 {
        switch instruction.addressingMode {
        case ZeroPage:
            let address = instruction.modeByteAddressValue()
            return address
        case ZeroPage_XIndexed:
            var address: UInt16 = instruction.modeByteAddressValue()
            address += UInt16(Xregister.value)
            return address
        case ZeroPage_YIndexed:
            var address: UInt16 = instruction.modeByteAddressValue()
            address += UInt16(Yregister.value)
            return address
        case Absolute:
            let address: UInt16 = instruction.modeWordAddressValue()
            return address
        case Absolute_XIndexed:
            // not doing the page-crossing work here. If a page is crossed,
            // for HB (high byte) and LB (low byte)
            //   - One is added to LB.  It overflows into the carry
            //   -   HB and the LB value are combined into an address, and
            //       that byte read (from the wrong place)
            //   - The carry is added to HB
            //       - HB and t he LB value are combined into an address, and
            //       *that* byte is read
            // costing one cycle, and an extra (throw-away) data read.
            // no doing this could be bad if we're doing this operation on
            // a memory read location that sensitive to reads. The algo below
            // just does a simple add, ignoring the cross-page shenanigans
            var address: UInt16 = instruction.modeWordAddressValue()
            address += UInt16(Xregister.value)
            return address
        case Absolute_YIndexed:
            var address: UInt16 = instruction.modeWordAddressValue()
            address += UInt16(Yregister.value)
            return address

        case Indexed_Indirect_X:
            // Syntax is XYZ ($44,X)
            // "major use is in picking up data from a table or a list
            // of addresses to perform an operation"
            // "examples where this is applicable is in polling I/O devices
            // or performing string ot multiple string operations" (?)
            // "useful for implementing jump tables or accessing elements
            // in an array of pointers in the zero page"
            // TL;DR: X is added to the zero page address (ZPA).  That's the
            //   low byte.  The next page address (ZPA+1) forms the high byte.
            //   then *that* is used as the effective address.
            // It's *Indexed Indirect* because the index happens before the
            // indirection.
            let zpAddress: UInt16 = instruction.modeByteAddressValue()
            let indexedZPAddress: UInt16 = (zpAddress + UInt16(Xregister.value)) & 0xFF // ignore carry
            let lowByte = memory.byte(at: indexedZPAddress)
            let highByte = memory.byte(at: (indexedZPAddress + 1) % 0xFF)
            let effectiveAddress: UInt16 = UInt16(highByte) << 8 | UInt16(lowByte)
            return effectiveAddress

        case Indirect_Indexed_Y:
            // Syntax is ($44),Y
            // "the usefulness of this is primarily for those operations
            // in which one of several values could be used as part of
            // a subroutine.  Combine an address that points anywhere
            // in memory combined with counter offset of the index (Y) register
            let zpAddress: UInt16 = instruction.modeByteAddressValue()
            let lowByte = memory.byte(at: zpAddress)
            // this wraps around, staying on zero page
            let highByte = memory.byte(at: (UInt16(zpAddress) + 1) % 0xFF)
            // this is sixteen-bit math, so it's ok if it cross page boundaries
            let thirtyTwoBitAddress = ((UInt32(highByte) << 8 | UInt32(lowByte)) + UInt32(Yregister.value)) & UInt32(0xFFFF) // wrap around 16 bit address space if we started off at say $FFFF
            let address: UInt16 = UInt16(thirtyTwoBitAddress & 0xFFFF)
            return address

/*
        case Implied:
        case Indirect: // just used by JMP. there is no pure indirect for other instructions. 
        case Relative:  // this is pretty complicated due to page-boundary crossings, so kicked that can further down the road. only for branches

        // no addresses for these dudes
        case Accumulator:
        case Immediate:
*/
        case Implied:
            fallthrough
        default:
            print("oops address")
            return 0x0000
        }
    }

    func addressedByte(_ instruction: Instruction) -> UInt8 {
        switch instruction.addressingMode {
        case Accumulator:
            return accumulator.value
        case Immediate:
            return instruction.modeByteValue()
        case ZeroPage:
            let address = addressFor(instruction)
            return memory.bytes[Int(address)]
        case ZeroPage_XIndexed:
            let address = addressFor(instruction)
            return memory.bytes[Int(address)]
        case ZeroPage_YIndexed:
            let address = addressFor(instruction)
            return memory.bytes[Int(address)]
        case Absolute:
            let address = addressFor(instruction)
            return memory.bytes[Int(address)]
        case Absolute_XIndexed:
            let address = addressFor(instruction)
            return memory.bytes[Int(address)]
        case Absolute_YIndexed:
            let address = addressFor(instruction)
            return memory.bytes[Int(address)]
        case Indexed_Indirect_X:
            let address = addressFor(instruction)
            return memory.bytes[Int(address)]
        case Indirect_Indexed_Y:
            let address = addressFor(instruction)
            return memory.bytes[Int(address)]

/*
        case Implied:
        case Indirect:
        case Relative:
*/
        default:
            print("oops")
            return 0xff
        }
    }

    func updateNZFlags(for byte: UInt8) {
        if byte == 0 {
            psw.setFlag(.Z)
        } else {
            psw.clearFlag(.Z)
        }

        if byte & bit7 != 0 {
            psw.setFlag(.N)
        } else {
            psw.clearFlag(.N)
        }
    }

    func setupHandlers() {
        handlers[CLC] = handleCLC
        handlers[SEC] = handleSEC
        handlers[CLI] = handleCLI
        handlers[SEI] = handleSEI
        handlers[CLV] = handleCLV
        handlers[CLD] = handleCLD
        handlers[SED] = handleSED

        handlers[LDA] = handleLDA
        handlers[LDX] = handleLDX
        handlers[LDY] = handleLDY

        handlers[INX] = handleINX
        handlers[INY] = handleINY
        handlers[DEX] = handleDEX
        handlers[DEY] = handleDEY

        handlers[STA] = handleSTA

        handlers[PHA] = handlePHA
        handlers[PLA] = handlePLA
        handlers[PHP] = handlePHP
        handlers[PLP] = handlePLP

        handlers[TAX] = handleTAX
        handlers[TAY] = handleTAY
        handlers[TSX] = handleTSX
        handlers[TXA] = handleTXA
        handlers[TXS] = handleTXS
        handlers[TYA] = handleTYA

        handlers[NOP] = handleNOP
    }
    
    func handleLDA(_ instruction: Instruction) {
        let byte = addressedByte(instruction)
        accumulator.value = byte
        updateNZFlags(for: byte)
    }

    func handleLDX(_ instruction: Instruction) {
        let byte = addressedByte(instruction)
        Xregister.value = byte
        updateNZFlags(for: byte)
    }

    func handleLDY(_ instruction: Instruction) {
        let byte = addressedByte(instruction)
        Yregister.value = byte
        updateNZFlags(for: byte)
    }

    func handleINX(_ instruction: Instruction) {
        var byte = Xregister.value
        if byte < 255 {
            byte = byte + 1
        } else {
            byte = 0
        }
        Xregister.value = byte
        updateNZFlags(for: byte)
    }

    func handleINY(_ instruction: Instruction) {
        var byte = Yregister.value
        if byte < 255 {
            byte = byte + 1
        } else {
            byte = 0
        }
        Yregister.value = byte
        updateNZFlags(for: byte)
    }

    func handleDEX(_ instruction: Instruction) {
        var byte = Xregister.value

        if byte > 0 {
            byte = byte - 1
        } else {
            byte = 255
        }
        Xregister.value = byte
        updateNZFlags(for: byte)
    }

    func handleDEY(_ instruction: Instruction) {
        var byte = Yregister.value

        if byte > 0 {
            byte = byte - 1
        } else {
            byte = 255
        }
        Yregister.value = byte
        updateNZFlags(for: byte)
    }

    func handleSTA(_ instruction: Instruction) {
        let address = addressFor(instruction)
        memory.setByte(accumulator.value, at: address)
    }

    // do all the work to do the instruction except for incrementing
    // the program counter
    func execute(_ instruction: Instruction) {
        guard let handler = handlers[instruction.opcode] else {
            print("no handler for \(instruction)")
            return
        }

        // increment PC first, because branches are relative to the
        // address of the instruction _after_ the branch instruction
        programCounter.value += instruction.byteCount
        handler(instruction)
    }
}


// PSW Flags
extension MOS6502 {
    func handleCLC(_ instruction: Instruction) {
        psw.clearFlag(.C)
    }

    func handleSEC(_ instruction: Instruction) {
        psw.setFlag(.C)
    }

    func handleCLI(_ instruction: Instruction) {
        psw.clearFlag(.I)
    }

    func handleSEI(_ instruction: Instruction) {
        psw.setFlag(.I)
    }

    func handleCLV(_ instruction: Instruction) {
        psw.clearFlag(.V)
    }

    func handleCLD(_ instruction: Instruction) {
        psw.clearFlag(.D)
    }

    func handleSED(_ instruction: Instruction) {
        psw.setFlag(.D)
    }
}

// Transfer instructions
extension MOS6502 {
    func handleTAX(_ instruction: Instruction) {
        Xregister.value = accumulator.value
        updateNZFlags(for: Xregister.value)
    }

    func handleTAY(_ instruction: Instruction) {
        Yregister.value = accumulator.value
        updateNZFlags(for: Yregister.value)
    }

    func handleTSX(_ instruction: Instruction) {
        Xregister.value = stackPointer.value
        updateNZFlags(for: Xregister.value)
    }

    func handleTXA(_ instruction: Instruction) {
        accumulator.value = Xregister.value
        updateNZFlags(for: accumulator.value)
    }

    func handleTXS(_ instruction: Instruction) {
        stackPointer.value = Xregister.value
        updateNZFlags(for: stackPointer.value)
    }

    func handleTYA(_ instruction: Instruction) {
        accumulator.value = Yregister.value
        updateNZFlags(for: accumulator.value)
    }
}

// Stacky stuff
extension MOS6502 {
    func handlePHA(_ instruction: Instruction) {
        // put the byte where the stack pointer is pointing to
        Swift.print(String(format: "starting snack pointer value %02X", stackPointer.value))
        let byte = accumulator.value
        let address: UInt16 = UInt16(0x01 << 8) | UInt16(stackPointer.value & 0xFF)
        memory.setByte(byte, at: address)
        Swift.print(String(format: "  setting %04X to %02X", address, byte))

        // move stack pointer down a byte, wrapping around if passes zero
        var newSP = stackPointer.value
        if newSP > 0 { newSP = newSP - 1 }
        else { newSP = 255 }
        stackPointer.value = newSP
        Swift.print(String(format: "    new snack pointer value %02X", newSP))
        // storing/pushing don't update NZ flags
    }

    func handlePLA(_ instruction: Instruction) {
        // move stack pointer up a byte, wrapping around if passes 0xFF
        var newSP = stackPointer.value
        if newSP < 255 { newSP = newSP + 1 }
        else { newSP = 0 }
        stackPointer.value = newSP

        // put the byte where the stack pointer is pointing to
        let address: UInt16 = UInt16(0x01 << 8) | UInt16(stackPointer.value & 0xFF)
        accumulator.value = memory.byte(at: address)

        updateNZFlags(for: accumulator.value)
    }

    func handlePHP(_ instruction: Instruction) {
        // put the byte where the stack pointer is pointing to
        Swift.print(String(format: "starting snack pointer value %02X", stackPointer.value))
        let byte = psw.flags
        let address: UInt16 = UInt16(0x01 << 8) | UInt16(stackPointer.value & 0xFF)
        memory.setByte(byte.rawValue, at: address)
        Swift.print(String(format: "  setting %04X to %02X", address, byte.rawValue))

        // move stack pointer down a byte, wrapping around if passes zero
        var newSP = stackPointer.value
        if newSP > 0 { newSP = newSP - 1 }
        else { newSP = 255 }
        stackPointer.value = newSP
        Swift.print(String(format: "    new snack pointer value %02X", newSP))
        // storing/pushing don't update NZ flags
    }

    func handlePLP(_ instruction: Instruction) {
        // move stack pointer up a byte, wrapping around if passes 0xFF
        var newSP = stackPointer.value
        if newSP < 255 { newSP = newSP + 1 }
        else { newSP = 0 }
        stackPointer.value = newSP

        // put the byte where the stack pointer is pointing to
        let address: UInt16 = UInt16(0x01 << 8) | UInt16(stackPointer.value & 0xFF)
        psw.setFlags(memory.byte(at: address))
    }
}

// Misc instructions
extension MOS6502 {
    func handleNOP(_ instruction: Instruction) {
        // nobody home
    }
}

extension Opcode: Hashable { }
