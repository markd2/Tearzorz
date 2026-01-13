// RegisterView.swift - visualize a register, react to its changes

import AppKit
import Combine

class RegisterView: NSView {
    
    private var cancellable: AnyCancellable?
    private var register: Register<UInt8>!
    
    override var isFlipped: Bool {
        true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        cancellable?.cancel()
    }

    func bind(to register: Register<UInt8>) {
//             update: @escaping @MainActor (UInt8) -> Void) {
        self.register = register
        cancellable = register.publisher
          .receive(on: RunLoop.main)
          .sink { value in
              _ = value
              self.needsDisplay = true
          }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.set()
        bounds.fill()

        let display = String(format: "$%02X\n%@", register.value,
                             register.value.binaryString) as NSString
        
        let size = display.size()
        let rect = CGRect(x: bounds.origin.x + ((bounds.width - size.width) / 2.0),
                          y: bounds.origin.y + ((bounds.height - size.height) / 2.0),
                          width: size.width,
                          height: size.height)

        display.draw(with: rect,
                     options: .usesLineFragmentOrigin)
        
        NSColor.black.set()
        bounds.frame()
    }
}

extension UInt8 {
    // Turn a byte into a "0101 1100" style
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
