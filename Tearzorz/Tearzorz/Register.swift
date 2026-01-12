// Register.swift - holds register value, and change-notification mechanism

import Foundation
import Afluent
import Combine

class Register<Value> {

    private let subject: Combine.CurrentValueSubject<Value, Never>
    
    init(_ initialValue: Value = UInt8(0)) {
        self.subject = CurrentValueSubject(initialValue)
    }

    var value: Value {
        get { subject.value }
        set { subject.send(newValue) }
    }

    var publisher: AnyPublisher<Value, Never> {
        subject.eraseToAnyPublisher()
    }
}
