// MOSFileParser.swift - consume a Kim-1 "paper tape" flavor of file.

import Foundation

// file format: https://srecord.sourceforge.net/man/man5/srec_mos_tech.5.html
//
// Multiple lines that look like:
// ;180200A20D866EA9009560CA10FBA20BB560D03BCA10F9E66DA56C0C34
// ;180218F009C66DC66ED0034C2519AD44174A4A4A4A4AC90690022908F3
//
// Records start off with a semicolon (leading characters and NULs ignored)
//
// The line is broken up:
// ; 18 0200 A20D866EA9009560CA10FBA20BB560D03BCA10F9E66DA56C 0C34
//   |  |    |                                                |
//   |  |    +-- hex 18 (24 decimal) bytes of data            +-- checksum
//   |  +-- memory address for this line of data
//   +-- how many bytes of actual data to place at the given address
//
// checksum is computed by adding all of the bytes (18 + 02 + 00 + A2 ... 6C)
// and the lower 16-bits of the result taken
//
// The last line of the file looks like:
// ;0000090009
//
// Which breaks down to
// ;00 0009 0009
//  |  |    |
//  |  |    +-- line count repeated
//  |  +-- how many lines (not counting this one) were in the file
//  +-- zero byte

struct MOSFileParser {
    let contents: String

    init(withContents contents: String) {
        self.contents = contents
    }

    func parse() throws -> (baseAddress: Int16, bytes: [CUnsignedChar]) {
        return (12, []);
    }
}
