// ProcessStatusWord.swift - the PSW / bits that are set and tested in the
//    regular operation of the 6502

import Foundation
import Combine

class ProcessorStatusWord {
    private let subject: Combine.CurrentValueSubject<Flags, Never>

    init() {
        self.subject = CurrentValueSubject(Flags())
    }

    var flags: Flags {
        get { subject.value }
        set { subject.send(newValue) }
    }

    var publisher: AnyPublisher<Flags, Never> {
        subject.eraseToAnyPublisher()
    }

    struct Flags: OptionSet {
        init(rawValue: UInt8) {
            self.rawValue = rawValue
            self.displayString = ""
        }
        
        init(rawValue: UInt8, displayString: String) {
            self.rawValue = rawValue
            self.displayString = displayString
        }
        
        let rawValue: UInt8
        let displayString: String

        /// Negative - set if the most significant bit of the result 1 is 
        static let N = Flags(rawValue: 1 << 7, displayString: "N")

        /// Overflow - set if a signed math operation results in an overflow
        static let V = Flags(rawValue: 1 << 6, displayString: "V")

        /// Break flag used by the BRK instruction
        static let brk = Flags(rawValue: 1 << 5, displayString: "B")

        /// Always 1 when pushed to the stack. Otherwise unused / left for expansion
        static let ignored = Flags(rawValue: 1 << 4, displayString: "") // always 1

        /// Decimal (BCD) mode flag
        static let D = Flags(rawValue: 1 << 3, displayString: "D")

        /// Interrupt disable flag - disables maskable interrupts
        static let I = Flags(rawValue: 1 << 2, displayString: "I")

        /// Zero - set if the result of an operation is zero
        static let Z = Flags(rawValue: 1 << 1, displayString: "Z")

        /// Carry - set if an addition generates a carry (to the "9th bit")
        /// or a subtraction requires a borrow.
        static let C = Flags(rawValue: 1 << 0, displayString: "C")
    }

    func setFlag(_ flag: Flags) {
        flags = flags.union([flag])
    }
    
    func clearFlag(_ flag: Flags) {
        flags = flags.subtracting([flag])
    }

    func isSet(_ flag: Flags) -> Bool {
        flags.contains(flag)
    }
}
