// NumericUtilities - like tumeric utilities, but different

import Foundation

extension UInt8 {
    /// Turn a byte into a "0101 1100" style
    var binaryString: String {
        let binary = String(self, radix: 2)
        
        let padded = String(repeating: "0",
                            count: 8 - binary.count) + binary
        
        // stick in the space
        let index = padded.index(padded.startIndex, offsetBy: 4)

        let firstHalf = padded[..<index] // Uses partial range up to
        let secondHalf = padded[index...] // Uses partial range from

        let finalForm = String(firstHalf) + " " + String(secondHalf)
        return finalForm
    }
}

