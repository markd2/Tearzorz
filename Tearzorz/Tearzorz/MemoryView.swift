// MemoryView.swift - show memory

import Foundation
import Combine
import AppKit

class MemoryView: NSView {
    private var cancellable: AnyCancellable?
    private var memory: Memory!
    
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
