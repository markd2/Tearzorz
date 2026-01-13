// PSWView.swift - visualize the processor status longword,
//     react to it changes

import AppKit
import Combine

class PSWView: NSView {
    private var cancellable: AnyCancellable?
    var psw: ProcessorStatusWord! = nil

    var flags: [ProcessorStatusWord.Flags] = 
          [.N, .V, .brk, .ignored, .D, .I, .Z, .C]
    var hitRects: [CGRect] = []

    override var isFlipped: Bool {
        true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        cancellable?.cancel()
    }

    func bind(to psw: ProcessorStatusWord) {
        self.psw = psw
        cancellable = psw.publisher
        .receive(on: RunLoop.main)
        .sink { value in
            _ = value
            self.needsDisplay = true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let sliceWidth = bounds.width / CGFloat(flags.count)

        for i in 0 ..< flags.count {
            let rect = CGRect(x: bounds.origin.x + CGFloat(i) * sliceWidth,
                              y: bounds.origin.y,
                              width: sliceWidth,
                              height: bounds.height)
            hitRects.append(rect)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.set()
        bounds.fill()

        let flags: [ProcessorStatusWord.Flags] = 
          [.N, .V, .brk, .ignored, .D, .I, .Z, .C]

        for (i, flag) in flags.enumerated() {
            if psw.isSet(flag) {
                NSColor.yellow.set()
            } else {
                NSColor.white.set()
            }
            let rect = hitRects[i]
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

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)

        for (i, flag) in flags.enumerated() {
            if hitRects[i].contains(point) {
                psw.toggle(flag)
            }
        }
        
    }

}
