//
//  MainWindow.swift
//  Tearzorz
//
//  Created by MarkD on 1/11/26.
//

import Cocoa

class MainWindow: NSWindow {

    @IBAction func splunge(_ sender: NSButton) {
        let dis = Disassembly()
        
        let bytes: [CUnsignedChar] = [
            0x18,
            0xA5, 0x00,
            0x65, 0x01,
            0x85, 0xFA,
            0xA9, 0x00,
            0x85, 0xFB,
            0x4C, 0x4F, 0x1C
        ]
        
        let blah = dis.disassemble(Data(bytes))!
        
        for ins in blah {
            Swift.print("    ", ins)
        }
    }

}
