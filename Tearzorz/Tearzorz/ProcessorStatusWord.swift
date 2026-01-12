import Foundation


class ProcessorStatusWord {
    struct Storage: OptionSet {
        let rawValue: UInt8

        /// Negative - set if the most significant bit of the result 1 is 
        static let N = Storage(rawValue: 1 << 7)

        /// Overflow - set if a signed math operation results in an overflow
        static let V = Storage(rawValue: 1 << 6)

        /// Break flag used by the BRK instruction
        static let brk = Storage(rawValue: 1 << 5)

        /// Always 1 when pushed to the stack. Otherwise unused / left for expansion
        static let ignored = Storage(rawValue: 1 << 4) // always 1

        /// Decimal (BCD) mode flag
        static let D = Storage(rawValue: 1 << 3)

        /// Interrupt disable flag - disables maskable interrupts
        static let I = Storage(rawValue: 1 << 2)

        /// Zero - set if the result of an operation is zero
        static let Z = Storage(rawValue: 1 << 1)

        /// Carry - set if an addition generates a carry (to the "9th bit")
        /// or a subtraction requires a borrow.
        static let C = Storage(rawValue: 1 << 0)
    }
}
