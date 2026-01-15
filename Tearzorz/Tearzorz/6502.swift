// 6502.swift - main glue class for the 6502. Holds the moving pieces.

import Foundation

typealias InstructionHandler = (Instruction) -> Void

class MOS6502 {
    var instructions: [Instruction] = []

    let accumulator: Register = Register()
    let Xregister: Register = Register()
    let Yregister: Register = Register()
    let stackPointer: Register = Register()

    let psw: ProcessorStatusWord = ProcessorStatusWord()

    // can have some "overlays" over RAM for device I/O, ROM, text page, etc
    // Eventually this will break out into "outside the 6502". maybe.
    let memory: Memory = Memory()

    var handlers: [Opcode: InstructionHandler] = [:]

    init() {
        setupHandlers()
        memory.randomizeBytes()
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
            print(String(format: "looking at %04x", UInt16(address)))
            return address

/*
        case Absolute:
        case Absolute_YIndexed:
        case Absolute_XIndexed:
        case Implied:
        case Indirect:
        case Indexed_Indirect_X:
        case Indirect_Indexed_Y:
        case Relative:
        case ZeroPage_YIndexed:

        // no addresses for these dudes
        case Accumulator:
        case Immediate:
*/
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

/*
        case Absolute:
        case Absolute_XIndexed:
        case Absolute_YIndexed:
        case Implied:
        case Indirect:
        case Indexed_Indirect_X:
        case Indirect_Indexed_Y:
        case Relative:
        case ZeroPage_YIndexed:
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

// Misc instructions
extension MOS6502 {
    func handleNOP(_ instruction: Instruction) {
        // nobody home
    }
}

extension Opcode: Hashable { }
