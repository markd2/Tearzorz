// StackView - not NSSnackView, but a view that shows the 6502 stack
//   Things that are above SP are black, things below grey meaning they'r
//   not accessible to the Pull (a.k.a. Pop) instructions.

import AppKit
import Combine

class StackView: NSView {

    private var cancellables = Set<AnyCancellable>()
    private var sp: Register<UInt8>!
    private var memory: Memory!

    private var highlightedAddress: UInt16?

    override var isFlipped: Bool {
        true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        cancellables.removeAll()
    }

    func bind(toSP sp: Register<UInt8>,
              memory: Memory) {
        self.sp = sp
        self.memory = memory

        self.sp.publisher
          .receive(on: RunLoop.main)
          .sink { value in
              self.clearHighlightIn(Constants.changeHighlightInterval)
              self.needsDisplay = true
          }
          .store(in: &cancellables)        

        self.memory.publisher
          .receive(on: RunLoop.main)
          .sink { notification in
              self.highlightedAddress = notification.address
              self.clearHighlightIn(Constants.changeHighlightInterval)
              self.needsDisplay = true
          }
          .store(in: &cancellables)        
    }

    func clearHighlightIn(_ seconds: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.highlightedAddress = nil
            self.needsDisplay = true
        }
    }

    let byteWidth = 25
    let byteHeight: CGFloat = 14

    func renderTwoBytes(_ thing1: UInt8, _ thing2: UInt8,
                        at y: CGFloat, drawLighter: Bool, drawHighlighted: Bool) {
        let string = String(format: "$01%02X: %02X", thing1, thing2) as NSString
        let rect = CGRect(x: 5, y: y,
                          width: bounds.width - 10, height: byteHeight)
        if drawHighlighted {
            Colors.changeHighlight.set()
            rect.fill()
        }

        let size = string.size()

        let textFontAttributes: [NSAttributedString.Key: Any] = [
          .foregroundColor: (drawLighter ? NSColor.gray : NSColor.black)
        ]

        string.draw(with: rect.sizeCenteredIn(size),
                    options: .usesLineFragmentOrigin,
                    attributes: textFontAttributes)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.set()
        bounds.fill()

        var y: CGFloat = 5
        var drawLighter = false

        NSColor.black.set()
        for address: UInt16 in stride(from: 0x01FF, through: 0x0100, by: -1) {
            let lowByte = UInt8(address & 0xFF)
            let drawHighlighted = address == highlightedAddress
            renderTwoBytes(lowByte, memory.byte(at: address),
                           at: y, drawLighter: drawLighter,
                           drawHighlighted: drawHighlighted)
            y += (byteHeight + 2.0)

            if (y + byteHeight) > bounds.height { break }

            if sp.value == lowByte {
                drawLighter = true
                NSColor.gray.set()
                let line = CGRect(x: 0, y: y - 2,
                                  width: bounds.width, height: 1)
                line.fill()
            }
        }
        
        NSColor.black.set()
        bounds.frame()
    }
}

