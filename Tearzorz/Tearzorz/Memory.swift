// Memory.swift - have a sea of RAM

import Foundation
import Combine

class Memory {
    private let subject: Combine.PassthroughSubject<Notification, Never>

    enum Notification {
        case byteWrite(address: UInt16, oldValue: UInt8, newValue: UInt8)

        var address: UInt16? {
            switch self {
            case let .byteWrite(addr, _, _): return addr
            }
        }
    }

    static let capacity = 64 * 1024 // 64K
    var bytes: [UInt8] = Array<UInt8>(repeating: 0, count: capacity)

    init() {
        self.subject = PassthroughSubject()
    }

    var publisher: AnyPublisher<Notification, Never> {
        subject.eraseToAnyPublisher()
    }

    func randomizeBytes() {
        for i in 0 ..< Self.capacity {
            bytes[i] = UInt8.random(in: 0 ... 255)
        }

        // if we get a range notification, specify the range
        subject.send(Notification.byteWrite(address: 0,
                                            oldValue: 0,
                                            newValue: 0))
    }

    func byte(at index: UInt16) -> UInt8 {
        bytes[Int(index)]
    }

    subscript(address: UInt16) -> UInt8 {
        get {
            byte(at: address)
        }
        set(newValue) {
            setByte(newValue, at: address)
        }
    }

    func setByte(_ value: UInt8, at index: UInt16) {
        let oldValue = bytes[Int(index)]
        bytes[Int(index)] = value

        // intentionally sending even if value doesn't change. The fact that
        // someone tried to change it might be interesting
        subject.send(Notification.byteWrite(address: index,
                                            oldValue: oldValue,
                                            newValue: value))
    }

    func page(at index: UInt8) -> [UInt8] {
        let page = bytes[Int(index) * 256 ..< (Int(index) + 1) * 256]
        return Array(page)
    }
}
