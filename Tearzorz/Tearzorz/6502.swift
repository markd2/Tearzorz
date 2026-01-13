// 6502.swift - main glue class for the 6502. Holds the moving pieces.

import Foundation

class MOS6502 {
    var instructions: [Instruction] = []

    let accumulator: Register = Register()
    let Xregister: Register = Register()
    let Yregister: Register = Register()
    let stackPointer: Register = Register()

    let psw: ProcessorStatusWord = ProcessorStatusWord()

    // can have some "overlays" over RAM for device I/O, ROM, text page, etc
    // Eventually this will break out into "outside the 6502". maybe.
    let RAM: [UInt8] = Array<UInt8>(repeating: 0, count: 64 * 1024)

    // do all the work to do the instruction except for incrementing
    // the program counter
    func execute(_ instruction: Instruction) {
        print("doing \(instruction)")
    }
}
