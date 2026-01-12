//
//  AppDelegate.swift
//  Tearzorz
//
//  Created by MarkD on 1/11/26.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
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
        Swift.print(blah)
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

