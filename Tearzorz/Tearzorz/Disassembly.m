#import "Disassembly.h"

/// Thanks to https://www.masswerk.at/6502/6502_instruction_set.html for deets!

@implementation Instruction

/// Number of bytes used for addressing. Does not include the byte
/// for the opcode.
- (NSInteger) bytesForMode: (AddressingMode) addressingMode {
    NSInteger bytes = 0;
    
    switch (addressingMode) {
    case Accumulator: bytes = 0; break;
    case Absolute: bytes = 2; break;
    case Absolute_XIndexed: bytes = 2; break;
    case Absolute_YIndexed: bytes = 2; break;
    case Immediate: bytes = 1; break;
    case Implied: bytes = 0; break;
    case Indirect: bytes = 2; break;
    case Indexed_Indirect_X: bytes = 1; break;
    case Indirect_Indexed_Y: bytes = 1; break;
    case Relative: bytes = 1; break;
    case ZeroPage: bytes = 1; break;
    case ZeroPage_XIndexed: bytes = 1; break;
    case ZeroPage_YIndexed: bytes = 1; break;
    }

    return bytes;
} // bytesForMode


- (instancetype) initWithOpcode: (Opcode) opcode
                 addressingMode: (AddressingMode) addressingMode
                          bytes: (unsigned char *) bytes {
    if (self = [super init]) {
        _opcode = opcode;
        _addressingMode = addressingMode;

        NSInteger count = [self bytesForMode: addressingMode];
        for (int i = 0; i < count + 1; i++) {
            bytes[i] = bytes[i];
        }
    }
    return self;
} // initWithOpcode


- (NSString *) humanReadableOpcodeFor: (Opcode) opcode {
    switch (opcode) {
    case ADC: return @"ADC";
    case AND: return @"AND";
    case ASL: return @"ASL";
    case BCC: return @"BCC";
    case BCS: return @"BCS";
    case BEQ: return @"BEQ";
    case BIT: return @"BIT";
    case BMI: return @"BMI";
    case BNE: return @"BNE";
    case BPL: return @"BPL";
    case BRK: return @"BRK";
    case BVC: return @"BVC";
    case BVS: return @"BVS";
    case CLC: return @"CLC";
    case CLD: return @"CLD";
    case CLI: return @"CLI";
    case CLV: return @"CLV";
    case CMP: return @"CMP";
    case CPX: return @"CPX";
    case CPY: return @"CPY";
    case DEC: return @"DEC";
    case DEX: return @"DEX";
    case DEY: return @"DEY";
    case EOR: return @"EOR";
    case INC: return @"INC";
    case INX: return @"INX";
    case INY: return @"INY";
    case JMP: return @"JMP";
    case JSR: return @"JSR";
    case LDA: return @"LDA";
    case LDX: return @"LDX";
    case LDY: return @"LDY";
    case LSR: return @"LSR";
    case NOP: return @"NOP";
    case ORA: return @"ORA";
    case PHA: return @"PHA";
    case PHP: return @"PHP";
    case PLA: return @"PLA";
    case PLP: return @"PLP";
    case ROL: return @"ROL";
    case ROR: return @"ROR";
    case RTI: return @"RTI";
    case RTS: return @"RTS";
    case SBC: return @"SBC";
    case SEC: return @"SEC";
    case SED: return @"SED";
    case SEI: return @"SEI";
    case STA: return @"STA";
    case STX: return @"STX";
    case STY: return @"STY";
    case TAX: return @"TAX";
    case TAY: return @"TAY";
    case TSX: return @"TSX";
    case TXA: return @"TXA";
    case TXS: return @"TXS";
    case TYA: return @"TYA";
    }
} // humanReadableOpcode


- (NSString *) description {
    NSString *description = [NSString stringWithFormat: @"%@", [self humanReadableOpcodeFor: self.opcode]];
    return description;
} // description

@end // Instruction


@implementation Disassembly

- (Instruction *) makeInstructionFrom: (unsigned char **)scan
                           opcode: (Opcode) opcode
                             mode: (AddressingMode) mode {
    Instruction *instruction =
        [[Instruction alloc] initWithOpcode: opcode
                             addressingMode: mode
                                      bytes: *scan];
    scan += (1 + [instruction bytesForMode: mode]);

    return instruction;
} // makeInstructionFrom


- (NSArray<Instruction *> *) disassembleFrom: (unsigned char *) address  length: (NSInteger) length {
    NSMutableArray *instructions = NSMutableArray.new;
    Instruction *instruction;

    unsigned char *scan = address;
    unsigned char *stop = address + length;
    
    while (scan < stop) {

        switch (*scan) {
        case 0x00: instruction = [self makeInstructionFrom: &scan  opcode: BRK  mode: Implied]; break;
        case 0x01: instruction = [self makeInstructionFrom: &scan  opcode: ORA  mode: Indexed_Indirect_X]; break;
        case 0x05: instruction = [self makeInstructionFrom: &scan  opcode: ORA  mode: ZeroPage]; break;
        case 0x06: instruction = [self makeInstructionFrom: &scan  opcode: ASL  mode: ZeroPage]; break;
        case 0x08: instruction = [self makeInstructionFrom: &scan  opcode: PHP  mode: Implied]; break;
        case 0x09: instruction = [self makeInstructionFrom: &scan  opcode: ORA  mode: Immediate]; break;
        case 0x0A: instruction = [self makeInstructionFrom: &scan  opcode: ASL  mode: Accumulator]; break;
        case 0x0D: instruction = [self makeInstructionFrom: &scan  opcode: ORA  mode: Absolute]; break;
        case 0x0E: instruction = [self makeInstructionFrom: &scan  opcode: ASL  mode: Absolute]; break;
        case 0x10: instruction = [self makeInstructionFrom: &scan  opcode: BPL  mode: Relative]; break;
        case 0x11: instruction = [self makeInstructionFrom: &scan  opcode: ORA  mode: Indirect_Indexed_Y]; break;
        case 0x15: instruction = [self makeInstructionFrom: &scan  opcode: ORA  mode: ZeroPage_XIndexed]; break;
        case 0x16: instruction = [self makeInstructionFrom: &scan  opcode: ASL  mode: ZeroPage_XIndexed]; break;
        case 0x18: instruction = [self makeInstructionFrom: &scan  opcode: CLC  mode: Implied]; break;
        case 0x19: instruction = [self makeInstructionFrom: &scan  opcode: ORA  mode: Absolute_YIndexed]; break;
        case 0x1D: instruction = [self makeInstructionFrom: &scan  opcode: ORA  mode: Absolute_XIndexed]; break;
        case 0x1E: instruction = [self makeInstructionFrom: &scan  opcode: ASL  mode: Absolute_XIndexed]; break;
        case 0x20: instruction = [self makeInstructionFrom: &scan  opcode: JSR  mode: Absolute]; break;
        case 0x21: instruction = [self makeInstructionFrom: &scan  opcode: AND  mode: Indexed_Indirect_X]; break;
        case 0x24: instruction = [self makeInstructionFrom: &scan  opcode: BIT  mode: ZeroPage]; break;
        case 0x25: instruction = [self makeInstructionFrom: &scan  opcode: AND  mode: ZeroPage]; break;
        case 0x26: instruction = [self makeInstructionFrom: &scan  opcode: ROL  mode: ZeroPage]; break;
        case 0x28: instruction = [self makeInstructionFrom: &scan  opcode: PLP  mode: Implied]; break;
        case 0x29: instruction = [self makeInstructionFrom: &scan  opcode: AND  mode: Immediate]; break;
        case 0x2A: instruction = [self makeInstructionFrom: &scan  opcode: ROL  mode: Accumulator]; break;
        case 0x2C: instruction = [self makeInstructionFrom: &scan  opcode: BIT  mode: Absolute]; break;
        case 0x2D: instruction = [self makeInstructionFrom: &scan  opcode: AND  mode: Absolute]; break;
        case 0x2E: instruction = [self makeInstructionFrom: &scan  opcode: ROL  mode: Absolute]; break;
        case 0x30: instruction = [self makeInstructionFrom: &scan  opcode: BMI  mode: Relative]; break;
        case 0x31: instruction = [self makeInstructionFrom: &scan  opcode: AND  mode: Indirect_Indexed_Y]; break;
        case 0x35: instruction = [self makeInstructionFrom: &scan  opcode: AND  mode: ZeroPage_XIndexed]; break;
        case 0x36: instruction = [self makeInstructionFrom: &scan  opcode: ROL  mode: ZeroPage_XIndexed]; break;
        case 0x38: instruction = [self makeInstructionFrom: &scan  opcode: SEC  mode: Implied]; break;
        case 0x39: instruction = [self makeInstructionFrom: &scan  opcode: AND  mode: Absolute_YIndexed]; break;
        case 0x3D: instruction = [self makeInstructionFrom: &scan  opcode: AND  mode: Absolute_XIndexed]; break;
        case 0x3E: instruction = [self makeInstructionFrom: &scan  opcode: ROL  mode: Absolute_XIndexed]; break;
        case 0x40: instruction = [self makeInstructionFrom: &scan  opcode: RTI  mode: Implied]; break;
        case 0x41: instruction = [self makeInstructionFrom: &scan  opcode: EOR  mode: Indexed_Indirect_X]; break;
        case 0x45: instruction = [self makeInstructionFrom: &scan  opcode: EOR  mode: ZeroPage]; break;
        case 0x46: instruction = [self makeInstructionFrom: &scan  opcode: LSR  mode: ZeroPage]; break;
        case 0x48: instruction = [self makeInstructionFrom: &scan  opcode: PHA  mode: Implied]; break;
        case 0x49: instruction = [self makeInstructionFrom: &scan  opcode: EOR  mode: Immediate]; break;
        case 0x4A: instruction = [self makeInstructionFrom: &scan  opcode: LSR  mode: Accumulator]; break;
        case 0x4C: instruction = [self makeInstructionFrom: &scan  opcode: JMP  mode: Absolute]; break;
        case 0x4D: instruction = [self makeInstructionFrom: &scan  opcode: EOR  mode: Absolute]; break;
        case 0x4E: instruction = [self makeInstructionFrom: &scan  opcode: LSR  mode: Absolute]; break;
        case 0x50: instruction = [self makeInstructionFrom: &scan  opcode: BVC  mode: Relative]; break;
        case 0x51: instruction = [self makeInstructionFrom: &scan  opcode: EOR  mode: Indirect_Indexed_Y]; break;
        case 0x55: instruction = [self makeInstructionFrom: &scan  opcode: EOR  mode: ZeroPage_XIndexed]; break;
        case 0x56: instruction = [self makeInstructionFrom: &scan  opcode: LSR  mode: ZeroPage_XIndexed]; break;
        case 0x58: instruction = [self makeInstructionFrom: &scan  opcode: CLI  mode: Implied]; break;
        case 0x59: instruction = [self makeInstructionFrom: &scan  opcode: EOR  mode: Absolute_YIndexed]; break;
        case 0x5D: instruction = [self makeInstructionFrom: &scan  opcode: EOR  mode: Absolute_XIndexed]; break;
        case 0x5E: instruction = [self makeInstructionFrom: &scan  opcode: LSR  mode: Absolute_XIndexed]; break;
        case 0x60: instruction = [self makeInstructionFrom: &scan  opcode: RTS  mode: Implied]; break;
        case 0x61: instruction = [self makeInstructionFrom: &scan  opcode: ADC  mode: Indexed_Indirect_X]; break;
        case 0x65: instruction = [self makeInstructionFrom: &scan  opcode: ADC  mode: ZeroPage]; break;
        case 0x66: instruction = [self makeInstructionFrom: &scan  opcode: ROR  mode: ZeroPage]; break;
        case 0x68: instruction = [self makeInstructionFrom: &scan  opcode: PLA  mode: Implied]; break;
        case 0x69: instruction = [self makeInstructionFrom: &scan  opcode: ADC  mode: Immediate]; break;
        case 0x6A: instruction = [self makeInstructionFrom: &scan  opcode: ROR  mode: Accumulator]; break;
        case 0x6C: instruction = [self makeInstructionFrom: &scan  opcode: JMP  mode: Indirect]; break;
        case 0x6D: instruction = [self makeInstructionFrom: &scan  opcode: ADC  mode: Absolute]; break;
        case 0x6E: instruction = [self makeInstructionFrom: &scan  opcode: ROR  mode: Absolute]; break;
        case 0x70: instruction = [self makeInstructionFrom: &scan  opcode: BVS  mode: Relative]; break;
        case 0x71: instruction = [self makeInstructionFrom: &scan  opcode: ADC  mode: Indirect_Indexed_Y]; break;
        case 0x75: instruction = [self makeInstructionFrom: &scan  opcode: ADC  mode: ZeroPage_XIndexed]; break;
        case 0x76: instruction = [self makeInstructionFrom: &scan  opcode: ROR  mode: ZeroPage_XIndexed]; break;
        case 0x78: instruction = [self makeInstructionFrom: &scan  opcode: SEI  mode: Implied]; break;
        case 0x79: instruction = [self makeInstructionFrom: &scan  opcode: ADC  mode: Absolute_YIndexed]; break;
        case 0x7D: instruction = [self makeInstructionFrom: &scan  opcode: ADC  mode: Absolute_XIndexed]; break;
        case 0x7E: instruction = [self makeInstructionFrom: &scan  opcode: ROR  mode: Absolute_XIndexed]; break;
        case 0x81: instruction = [self makeInstructionFrom: &scan  opcode: STA  mode: Indexed_Indirect_X]; break;
        case 0x84: instruction = [self makeInstructionFrom: &scan  opcode: STY  mode: ZeroPage]; break;
        case 0x85: instruction = [self makeInstructionFrom: &scan  opcode: STA  mode: ZeroPage]; break;
        case 0x86: instruction = [self makeInstructionFrom: &scan  opcode: STX  mode: ZeroPage]; break;
        case 0x88: instruction = [self makeInstructionFrom: &scan  opcode: DEY  mode: Implied]; break;
        case 0x8A: instruction = [self makeInstructionFrom: &scan  opcode: TXA  mode: Implied]; break;
        case 0x8C: instruction = [self makeInstructionFrom: &scan  opcode: STY  mode: Absolute]; break;
        case 0x8D: instruction = [self makeInstructionFrom: &scan  opcode: STA  mode: Absolute]; break;
        case 0x8E: instruction = [self makeInstructionFrom: &scan  opcode: STX  mode: Absolute]; break;
        case 0x90: instruction = [self makeInstructionFrom: &scan  opcode: BCC  mode: Relative]; break;
        case 0x91: instruction = [self makeInstructionFrom: &scan  opcode: STA  mode: Indirect_Indexed_Y]; break;
        case 0x94: instruction = [self makeInstructionFrom: &scan  opcode: STY  mode: ZeroPage_XIndexed]; break;
        case 0x95: instruction = [self makeInstructionFrom: &scan  opcode: STA  mode: ZeroPage_XIndexed]; break;
        case 0x96: instruction = [self makeInstructionFrom: &scan  opcode: STX  mode: ZeroPage_YIndexed]; break;
        case 0x98: instruction = [self makeInstructionFrom: &scan  opcode: TYA  mode: Implied]; break;
        case 0x99: instruction = [self makeInstructionFrom: &scan  opcode: STA  mode: Absolute_YIndexed]; break;
        case 0x9A: instruction = [self makeInstructionFrom: &scan  opcode: TXS  mode: Implied]; break;
        case 0x9D: instruction = [self makeInstructionFrom: &scan  opcode: STA  mode: Absolute_XIndexed]; break;
        case 0xA0: instruction = [self makeInstructionFrom: &scan  opcode: LDY  mode: Immediate]; break;
        case 0xA1: instruction = [self makeInstructionFrom: &scan  opcode: LDA  mode: Indexed_Indirect_X]; break;
        case 0xA2: instruction = [self makeInstructionFrom: &scan  opcode: LDX  mode: Immediate]; break;
        case 0xA4: instruction = [self makeInstructionFrom: &scan  opcode: LDY  mode: ZeroPage]; break;
        case 0xA5: instruction = [self makeInstructionFrom: &scan  opcode: LDA  mode: ZeroPage]; break;
        case 0xA6: instruction = [self makeInstructionFrom: &scan  opcode: LDX  mode: ZeroPage]; break;
        case 0xA8: instruction = [self makeInstructionFrom: &scan  opcode: TAY  mode: Implied]; break;
        case 0xA9: instruction = [self makeInstructionFrom: &scan  opcode: LDA  mode: Immediate]; break;
        case 0xAA: instruction = [self makeInstructionFrom: &scan  opcode: TAX  mode: Implied]; break;
        case 0xAC: instruction = [self makeInstructionFrom: &scan  opcode: LDY  mode: Absolute]; break;
        case 0xAD: instruction = [self makeInstructionFrom: &scan  opcode: LDA  mode: Absolute]; break;
        case 0xAE: instruction = [self makeInstructionFrom: &scan  opcode: LDX  mode: Absolute]; break;
        case 0xB0: instruction = [self makeInstructionFrom: &scan  opcode: BCS  mode: Relative]; break;
        case 0xB1: instruction = [self makeInstructionFrom: &scan  opcode: LDA  mode: Indirect_Indexed_Y]; break;
        case 0xB4: instruction = [self makeInstructionFrom: &scan  opcode: LDY  mode: ZeroPage_XIndexed]; break;
        case 0xB5: instruction = [self makeInstructionFrom: &scan  opcode: LDA  mode: ZeroPage_XIndexed]; break;
        case 0xB6: instruction = [self makeInstructionFrom: &scan  opcode: LDX  mode: ZeroPage_YIndexed]; break;
        case 0xB8: instruction = [self makeInstructionFrom: &scan  opcode: CLV  mode: Implied]; break;
        case 0xB9: instruction = [self makeInstructionFrom: &scan  opcode: LDA  mode: Absolute_YIndexed]; break;
        case 0xBA: instruction = [self makeInstructionFrom: &scan  opcode: TSX  mode: Implied]; break;
        case 0xBC: instruction = [self makeInstructionFrom: &scan  opcode: LDY  mode: Absolute_XIndexed]; break;
        case 0xBD: instruction = [self makeInstructionFrom: &scan  opcode: LDA  mode: Absolute_XIndexed]; break;
        case 0xBE: instruction = [self makeInstructionFrom: &scan  opcode: LDX  mode: Absolute_YIndexed]; break;
        case 0xC0: instruction = [self makeInstructionFrom: &scan  opcode: CPY  mode: Immediate]; break;
        case 0xC1: instruction = [self makeInstructionFrom: &scan  opcode: CMP  mode: Indexed_Indirect_X]; break;
        case 0xC4: instruction = [self makeInstructionFrom: &scan  opcode: CPY  mode: ZeroPage]; break;
        case 0xC5: instruction = [self makeInstructionFrom: &scan  opcode: CMP  mode: ZeroPage]; break;
        case 0xC6: instruction = [self makeInstructionFrom: &scan  opcode: DEC  mode: ZeroPage]; break;
        case 0xC8: instruction = [self makeInstructionFrom: &scan  opcode: INY  mode: Implied]; break;
        case 0xC9: instruction = [self makeInstructionFrom: &scan  opcode: CMP  mode: Immediate]; break;
        case 0xCA: instruction = [self makeInstructionFrom: &scan  opcode: DEX  mode: Implied]; break;
        case 0xCC: instruction = [self makeInstructionFrom: &scan  opcode: CPY  mode: Absolute]; break;
        case 0xCD: instruction = [self makeInstructionFrom: &scan  opcode: CMP  mode: Absolute]; break;
        case 0xCE: instruction = [self makeInstructionFrom: &scan  opcode: DEC  mode: Absolute]; break;
        case 0xD0: instruction = [self makeInstructionFrom: &scan  opcode: BNE  mode: Relative]; break;
        case 0xD1: instruction = [self makeInstructionFrom: &scan  opcode: CMP  mode: Indirect_Indexed_Y]; break;
        case 0xD5: instruction = [self makeInstructionFrom: &scan  opcode: CMP  mode: ZeroPage_XIndexed]; break;
        case 0xD6: instruction = [self makeInstructionFrom: &scan  opcode: DEC  mode: ZeroPage_XIndexed]; break;
        case 0xD8: instruction = [self makeInstructionFrom: &scan  opcode: CLD  mode: Implied]; break;
        case 0xD9: instruction = [self makeInstructionFrom: &scan  opcode: CMP  mode: Absolute_YIndexed]; break;
        case 0xDD: instruction = [self makeInstructionFrom: &scan  opcode: CMP  mode: Absolute_XIndexed]; break;
        case 0xDE: instruction = [self makeInstructionFrom: &scan  opcode: DEC  mode: Absolute_XIndexed]; break;
        case 0xE0: instruction = [self makeInstructionFrom: &scan  opcode: CPX  mode: Immediate]; break;
        case 0xE1: instruction = [self makeInstructionFrom: &scan  opcode: SBC  mode: Indexed_Indirect_X]; break;
        case 0xE4: instruction = [self makeInstructionFrom: &scan  opcode: CPX  mode: ZeroPage]; break;
        case 0xE5: instruction = [self makeInstructionFrom: &scan  opcode: SBC  mode: ZeroPage]; break;
        case 0xE6: instruction = [self makeInstructionFrom: &scan  opcode: INC  mode: ZeroPage]; break;
        case 0xE8: instruction = [self makeInstructionFrom: &scan  opcode: INX  mode: Implied]; break;
        case 0xE9: instruction = [self makeInstructionFrom: &scan  opcode: SBC  mode: Immediate]; break;
        case 0xEA: instruction = [self makeInstructionFrom: &scan  opcode: NOP  mode: Implied]; break;
        case 0xEC: instruction = [self makeInstructionFrom: &scan  opcode: CPX  mode: Absolute]; break;
        case 0xED: instruction = [self makeInstructionFrom: &scan  opcode: SBC  mode: Absolute]; break;
        case 0xEE: instruction = [self makeInstructionFrom: &scan  opcode: INC  mode: Absolute]; break;
        case 0xF0: instruction = [self makeInstructionFrom: &scan  opcode: BEQ  mode: Relative]; break;
        case 0xF1: instruction = [self makeInstructionFrom: &scan  opcode: SBC  mode: Indirect_Indexed_Y]; break;
        case 0xF5: instruction = [self makeInstructionFrom: &scan  opcode: SBC  mode: ZeroPage_XIndexed]; break;
        case 0xF6: instruction = [self makeInstructionFrom: &scan  opcode: INC  mode: ZeroPage_XIndexed]; break;
        case 0xF8: instruction = [self makeInstructionFrom: &scan  opcode: SED  mode: Implied]; break;
        case 0xF9: instruction = [self makeInstructionFrom: &scan  opcode: SBC  mode: Absolute_YIndexed]; break;
        case 0xFD: instruction = [self makeInstructionFrom: &scan  opcode: SBC  mode: Absolute_XIndexed]; break;
        case 0xFE: instruction = [self makeInstructionFrom: &scan  opcode: INC  mode: Absolute_XIndexed]; break;
        }
    }

    return instructions;
} // Disassemble

@end // Disassembly
