// TearingWindowController.swift - the primary tearing interface

import Cocoa

class TearingWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        do {
            try bootstrapWithKim1File()
        } catch {
            Swift.print("oh noes: \(error)")
        }
    }

    func bootstrapWithKim1File() throws {
        let kim1tapeURL = Bundle.main.url(forResource: "farmer-brown",
                                          withExtension: "txt")!
        let kim1tapeBytes = try String(contentsOf: kim1tapeURL,
                                   encoding: .utf8)
        let parser = MOSFileParser(withContents: kim1tapeBytes)
        let (baseAddress, bytes) = try parser.parse()
        Swift.print(baseAddress, bytes)
    }
    
}
