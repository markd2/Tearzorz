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
        memory[0x42] = 0x10
        memory[0x43] = 0x01
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
        case Indirect:
            let address: UInt16 = instruction.modeWordAddressValue()
            let lowByte = memory[address]
            let highByte = memory[UInt16((UInt32(address) + 1) & 0xFFFF)]
            let effectiveAddress: UInt16 = UInt16(highByte) << 8 | UInt16(lowByte)
            return effectiveAddress

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
            let lowByte = memory[indexedZPAddress]
            let highByte = memory[UInt16(UInt32(indexedZPAddress) + 1 & 0xFF)]
            let effectiveAddress: UInt16 = UInt16(highByte) << 8 | UInt16(lowByte)
            return effectiveAddress

        case Indirect_Indexed_Y:
            // Syntax is ($44),Y
            // "the usefulness of this is primarily for those operations
            // in which one of several values could be used as part of
            // a subroutine.  Combine an address that points anywhere
            // in memory combined with counter offset of the index (Y) register
            let zpAddress: UInt16 = instruction.modeByteAddressValue()
            let lowByte = memory[zpAddress]
            // this wraps around, staying on zero page
            let highByte = memory[(UInt16(zpAddress) + 1) & 0xFF]
            // this is sixteen-bit math, so it's ok if it cross page boundaries
            let thirtyTwoBitAddress = ((UInt32(highByte) << 8 | UInt32(lowByte)) + UInt32(Yregister.value)) & UInt32(0xFFFF) // wrap around 16 bit address space if we started off at say $FFFF
            let address: UInt16 = UInt16(thirtyTwoBitAddress & 0xFFFF)
            return address

/*
        case Implied:
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
            return memory[address]
        case ZeroPage_XIndexed:
            let address = addressFor(instruction)
            return memory[address]
        case ZeroPage_YIndexed:
            let address = addressFor(instruction)
            return memory[address]
        case Absolute:
            let address = addressFor(instruction)
            return memory[address]
        case Absolute_XIndexed:
            let address = addressFor(instruction)
            return memory[address]
        case Absolute_YIndexed:
            let address = addressFor(instruction)
            return memory[address]
        case Indexed_Indirect_X:
            let address = addressFor(instruction)
            return memory[address]
        case Indirect_Indexed_Y:
            let address = addressFor(instruction)
            return memory[address]

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

        handlers[AND] = handleAND
        handlers[ORA] = handleORA
        handlers[EOR] = handleEOR
        handlers[ASL] = handleASL
        handlers[LSR] = handleLSR
        handlers[ROL] = handleROL
        handlers[ROR] = handleROR

        handlers[ADC] = handleADC
        handlers[SBC] = handleSBC
        handlers[INC] = handleINC
        handlers[DEC] = handleDEC
        handlers[INX] = handleINX
        handlers[INY] = handleINY
        handlers[DEX] = handleDEX
        handlers[DEY] = handleDEY

        handlers[STA] = handleSTA
        handlers[STX] = handleSTX
        handlers[STY] = handleSTY

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

        handlers[CMP] = handleCMP
        handlers[CPX] = handleCPX
        handlers[CPY] = handleCPY
        handlers[BIT] = handleBIT

        handlers[JMP] = handleJMP
        handlers[JSR] = handleJSR
        handlers[RTS] = handleRTS
        handlers[BPL] = handleBPL
        handlers[BMI] = handleBMI
        handlers[BVC] = handleBVC
        handlers[BVS] = handleBVS
        handlers[BCC] = handleBCC
        handlers[BCS] = handleBCS
        handlers[BNE] = handleBNE
        handlers[BEQ] = handleBEQ

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

    func handleSTA(_ instruction: Instruction) {
        let address = addressFor(instruction)
        memory[address] = accumulator.value
    }

    func handleSTX(_ instruction: Instruction) {
        let address = addressFor(instruction)
        memory[address] = Xregister.value
    }

    func handleSTY(_ instruction: Instruction) {
        let address = addressFor(instruction)
        memory[address] = Yregister.value
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

// Mathy / Logically stuff
extension MOS6502 {

    func handleAND(_ instruction: Instruction) {
        let byte = addressedByte(instruction)
        let result = byte & accumulator.value
        accumulator.value = result
        updateNZFlags(for: accumulator.value)
    }
    
    func handleORA(_ instruction: Instruction) {
        let byte = addressedByte(instruction)
        let result = byte | accumulator.value
        accumulator.value = result
        updateNZFlags(for: accumulator.value)
    }
    
    func handleEOR(_ instruction: Instruction) {
        let byte = addressedByte(instruction)
        let result = byte ^ accumulator.value
        accumulator.value = result
        updateNZFlags(for: accumulator.value)
    }

    // if it's accumulator mode, put the byte there, otherwise
    // figure out the effective address, and put the byte there.
    // Saves repeated nonsense in the shifting opcodes
    func setByte(_ byte: UInt8, for instruction: Instruction) {
        if instruction.addressingMode == Accumulator {
            accumulator.value = byte
        } else {
            let address = addressFor(instruction)
            memory[address] = byte
        }
    }

    func handleASL(_ instruction: Instruction) { // 58,M,Pittsburgh
        let byte = addressedByte(instruction)
        if byte & bit7 == bit7 { psw.setFlag(.C) } else { psw.clearFlag(.C) }
        let result = byte << 1

        setByte(result, for: instruction)
        updateNZFlags(for: result)
    }

    func handleLSR(_ instruction: Instruction) {
        let byte = addressedByte(instruction)

        // see if we need to send bottom bit to the carry flag
        if byte & bit0 == bit0 { psw.setFlag(.C) } else { psw.clearFlag(.C) }

        let result = byte >> 1
        
        setByte(result, for: instruction)
        updateNZFlags(for: result)
    }

    func handleROL(_ instruction: Instruction) {
        let byte = addressedByte(instruction)

        let bit7set = byte & bit7 == bit7

        // shift left by one
        var result = byte << 1
        
        // shift in the carry to bit zero
        if psw.isSet(.C) {
           result |= bit0
        }

        // shift bit 7 into the carry
        if bit7set { psw.setFlag(.C) } else { psw.clearFlag(.C) }

        setByte(result, for: instruction)
        updateNZFlags(for: result)
    }

    func handleROR(_ instruction: Instruction) {
        let byte = addressedByte(instruction)

        let bit0set = byte & bit0 == bit0

        // shift right by one
        var result = byte >> 1
        
        // shift in the carry to bit 7
        if psw.isSet(.C) {
           result |= bit7
        }

        // shift bit 0 into the carry
        if bit0set { psw.setFlag(.C) } else { psw.clearFlag(.C) }

        setByte(result, for: instruction)
        updateNZFlags(for: result)
    }

    private func handleAdd(_ thing1: UInt8, _ thing2: UInt8) -> UInt8 {
        let sum: UInt16 = UInt16(thing1) + UInt16(thing2) + (psw.isSet(.C) ? 1 : 0)
        psw.setFlag(.C, to: sum > 255)
        
        let result: UInt8 = UInt8(sum & 0xFF)
        
        // check for carry
        psw.setFlag(.C, to: sum > 255)
        
        // check for overflow
        let thing1Bit7set = thing1 & bit7 == bit7
        let thing2Bit7set = thing2 & bit7 == bit7
        let resultBit7set = result & bit7 == bit7
        
        var overflew = false
        if (thing1Bit7set && thing2Bit7set) && !resultBit7set { overflew = true }
        if (!thing1Bit7set && !thing2Bit7set) && resultBit7set { overflew = true }
        psw.setFlag(.V, to: overflew)
        
        return result
    }

    func handleADC(_ instruction: Instruction) {
        let byte = addressedByte(instruction)

        if psw.isSet(.D) {
            // BCD
            print("no BCD yet")
        } else {

            // two's complement
            let result = handleAdd(accumulator.value, byte)

            accumulator.value = result
            updateNZFlags(for: result)
        }
    }

    func handleSBC(_ instruction: Instruction) {
        let byte = addressedByte(instruction)

        if psw.isSet(.D) {
            // BCD
            print("no BCD yet")
        } else {

            // two's complement
            // subtraction is the same as adding, but doing a 1s-complement
            // of the memory field.  The carry flag being set before SBC
            // turns it into true two's complement
            // http://forum.6502.org/viewtopic.php?p=97407&sid=5a386f79fc3ed4596724aa9f73582d93#p97407
            let result = handleAdd(accumulator.value, ~byte)

            accumulator.value = result
            updateNZFlags(for: result)
        }
    }

    func handleINC(_ instruction: Instruction) {
        let address = addressFor(instruction)
        let byte = memory[address]
        let result = UInt8( (UInt16(byte) + 1) & 0xFF )
        memory[address] = result
        updateNZFlags(for: result)
    }

    func handleDEC(_ instruction: Instruction) {
        let address = addressFor(instruction)
        let byte = memory[address]
        let result = UInt8( (Int16(byte) - 1) & 0xFF )
        memory[address] = result
        updateNZFlags(for: result)
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
    func push(_ byte: UInt8) {
        let address: UInt16 = UInt16(0x01 << 8) | UInt16(stackPointer.value & 0xFF)
        memory[address] = byte

        // post increment SP
        var newSP = stackPointer.value
        if newSP > 0 { newSP = newSP - 1 }
        else { newSP = 255 }
        stackPointer.value = newSP
    }

    // eventually the world settled on 'pop' for this operation, but the 6502
    // manuals and opcodes call it pull.
    func pull() -> UInt8 {
        // pre decrement SP.
        // move stack pointer up a byte, wrapping around if passes 0xFF

        var newSP = stackPointer.value
        if newSP < 255 { newSP = newSP + 1 }
        else { newSP = 0 }
        stackPointer.value = newSP

        let address: UInt16 = UInt16(0x01 << 8) | UInt16(stackPointer.value & 0xFF)
        let byte = memory[address]
        return byte
    }

    func handlePHA(_ instruction: Instruction) {
        push(accumulator.value)
        // storing/pushing don't update NZ flags
    }

    func handlePLA(_ instruction: Instruction) {
        let byte = pull()
        accumulator.value = byte
        updateNZFlags(for: accumulator.value)
    }

    func handlePHP(_ instruction: Instruction) {
        push(psw.flags.rawValue)
        // storing/pushing don't update NZ flags
    }

    func handlePLP(_ instruction: Instruction) {
        let byte = pull()
        psw.setFlags(byte)
    }
}

// Comparison instructions
extension MOS6502 {

    func updateComparisonFlags(registerByte: UInt8, memoryByte: UInt8) {

        // described as A - M
        //   A < M  : Z=0, C=0
        //   A = M  : Z=1, C=1
        //   A > M  : Z=0, C=1

        if registerByte == memoryByte { psw.setFlag(.Z) } else { psw.clearFlag(.Z) }
        if registerByte >= memoryByte { psw.setFlag(.C) } else { psw.clearFlag(.C) }

        let diff = Int32(bitPattern: UInt32(registerByte)) - Int32(bitPattern: UInt32(memoryByte)) // I <3 Swift so much
        if diff < 0 { psw.setFlag(.N) } else { psw.clearFlag(.N) }
    }

    func handleCMP(_ instruction: Instruction) {
        let address = UInt16(addressedByte(instruction))
        updateComparisonFlags(registerByte: accumulator.value,
                              memoryByte: memory[address])
    }

    func handleCPX(_ instruction: Instruction) {
        let address = UInt16(addressedByte(instruction))
        updateComparisonFlags(registerByte: Xregister.value,
                              memoryByte: memory[address])
    }

    func handleCPY(_ instruction: Instruction) {
        let address = UInt16(addressedByte(instruction))
        updateComparisonFlags(registerByte: Yregister.value,
                              memoryByte: memory[address])
    }

    func handleBIT(_ instruction: Instruction) {
        let byte = addressedByte(instruction)
        let andAcc = byte & accumulator.value

        // it's a non-destructive AND with the accumulator
        if andAcc == 0 { psw.setFlag(.Z) } else { psw.clearFlag(.Z) }

        // oh, also look at the high two bits of the memory value and
        // set flags. Kind of a three-fer looking at bits
        if byte & bit7 == bit7 { psw.setFlag(.N) } else { psw.clearFlag(.N) }
        if byte & bit6 == bit6 { psw.setFlag(.V) } else { psw.clearFlag(.V) }
    }
}

// Branching instructions
extension MOS6502 {
    func handleJMP(_ instruction: Instruction) {
        let address = addressFor(instruction)
        programCounter.value = address
    }

    func handleJSR(_ instruction: Instruction) {
        // point to the last byte of the JSR instruction
        let pc = programCounter.value - 1
        let lowPC = UInt8(pc & 0xFF)
        let highPC = UInt8(pc >> 8 & 0xFF)

        // push high first so the low byte is in the lower addres
        push(highPC)
        push(lowPC)

        let address = addressFor(instruction)
        programCounter.value = address
    }

    func handleRTS(_ instruction: Instruction) {
        let lowPC = pull()
        let highPC = pull()
        var address = UInt16(highPC) << 8 | UInt16(lowPC)
        address = UInt16((UInt32(address) + 1) & 0xFFFF)
        programCounter.value = address
    }

    func offsetAddress(_ address: UInt16, by byte: UInt8) -> UInt16 {
        let signedByte = Int8(bitPattern: byte)
        
        var addr = Int32(address)
        addr += Int32(signedByte)
        let effectiveAddress = UInt16(bitPattern: Int16(addr & 0xFF))
        return effectiveAddress
    }

    func handleBPL(_ instruction: Instruction) {
        guard psw.isSet(.N) else { return }
        programCounter.value = offsetAddress(self.programCounter.value,
                                             by: instruction.modeByteValue())
    }

    func handleBMI(_ instruction: Instruction) {
        guard psw.isClear(.N) else { return }
        programCounter.value = offsetAddress(self.programCounter.value,
                                             by: instruction.modeByteValue())
    }

    func handleBVC(_ instruction: Instruction) {
        guard psw.isClear(.V) else { return }
        programCounter.value = offsetAddress(self.programCounter.value,
                                             by: instruction.modeByteValue())
    }

    func handleBVS(_ instruction: Instruction) {
        guard psw.isSet(.V) else { return }
        programCounter.value = offsetAddress(self.programCounter.value,
                                             by: instruction.modeByteValue())
    }

    func handleBCC(_ instruction: Instruction) {
        guard psw.isClear(.C) else { return }
        programCounter.value = offsetAddress(self.programCounter.value,
                                             by: instruction.modeByteValue())
    }

    func handleBCS(_ instruction: Instruction) {
        guard psw.isSet(.C) else { return }
        programCounter.value = offsetAddress(self.programCounter.value,
                                             by: instruction.modeByteValue())
    }

    func handleBNE(_ instruction: Instruction) {
        guard psw.isClear(.Z) else { return }
        programCounter.value = offsetAddress(self.programCounter.value,
                                             by: instruction.modeByteValue())
    }

    func handleBEQ(_ instruction: Instruction) {
        guard psw.isSet(.Z) else { return }
        programCounter.value = offsetAddress(self.programCounter.value,
                                             by: instruction.modeByteValue())
    }
}

// Misc instructions
extension MOS6502 {
    func handleNOP(_ instruction: Instruction) {
        // nobody home
    }
}

extension Opcode: Hashable { }
