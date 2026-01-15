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
              self.highlightedAddress = 0x00 << 16 | UInt16(value)
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

    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.set()
        bounds.fill()
        
        NSColor.black.set()
        bounds.frame()
    }
}

