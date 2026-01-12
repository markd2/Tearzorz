// PSWView.swift - visualize the processor status longword,
//     react to it changes

import AppKit
import Combine

class PSWView: NSView {
    private var cancellable: AnyCancellable?
    var psw: ProcessorStatusWord! = nil

    override var isFlipped: Bool {
        true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        cancellable?.cancel()
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.set()
        bounds.fill()

        let flags: [ProcessorStatusWord.Storage] = 
          [.N, .V, .brk, .ignored, .D, .I, .Z, .C]

        let sliceWidth = bounds.width / CGFloat(flags.count)

        for (i, flag) in flags.enumerated() {
            let rect = CGRect(x: bounds.origin.x + CGFloat(i) * sliceWidth,
                              y: bounds.origin.y,
                              width: sliceWidth,
                              height: bounds.height)
            if psw.isSet(flag) {
                NSColor.yellow.set()
            } else {
                NSColor.white.set()
            }
            rect.fill()

            let display = flag.displayString as NSString
            let size = display.size()
            let fudgeFactor = size.height - 3
            let textRect = CGRect(x: rect.origin.x + ((rect.width - size.width) / 2.0),
                                  y: rect.origin.y + ((rect.height - size.height) / 2.0) + fudgeFactor,
                                  width: size.width,
                                  height: size.height)
            
            display.draw(with: textRect)

            NSColor.black.set()
            rect.frame()
        }

        NSColor.black.set()
        bounds.frame()
    }

}
