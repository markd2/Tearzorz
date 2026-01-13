// Memory.swift - have a sea of RAM

import Foundation
import Combine

class Memory {
    static let capacity = 64 * 1024 // 64K
    private var bytes: [UInt8] = Array<UInt8>(repeating: 0, count: capacity)

    func randomizeBytes() {
        for i in 0 ..< Self.capacity {
            bytes[i] = UInt8.random(in: 0 ... 255)
        }
    }

    func byte(at index: UInt16) -> UInt8 {
        bytes[Int(index)]
    }

    func setByte(_ value: UInt8, at index: UInt16) {
        bytes[Int(index)] = value
    }

    func page(at index: UInt8) -> [UInt8] {
        let page = bytes[Int(index) * 256 ..< (Int(index) + 1) * 256]
        return Array(page)
    }
}
