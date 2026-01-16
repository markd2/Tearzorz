// Disassembly.h - header for byte to Instruction mapping. also has the list
//    of opcodes and addressing modes

#import <Foundation/Foundation.h>


typedef enum Opcode {
    ADC, // - add with carry
    AND, // * and
    ASL, // * arithmetic shift left
    BCC, // * branch on carry flag clear
    BCS, // * branch on carry flag set
    BEQ, // * branch on equal - zero flag set
    BIT, // * bit test
    BMI, // * branch on minus - negative flag set
    BNE, // * branch on not equal - zero flag clear
    BPL, // * branch on plus - negative flag clear
    BRK, // - break
    BVC, // * branch on overflow flag clear
    BVS, // * branch on overflow flag set
    CLC, // * clear carry
    CLD, // * clear decimal mode
    CLI, // * clear interrupt
    CLV, // * clear overflow
    CMP, // * compare
    CPX, // * compare with X
    CPY, // * compare with Y
    DEC, // - decrement (memory)
    DEX, // * decrement X
    DEY, // * decrement Y
    EOR, // * exclusive or
    INC, // - increment (memory)
    INX, // * increment X
    INY, // * increment Y
    JMP, // * jump
    JSR, // * jump subroutine
    LDA, // * load accumulator
    LDX, // * load X
    LDY, // * load Y
    LSR, // * logical shift right
    NOP, // * no operation
    ORA, // * or with accumulator
    PHA, // * push accumulator
    PHP, // * push processor status (SR)
    PLA, // * pull (pop) accumulator
    PLP, // * pull (pop) processor status (SR)
    ROL, // * rotate left
    ROR, // - rotate right
    RTI, // - return from interrupt
    RTS, // * return from subroutine
    SBC, // - subtract with carry
    SEC, // * set carry
    SED, // * set decimal mode
    SEI, // * set interrupt disable
    STA, // * store accumulator
    STX, // * store X
    STY, // * store Y
    TAX, // * transfer accumulator to X
    TAY, // * transfer accumulator to Y
    TSX, // * transfer stack pointer to X
    TXA, // * transfer X to accumulator
    TXS, // * transfer X to stack pointer
    TYA  // * transfer Y to accumulator
} Opcode;

typedef enum AddressingMode {
    Accumulator,
    Absolute,
    Absolute_XIndexed,
    Absolute_YIndexed,
    Immediate,
    Implied,
    Indirect,
    Indexed_Indirect_X,
    Indirect_Indexed_Y,
    Relative,
    ZeroPage,
    ZeroPage_XIndexed,
    ZeroPage_YIndexed
} AddressingMode;


@interface Instruction: NSObject {
    char _bytes[3];
}
@property (assign, nonatomic) Opcode opcode;
@property (assign, nonatomic) AddressingMode addressingMode;

/// how much to advance the program counter
@property (assign, readonly, nonatomic) UInt16 byteCount;

- (instancetype) initWithOpcode: (Opcode) opcode
                 addressingMode: (AddressingMode) addressingMode
                          bytes: (unsigned char *) bytes;

- (unsigned char) modeByteValue;
- (uint16_t) modeWordAddressValue;
- (uint16_t) modeByteAddressValue;
@end // Instruction


@interface Disassembly : NSObject

- (NSArray<Instruction *> *) disassemble: (NSData *) data;

@end // Disassembly


#if 0
#endif
