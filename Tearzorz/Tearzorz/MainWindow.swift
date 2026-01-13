// MainWindow.swift - the single window shown by the app, until we get
//    more windows involved via NSWindowController, or whatnot

import Cocoa

class MainWindow: NSWindow {
    let cpu: MOS6502 = MOS6502()

    @IBOutlet var accumulatorView: RegisterView! = nil
    @IBOutlet var xView: RegisterView! = nil
    @IBOutlet var yView: RegisterView! = nil
    @IBOutlet var spView: RegisterView! = nil
    @IBOutlet var pswView: PSWView! = nil
    @IBOutlet var memoryView: MemoryView! = nil

    @IBOutlet var tableView: NSTableView! = nil
    var instructions: [Instruction] = []
    
    override func awakeFromNib() {
        accumulatorView.bind(to: cpu.accumulator)
        xView.bind(to: cpu.Xregister)
        yView.bind(to: cpu.Yregister)
        spView.bind(to: cpu.stackPointer)

        pswView.bind(to: cpu.psw)
        memoryView.bind(to: cpu.memory)

        // populate the tableview
        loadSomeCode()
    }

    @IBAction func changeRegisters(_ sender: NSButton) {
        cpu.accumulator.value = UInt8.random(in: 0...255)
        cpu.Xregister.value = (cpu.Xregister.value + 2) % 127
        cpu.Yregister.value = (cpu.Yregister.value + 3) % 127
        cpu.stackPointer.value = (cpu.stackPointer.value + 2)
    }

    @IBAction func changePSW(_ sender: NSButton) {
        cpu.psw.setFlag(.Z)
        cpu.psw.setFlag(.N)
        pswView.needsDisplay = true
    }

    @IBAction func runSelectedInstruction(_ sender: NSButton) {
        let row = tableView.selectedRow
        guard row >= 0 else { return }

        let instruction = instructions[row]
        cpu.execute(instruction)
    }

    func loadSomeCode() {
//        let bytes = kim1bytes()
        let bytes = allAddressingModesBytes()

        let dis = Disassembly()
        instructions = dis.disassemble(bytes)!

//        for ins in instructions {
//            Swift.print("    ", ins)
//        }
        tableView.reloadData()
    }

    @IBAction func loadSomeCode(_ sender: NSButton) {
        loadSomeCode()
    }

    func kim1bytes() -> Data {
        let kim1bytes: [CUnsignedChar] = [
            0x18,
            0xA5, 0x00,
            0x65, 0x01,
            0x85, 0xFA,
            0xA9, 0x00,
            0x85, 0xFB,
            0x4C, 0x4F, 0x1C
        ]
        let data = Data(kim1bytes)
        return data
    }

    func allAddressingModesBytes() -> Data {
        // courtesy of our robot overlords
        /*
        0800: 78          ; SEI
        0801: 18          ; CLC
        0802: A9 10       ; LDA #$10
        0804: 69 05       ; ADC #$05
        0806: C9 20       ; CMP #$20
        0808: 0A          ; ASL A
        0809: 2A          ; ROL A
        080A: 85 00       ; STA $00
        080C: A5 00       ; LDA $00
        080E: A2 04       ; LDX #$04
        0810: A0 08       ; LDY #$08
        0812: 95 10       ; STA $10,X
        0814: B5 10       ; LDA $10,X
        0816: 84 20       ; STY $20
        0818: B6 20       ; LDX $20,Y
        081A: AD 34 12    ; LDA $1234
        081D: 8D 35 12    ; STA $1235
        0820: BD 00 20    ; LDA $2000,X
        0823: 9D 01 20    ; STA $2001,X
        0826: B9 00 30    ; LDA $3000,Y
        0829: 99 01 30    ; STA $3001,Y
        082C: A1 40       ; LDA ($40,X)
        082E: B1 50       ; LDA ($50),Y
        0830: F0 01       ; BEQ branch1
        0832: EA          ; NOP
        0833: D0 01       ; BNE branch2
        0835: EA          ; NOP
        0836: 6C 00 09    ; JMP ($0900)
        0839: 60          ; RTS
        */
        let blah: [CUnsignedChar] = [
          0x78, 0x18, 0xA9, 0x10, 0x69, 0x05, 0xC9, 0x20, 0x0A, 0x2A, 0x85, 0x00, 0xA5, 0x00, 0xA2, 0x04,
          0xA0, 0x08, 0x95, 0x10, 0xB5, 0x10, 0x84, 0x20, 0xB6, 0x20, 0xAD, 0x34, 0x12, 0x8D, 0x35, 0x12,
          0xBD, 0x00, 0x20, 0x9D, 0x01, 0x20, 0xB9, 0x00, 0x30, 0x99, 0x01, 0x30, 0xA1, 0x40, 0xB1, 0x50,
          0xF0, 0x01, 0xEA, 0xD0, 0x01, 0xEA, 0x6C, 0x00, 0x09, 0x60
        ]

        return Data(blah)
    }

    @IBAction func splunge(_ sender: NSButton) {
        let dis = Disassembly()
        
        let blah = dis.disassemble(kim1bytes())!
        
        for ins in blah {
            Swift.print("    ", ins)
        }


        let blah2 = dis.disassemble(allAddressingModesBytes())!
        
        for ins in blah2 {
            Swift.print("    ", ins)
        }

    }
}

extension MainWindow: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        instructions.count
    }

    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        guard let column = tableColumn else {
            print("nil column")
            return nil
        }
        
        let instruction = instructions[row]

        switch column.identifier.rawValue {
            case "iconColumn":
                return nil
                /*
                let cell = tableView.makeView(
                  withIdentifier: column.identifier,
                  owner: self
                ) as? NSTableCellView
                cell?.imageView?.image = item.isOn ? onImage : offImage
                return cell
                 */
            case "textColumn":
                let cell = tableView.makeView(
                  withIdentifier: column.identifier,
                  owner: self
                ) as? NSTableCellView
                cell?.textField?.stringValue = instruction.description
                return cell

            default:
                print("huh, identifier \(column.identifier)")
                return nil
        }
    }
}
