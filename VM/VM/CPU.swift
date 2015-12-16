//
//  CPU.swift
//  VM
//
//  Created by Drew Gottlieb on 12/14/15.
//  Copyright © 2015 Drew Gottlieb. All rights reserved.
//

import Foundation

private struct Properties {
    static let memorySpace: UInt16 = 4096 // 2 ^ 12
    static let memorySize: UInt16 = memorySpace
}

enum Error: ErrorType {
    case InvalidWord(word: String)
    case AddressOutOfRange(address: Int)
}

enum OpCode: UInt8 {
    case Add =           0x0
    case AddCarry =      0x1
    case Sub =           0x2
    case SubCarry =      0x3
    case And =           0x4
    case Or =            0x5
    case Xor =           0x6
    case Not =           0x7
    case LoadImmediate = 0x8
    case LoadMemory =    0x9
    case StoreMemory =   0xA
    case Jump =          0xB
    case JumpIndirect =  0xC
    case JumpZero =      0xD
    case JumpMinus =     0xE
    case JumpCarry =     0xF
}

struct Instruction {
    let opcode: OpCode
    let operand: UInt16
    
    init(word: UInt16) {
        opcode = OpCode(rawValue: UInt8(word >> 12))!
        operand = word & 0x0FFF
    }
    
    var isHalt: Bool {
        return opcode == .Add && operand == 0x000
    }
    
    var referencesMemory: Bool {
        return ![.LoadImmediate, .Not].contains(self.opcode)
    }
}

class CPU: CustomStringConvertible {
    var ram = ContiguousArray<UInt16>(count: Int(Properties.memorySize), repeatedValue: 0x0000)
    var map = [Int: String]()
    
    var pc = 0 {
        willSet {
            if newValue >= Int(Properties.memorySize) {
                fatalError("PC out of range")
            }
        }
    }
    
    var accumulator: UInt16 = 0
    var carryFlag: Bool = false
    
    func currentInstruction() throws -> Instruction {
        return Instruction(word: try wordAtAddress(pc))
    }
    
    init(ram: [UInt16], map: [Int: String]? = nil) {
        self.ram.replaceRange(ram.startIndex..<ram.endIndex, with: ram)
        self.map = map ?? self.map
    }
    
    convenience init(ram: [String], map: [Int: String]? = nil) throws {
        self.init(ram: try ram.map({ (word: String) throws -> UInt16 in
            guard let data = word.uint16 else {
                throw Error.InvalidWord(word: word)
            }
            return data
        }), map: map)
    }
    
    convenience init(ram: String, map: [Int: String]? = nil) throws {
        try self.init(ram: ram.componentsSeparatedByString("\n"), map: map)
    }
    
    func execute(onExecute: ((CPU) -> ())? = nil) throws {
        while true {
            let instruction = try currentInstruction()
            if instruction.isHalt {
                break
            }
            
            pc = try executeInstruction(instruction)
            onExecute?(self)
        }
    }
    
    func executeInstruction(instruction: Instruction) throws -> Int {
        let readWord = { try self.wordAtAddress(Int(instruction.operand)) }
        
        switch instruction.opcode {
        case .Add:
            (accumulator, carryFlag) = UInt16.addWithOverflow(try readWord(), accumulator)
        case .AddCarry:
            if carryFlag {
                (accumulator, carryFlag) = UInt16.addWithOverflow(1, accumulator)
            }
            (accumulator, carryFlag) = UInt16.addWithOverflow(try readWord(), accumulator)
        case .Sub:
            (accumulator, carryFlag) = UInt16.subtractWithOverflow(accumulator, try readWord())
        case .SubCarry:
            if carryFlag {
                (accumulator, carryFlag) = UInt16.subtractWithOverflow(accumulator, 1)
            }
            (accumulator, carryFlag) = UInt16.subtractWithOverflow(accumulator, try readWord())
        case .And:
            accumulator &= try readWord()
        case .Or:
            accumulator |= try readWord()
        case .Xor:
            accumulator ^= try readWord()
        case .Not:
            accumulator = ~accumulator
        case .LoadImmediate:
            accumulator = instruction.operand
        case .LoadMemory:
            accumulator = try readWord()
        case .StoreMemory:
            try writeWord(accumulator, toAddress: Int(instruction.operand))
        case .Jump:
            return Int(instruction.operand)
        case .JumpIndirect:
            return Int(try readWord())
        case .JumpZero:
            return accumulator == 0x0000 ? Int(instruction.operand) : pc + 1
        case .JumpMinus:
            return accumulator & 0x8000 != 0 ? Int(instruction.operand) : pc + 1
        case .JumpCarry:
            return carryFlag ? Int(instruction.operand) : pc + 1
        }
        
        return pc + 1
    }
    
    func wordAtAddress(address: Int) throws -> UInt16 {
        guard address < Int(Properties.memorySpace) else {
            throw Error.AddressOutOfRange(address: address)
        }
        
        if address == 0xFFF {
            return UInt16(getchar() & 0xFFFF)
        }
        
        return ram[address]
    }
    
    func writeWord(word: UInt16, toAddress address: Int) throws {
        guard address < Int(Properties.memorySpace) else {
            throw Error.AddressOutOfRange(address: address)
        }
        
        if address == 0xFFF {
            print(UnicodeScalar(word), terminator: "")
            return
        }
        
        ram[address] = word
    }
    
    var description: String {
        var desc = ""
        
        // Get the most recent label for current PC, with an offset
        var stepsBack = 0
        var curAddr = pc
        var label: String? = nil
        while curAddr > 0 {
            label = map[curAddr]
            if label != nil { break }
            curAddr -= 1
            stepsBack += 1
        }
        
        // Display the PC
        desc += UInt16(pc).paddedHexString
        desc += "\t"
        
        // Display the most recent label + relative offset
        if !map.isEmpty {
            desc += label ?? "[start]"
            if stepsBack > 0 { desc += " + \(stepsBack)" }
            desc += "\t\t"
        }
        
        // Display the current accumulator value
        desc += "A = " + accumulator.paddedHexString
        desc += "\t\t"
        
        // Display the instruction at PC, displaying mapped labels if found
        if let instruction = try? currentInstruction() {
            desc += String(instruction.opcode)
            desc += " "
            
            if instruction.referencesMemory {
                desc += self.map[Int(instruction.operand)] ?? instruction.operand.paddedHexString
            } else {
                desc += instruction.operand.paddedHexString
            }
        } else {
            desc += "unknown instruction"
        }
        
        return desc
    }
}

extension String {
    var uint16: UInt16? {
        let scanner = NSScanner(string: self)
        
        var tmpData: UInt32 = 0
        guard scanner.scanHexInt(&tmpData) else {
            return nil
        }
        
        let data = UInt16(tmpData & 0xFFFF)
        
        guard UInt32(data) == tmpData else {
            return nil
        }
        
        return data
    }
}

extension UInt16 {
    var paddedHexString: String {
        var s = String(self, radix: 16, uppercase: true)
        while s.characters.count < 4 {
            s = "0" + s
        }
        return s
    }
}