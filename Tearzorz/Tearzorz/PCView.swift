// PCView.swift - visualize the program counter, react to its changes.
//    Was wanting to tweak Register for this, but the UInt8/UInt16 

import AppKit
import Combine

class PCView: NSView {
    
    private var cancellable: AnyCancellable?
    private var register: Register<UInt16>!
    private var isHighlighted = false
    
    override var isFlipped: Bool {
        true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        cancellable?.cancel()
    }

    func bind(to register: Register<UInt16>) {
        self.register = register
        cancellable = register.publisher
          .receive(on: RunLoop.main)
          .sink { value in
              _ = value
              self.isHighlighted = true
              self.clearHighlightIn(Constants.changeHighlightInterval)
              self.needsDisplay = true
          }
    }

    func clearHighlightIn(_ seconds: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.isHighlighted = false
            self.needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        (isHighlighted ? Colors.changeHighlight : NSColor.white).set()
        bounds.fill()

        let display = String(format: "$%04X", register.value) as NSString

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
