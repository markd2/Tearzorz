// RegisterView.swift - visualize a register, react to its changes

import AppKit

class RegisterView: NSView {
    private var updateTask: Task<Void, Never>?
    private var register: Register!
    
    override var isFlipped: Bool {
        true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        updateTask?.cancel()
    }

    func bind(to register: Register) {
//             update: @escaping @MainActor (UInt8) -> Void) {
        self.register = register

        updateTask?.cancel()

        updateTask = Task {
            for await _ in register.values {
                await MainActor.run {
                    needsDisplay = true
                }
            }
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.set()
        bounds.fill()

        let display = String(format: "%02X", register.value) as NSString
        
        let size = display.size()
        let fudgeFactor = size.height - 3 //  if the rect is perfectly centered, the text draws above it %-)
        let rect = CGRect(x: bounds.origin.x + ((bounds.width - size.width) / 2.0),
                          y: bounds.origin.y + ((bounds.height - size.height) / 2.0) + fudgeFactor,
                          width: size.width,
                          height: size.height)

        display.draw(with: rect)
        
        NSColor.black.set()
        bounds.frame()
    }
}
