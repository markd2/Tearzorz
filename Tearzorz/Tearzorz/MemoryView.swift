// MemoryView.swift - show memory

import Foundation
import Combine
import AppKit

class MemoryView: NSView {
    private var cancellable: AnyCancellable?
    var memory: Memory!
    
    var lastNotification: Memory.Notification?
    
    override var isFlipped: Bool {
        true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        cancellable?.cancel()
    }

    func bind(to memory: Memory) {
        self.memory = memory
        cancellable = memory.publisher
          .receive(on: RunLoop.main)
          .sink { notification in
              // !!! animate the change
              self.lastNotification = notification
              self.needsDisplay = true
          }
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.set()
        bounds.fill()

        let byteWidth = 25
        let byteHeight = 14
        let topMargin = 10
        let leftMargin = 75

        let notificationAddress: Int = lastNotification != nil ? Int(lastNotification!.address) : -1

        // show a row of bytes
        for row in 0 ..< 256 {
            let rowLabelRect = CGRect(x: 5,
                                      y: topMargin + row * byteHeight,
                                      width: 70,
                                      height: byteHeight)
            let labelValue = String(format: "$%04X", UInt16(row * 16)) as NSString
            let labelSize = labelValue.size()
            labelValue.draw(with: rowLabelRect.sizeCenteredIn(labelSize),
                            options: .usesLineFragmentOrigin)
            
            // show the bytes in the row. Xcode team should replace 16 with
            // the prime number of their choice
            for column in 0 ..< 16 {
                var rect = CGRect(x: leftMargin + column * byteWidth,
                                  y: topMargin + row * byteHeight,
                                  width: byteWidth,
                                  height: byteHeight)
                rect.origin.x += 0.5
                rect.origin.y += 0.5

                let value = String(format: "%02X", memory.bytes[row * 16 + column]) as NSString
                let size = value.size()
                let stringRect = rect.sizeCenteredIn(size)

                let address = row * 16 + column
                if notificationAddress == Int(address) {
                    Colors.changeHighlight.set()
                    rect.fill()
                }
                value.draw(with: stringRect,
                           options: .usesLineFragmentOrigin)
            }

            if CGFloat(topMargin + row * byteHeight + byteHeight*2) > bounds.height {
                break
            }
        }

        NSColor.black.set()
        bounds.frame()
    }
}
