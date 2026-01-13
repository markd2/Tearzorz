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
/*
        case Absolute:
        case Absolute_XIndexed:
        case Absolute_YIndexed:
        case Implied:
        case Indirect:
        case Indexed_Indirect_X:
        case Indirect_Indexed_Y:
        case Relative:
        case ZeroPage_XIndexed:
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
/*
        case Absolute:
        case Absolute_XIndexed:
        case Absolute_YIndexed:
        case Implied:
        case Indirect:
        case Indexed_Indirect_X:
        case Indirect_Indexed_Y:
        case Relative:
        case ZeroPage_XIndexed:
        case ZeroPage_YIndexed:
*/
        default:
            print("oops")
            return 0xff
        }
    }

    func updateFlags(for byte: UInt8) {
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
        handlers[LDA] = handleLDA
        handlers[STA] = handleSTA
        handlers[NOP] = handleNOP
    }
    
    func handleCLC(_ instruction: Instruction) {
        psw.clearFlag(.C)
    }

    func handleLDA(_ instruction: Instruction) {
        let byte = addressedByte(instruction)
        accumulator.value = byte
        updateFlags(for: byte)
    }

    func handleSTA(_ instruction: Instruction) {
        let address = addressFor(instruction)
        memory.setByte(accumulator.value, at: address)
    }

    func handleNOP(_ instruction: Instruction) {
        // nobody home
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

extension Opcode: Hashable { }
