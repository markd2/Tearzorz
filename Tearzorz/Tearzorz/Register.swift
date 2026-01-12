// Register.swift - holds register value, and change-notification mechanism

import Foundation
import Afluent
import AsyncAlgorithms

class Register {

    private var _value: UInt8 = 0
    
    var value: UInt8 {
        get { _value }
        set {
            _value = newValue
            Task { await channel.send(newValue) }
        }
    }

    private let channel = AsyncChannel<UInt8>()

    init() {
        self.value = 0
        Task { await channel.send(0) }
    }

    var values: AsyncChannel<UInt8> {
        channel
    }

}
