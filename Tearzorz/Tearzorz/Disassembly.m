#import "Disassembly.h"

@implementation Instruction
@end // Instruction

@implementation Disassembly


Instruction *makeInstruction(unsigned char **scan, Opcode opcode, AddressingMode mode) {
    return nil;
} // makeInstruction


- (NSArray<Instruction *> *) disassemble {
    NSMutableArray *instructions = NSMutableArray.new;
    Instruction *instruction;

    unsigned char *scan = NULL;

    switch (*scan) {
    case 0x00: instruction = makeInstruction(&scan, BRK, Implied); break;
    case 0x01: instruction = makeInstruction(&scan, ORA, XIndexed_Indirect); break;
    case 0x05: instruction = makeInstruction(&scan, ORA, ZeroPage); break;
    case 0x06: instruction = makeInstruction(&scan, ASL, ZeroPage); break;
    case 0x08: instruction = makeInstruction(&scan, PHP, Implied); break;
    case 0x09: instruction = makeInstruction(&scan, ORA, Immediate); break;
    case 0x0A: instruction = makeInstruction(&scan, ASL, Accumulator); break;
    case 0x0D: instruction = makeInstruction(&scan, ORA, Absolute); break;
    case 0x0E: instruction = makeInstruction(&scan, ASL, Absolute); break;
    case 0x10: instruction = makeInstruction(&scan, BPL, Relative); break;
    case 0x11: instruction = makeInstruction(&scan, ORA, Indirect_YIndexed); break;
    case 0x15: instruction = makeInstruction(&scan, ORA, ZeroPage_XIndexed); break;
    case 0x16: instruction = makeInstruction(&scan, ASL, ZeroPage_XIndexed); break;
    case 0x18: instruction = makeInstruction(&scan, CLC, Implied); break;
    case 0x19: instruction = makeInstruction(&scan, ORA, Absolute_YIndexed); break;
    case 0x1D: instruction = makeInstruction(&scan, ORA, Absolute_XIndexed); break;
    case 0x1E: instruction = makeInstruction(&scan, ASL, Absolute_XIndexed); break;
    case 0x20: instruction = makeInstruction(&scan, JSR, Absolute); break;
    case 0x21: instruction = makeInstruction(&scan, AND, XIndexed_Indirect); break;
    case 0x24: instruction = makeInstruction(&scan, BIT, ZeroPage); break;
    case 0x25: instruction = makeInstruction(&scan, AND, ZeroPage); break;
    case 0x26: instruction = makeInstruction(&scan, ROL, ZeroPage); break;
    case 0x28: instruction = makeInstruction(&scan, PLP, Implied); break;
    case 0x29: instruction = makeInstruction(&scan, AND, Immediate); break;
    case 0x2A: instruction = makeInstruction(&scan, ROL, Accumulator); break;
    case 0x2C: instruction = makeInstruction(&scan, BIT, Absolute); break;
    case 0x2D: instruction = makeInstruction(&scan, AND, Absolute); break;
    case 0x2E: instruction = makeInstruction(&scan, ROL, Absolute); break;
    case 0x30: instruction = makeInstruction(&scan, BMI, Relative); break;
    case 0x31: instruction = makeInstruction(&scan, AND, Indirect_YIndexed); break;
    case 0x35: instruction = makeInstruction(&scan, AND, ZeroPage_XIndexed); break;
    case 0x36: instruction = makeInstruction(&scan, ROL, ZeroPage_XIndexed); break;
    case 0x38: instruction = makeInstruction(&scan, SEC, Implied); break;
    case 0x39: instruction = makeInstruction(&scan, AND, Absolute_YIndexed); break;
    case 0x3D: instruction = makeInstruction(&scan, AND, Absolute_XIndexed); break;
    case 0x3E: instruction = makeInstruction(&scan, ROL, Absolute_XIndexed); break;
    case 0x40: instruction = makeInstruction(&scan, RTI, Implied); break;
    case 0x41: instruction = makeInstruction(&scan, EOR, XIndexed_Indirect); break;
    case 0x45: instruction = makeInstruction(&scan, EOR, ZeroPage); break;
    case 0x46: instruction = makeInstruction(&scan, LSR, ZeroPage); break;
    case 0x48: instruction = makeInstruction(&scan, PHA, Implied); break;
    case 0x49: instruction = makeInstruction(&scan, EOR, Immediate); break;
    case 0x4A: instruction = makeInstruction(&scan, LSR, Accumulator); break;
    case 0x4C: instruction = makeInstruction(&scan, JMP, Absolute); break;
    case 0x4D: instruction = makeInstruction(&scan, EOR, Absolute); break;
    case 0x4E: instruction = makeInstruction(&scan, LSR, Absolute); break;
    case 0x50: instruction = makeInstruction(&scan, BVC, Relative); break;
    case 0x51: instruction = makeInstruction(&scan, EOR, Indirect_YIndexed); break;
    case 0x55: instruction = makeInstruction(&scan, EOR, ZeroPage_XIndexed); break;
    case 0x56: instruction = makeInstruction(&scan, LSR, ZeroPage_XIndexed); break;
    case 0x58: instruction = makeInstruction(&scan, CLI, Implied); break;
    case 0x59: instruction = makeInstruction(&scan, EOR, Absolute_YIndexed); break;
    case 0x5D: instruction = makeInstruction(&scan, EOR, Absolute_XIndexed); break;
    case 0x5E: instruction = makeInstruction(&scan, LSR, Absolute_XIndexed); break;
    case 0x60: instruction = makeInstruction(&scan, RTS, Implied); break;
    case 0x61: instruction = makeInstruction(&scan, ADC, XIndexed_Indirect); break;
    case 0x65: instruction = makeInstruction(&scan, ADC, ZeroPage); break;
    case 0x66: instruction = makeInstruction(&scan, ROR, ZeroPage); break;
    case 0x68: instruction = makeInstruction(&scan, PLA, Implied); break;
    case 0x69: instruction = makeInstruction(&scan, ADC, Immediate); break;
    case 0x6A: instruction = makeInstruction(&scan, ROR, Accumulator); break;
    case 0x6C: instruction = makeInstruction(&scan, JMP, Indirect); break;
    case 0x6D: instruction = makeInstruction(&scan, ADC, Absolute); break;
    case 0x6E: instruction = makeInstruction(&scan, ROR, Absolute); break;
    case 0x70: instruction = makeInstruction(&scan, BVS, Relative); break;
    case 0x71: instruction = makeInstruction(&scan, ADC, Indirect_YIndexed); break;
    case 0x75: instruction = makeInstruction(&scan, ADC, ZeroPage_XIndexed); break;
    case 0x76: instruction = makeInstruction(&scan, ROR, ZeroPage_XIndexed); break;
    case 0x78: instruction = makeInstruction(&scan, SEI, Implied); break;
    case 0x79: instruction = makeInstruction(&scan, ADC, Absolute_YIndexed); break;
    case 0x7D: instruction = makeInstruction(&scan, ADC, Absolute_XIndexed); break;
    case 0x7E: instruction = makeInstruction(&scan, ROR, Absolute_XIndexed); break;
    case 0x81: instruction = makeInstruction(&scan, STA, XIndexed_Indirect); break;
    case 0x84: instruction = makeInstruction(&scan, STY, ZeroPage); break;
    case 0x85: instruction = makeInstruction(&scan, STA, ZeroPage); break;
    case 0x86: instruction = makeInstruction(&scan, STX, ZeroPage); break;
    case 0x88: instruction = makeInstruction(&scan, DEY, Implied); break;
    case 0x8A: instruction = makeInstruction(&scan, TXA, Implied); break;
    case 0x8C: instruction = makeInstruction(&scan, STY, Absolute); break;
    case 0x8D: instruction = makeInstruction(&scan, STA, Absolute); break;
    case 0x8E: instruction = makeInstruction(&scan, STX, Absolute); break;
    case 0x90: instruction = makeInstruction(&scan, BCC, Relative); break;
    case 0x91: instruction = makeInstruction(&scan, STA, Indirect_YIndexed); break;
    case 0x94: instruction = makeInstruction(&scan, STY, ZeroPage_XIndexed); break;
    case 0x95: instruction = makeInstruction(&scan, STA, ZeroPage_XIndexed); break;
    case 0x96: instruction = makeInstruction(&scan, STX, ZeroPage_YIndexed); break;
    case 0x98: instruction = makeInstruction(&scan, TYA, Implied); break;
    case 0x99: instruction = makeInstruction(&scan, STA, Absolute_YIndexed); break;
    case 0x9A: instruction = makeInstruction(&scan, TXS, Implied); break;
    case 0x9D: instruction = makeInstruction(&scan, STA, Absolute_XIndexed); break;
    case 0xA0: instruction = makeInstruction(&scan, LDY, Immediate); break;
    case 0xA1: instruction = makeInstruction(&scan, LDA, XIndexed_Indirect); break;
    case 0xA2: instruction = makeInstruction(&scan, LDX, Immediate); break;
    case 0xA4: instruction = makeInstruction(&scan, LDY, ZeroPage); break;
    case 0xA5: instruction = makeInstruction(&scan, LDA, ZeroPage); break;
    case 0xA6: instruction = makeInstruction(&scan, LDX, ZeroPage); break;
    case 0xA8: instruction = makeInstruction(&scan, TAY, Implied); break;
    case 0xA9: instruction = makeInstruction(&scan, LDA, Immediate); break;
    case 0xAA: instruction = makeInstruction(&scan, TAX, Implied); break;
    case 0xAC: instruction = makeInstruction(&scan, LDY, Absolute); break;
    case 0xAD: instruction = makeInstruction(&scan, LDA, Absolute); break;
    case 0xAE: instruction = makeInstruction(&scan, LDX, Absolute); break;
    case 0xB0: instruction = makeInstruction(&scan, BCS, Relative); break;
    case 0xB1: instruction = makeInstruction(&scan, LDA, Indirect_YIndexed); break;
    case 0xB4: instruction = makeInstruction(&scan, LDY, ZeroPage_XIndexed); break;
    case 0xB5: instruction = makeInstruction(&scan, LDA, ZeroPage_XIndexed); break;
    case 0xB6: instruction = makeInstruction(&scan, LDX, ZeroPage_YIndexed); break;
    case 0xB8: instruction = makeInstruction(&scan, CLV, Implied); break;
    case 0xB9: instruction = makeInstruction(&scan, LDA, Absolute_YIndexed); break;
    case 0xBA: instruction = makeInstruction(&scan, TSX, Implied); break;
    case 0xBC: instruction = makeInstruction(&scan, LDY, Absolute_XIndexed); break;
    case 0xBD: instruction = makeInstruction(&scan, LDA, Absolute_XIndexed); break;
    case 0xBE: instruction = makeInstruction(&scan, LDX, Absolute_YIndexed); break;
    case 0xC0: instruction = makeInstruction(&scan, CPY, Immediate); break;
    case 0xC1: instruction = makeInstruction(&scan, CMP, XIndexed_Indirect); break;
    case 0xC4: instruction = makeInstruction(&scan, CPY, ZeroPage); break;
    case 0xC5: instruction = makeInstruction(&scan, CMP, ZeroPage); break;
    case 0xC6: instruction = makeInstruction(&scan, DEC, ZeroPage); break;
    case 0xC8: instruction = makeInstruction(&scan, INY, Implied); break;
    case 0xC9: instruction = makeInstruction(&scan, CMP, Immediate); break;
    case 0xCA: instruction = makeInstruction(&scan, DEX, Implied); break;
    case 0xCC: instruction = makeInstruction(&scan, CPY, Absolute); break;
    case 0xCD: instruction = makeInstruction(&scan, CMP, Absolute); break;
    case 0xCE: instruction = makeInstruction(&scan, DEC, Absolute); break;
    case 0xD0: instruction = makeInstruction(&scan, BNE, Relative); break;
    case 0xD1: instruction = makeInstruction(&scan, CMP, Indirect_YIndexed); break;
    case 0xD5: instruction = makeInstruction(&scan, CMP, ZeroPage_XIndexed); break;
    case 0xD6: instruction = makeInstruction(&scan, DEC, ZeroPage_XIndexed); break;
    case 0xD8: instruction = makeInstruction(&scan, CLD, Implied); break;
    case 0xD9: instruction = makeInstruction(&scan, CMP, Absolute_YIndexed); break;
    case 0xDD: instruction = makeInstruction(&scan, CMP, Absolute_XIndexed); break;
    case 0xDE: instruction = makeInstruction(&scan, DEC, Absolute_XIndexed); break;
    case 0xE0: instruction = makeInstruction(&scan, CPX, Immediate); break;
    case 0xE1: instruction = makeInstruction(&scan, SBC, XIndexed_Indirect); break;
    case 0xE4: instruction = makeInstruction(&scan, CPX, ZeroPage); break;
    case 0xE5: instruction = makeInstruction(&scan, SBC, ZeroPage); break;
    case 0xE6: instruction = makeInstruction(&scan, INC, ZeroPage); break;
    case 0xE8: instruction = makeInstruction(&scan, INX, Implied); break;
    case 0xE9: instruction = makeInstruction(&scan, SBC, Immediate); break;
    case 0xEA: instruction = makeInstruction(&scan, NOP, Implied); break;
    case 0xEC: instruction = makeInstruction(&scan, CPX, Absolute); break;
    case 0xED: instruction = makeInstruction(&scan, SBC, Absolute); break;
    case 0xEE: instruction = makeInstruction(&scan, INC, Absolute); break;
    case 0xF0: instruction = makeInstruction(&scan, BEQ, Relative); break;
    case 0xF1: instruction = makeInstruction(&scan, SBC, Indirect_YIndexed); break;
    case 0xF5: instruction = makeInstruction(&scan, SBC, ZeroPage_XIndexed); break;
    case 0xF6: instruction = makeInstruction(&scan, INC, ZeroPage_XIndexed); break;
    case 0xF8: instruction = makeInstruction(&scan, SED, Implied); break;
    case 0xF9: instruction = makeInstruction(&scan, SBC, Absolute_YIndexed); break;
    case 0xFD: instruction = makeInstruction(&scan, SBC, Absolute_XIndexed); break;
    case 0xFE: instruction = makeInstruction(&scan, INC, Absolute_XIndexed); break;
    }

    return instructions;
} // Disassemble

@end // Disassembly
