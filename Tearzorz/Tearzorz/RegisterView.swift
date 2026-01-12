// RegisterView.swift - visualize a register, react to its changes

import AppKit

class RegisterView: NSView {
    var register: Register! = nil

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.set()
        bounds.fill()

        let display = String(format: "%02X", register.value)
        (display as NSString).draw(with: bounds)
        
        NSColor.black.set()
        bounds.frame()
    }
}
