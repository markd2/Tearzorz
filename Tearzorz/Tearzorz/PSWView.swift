// PSWView.swift - visualize the processor status longword,
//     react to it changes

import AppKit
import Combine

class PSWView: NSView {
    private var cancellable: AnyCancellable?
    private var psw: ProcessorStatusWord! = nil

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

        NSColor.black.set()
        bounds.frame()
    }

}
