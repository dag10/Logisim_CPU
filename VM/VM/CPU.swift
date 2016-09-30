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

enum CPUError: Error {
    case invalidWord(word: String)
    case addressOutOfRange(address: Int)
}

enum OpCode: UInt8 {
    case add =           0x0
    case addCarry =      0x1
    case sub =           0x2
    case subCarry =      0x3
    case and =           0x4
    case or =            0x5
    case xor =           0x6
    case not =           0x7
    case loadImmediate = 0x8
    case loadMemory =    0x9
    case storeMemory =   0xA
    case jump =          0xB
    case jumpIndirect =  0xC
    case jumpZero =      0xD
    case jumpMinus =     0xE
    case jumpCarry =     0xF
}

struct Instruction {
    let opcode: OpCode
    let operand: UInt16
    
    init(word: UInt16) {
        opcode = OpCode(rawValue: UInt8(word >> 12))!
        operand = word & 0x0FFF
    }
    
    var isHalt: Bool {
        return opcode == .add && operand == 0x000
    }
    
    var referencesMemory: Bool {
        return ![.loadImmediate, .not].contains(self.opcode)
    }
}

class CPU: CustomStringConvertible {
    typealias InputClosure = () -> UInt16
    typealias OutputClosure = (UInt16) -> ()
    
    var ram = ContiguousArray<UInt16>(repeating: 0x0000, count: Int(Properties.memorySize))
    var map = [Int: String]()
    fileprivate var inputHandlers = [Int: InputClosure]()
    fileprivate var outputHandlers = [Int: OutputClosure]()
    
    var pc = 0 {
        willSet {
            if newValue >= Int(Properties.memorySize) {
                fatalError("PC out of range")
            }
        }
    }
    
    var accumulator: UInt16 = 0
    var carryFlag: Bool = false
    
    func registerInputHandler(_ handler: @escaping InputClosure, forAddress address: Int) {
        inputHandlers[address] = handler
    }
    
    func registerOutputHandler(_ handler: @escaping OutputClosure, forAddress address: Int) {
        outputHandlers[address] = handler
    }
    
    func currentInstruction() throws -> Instruction {
        return Instruction(word: try wordAtAddress(pc))
    }
    
    init(ram: [UInt16], map: [Int: String]? = nil) {
        self.ram.replaceSubrange(ram.indices, with: ram)
        self.map = map ?? self.map
    }
    
    convenience init(ram: [String], map: [Int: String]? = nil) throws {
        self.init(ram: try ram.map({ (word: String) throws -> UInt16 in
            guard let data = word.uint16 else {
                throw CPUError.invalidWord(word: word)
            }
            return data
        }), map: map)
    }
    
    convenience init(ram: String, map: [Int: String]? = nil) throws {
        try self.init(ram: ram.components(separatedBy: "\n"), map: map)
    }
    
    func execute(_ onExecute: ((CPU) -> ())? = nil) throws {
        while true {
            let instruction = try currentInstruction()
            if instruction.isHalt {
                break
            }
            
            pc = try execute(instruction: instruction)
            onExecute?(self)
        }
    }
    
    func execute(instruction: Instruction) throws -> Int {
        let readWord = { try self.wordAtAddress(Int(instruction.operand)) }
        
        switch instruction.opcode {
        case .add:
            (accumulator, carryFlag) = UInt16.addWithOverflow(try readWord(), accumulator)
        case .addCarry:
            if carryFlag {
                (accumulator, carryFlag) = UInt16.addWithOverflow(1, accumulator)
            }
            (accumulator, carryFlag) = UInt16.addWithOverflow(try readWord(), accumulator)
        case .sub:
            (accumulator, carryFlag) = UInt16.subtractWithOverflow(accumulator, try readWord())
        case .subCarry:
            if carryFlag {
                (accumulator, carryFlag) = UInt16.subtractWithOverflow(accumulator, 1)
            }
            (accumulator, carryFlag) = UInt16.subtractWithOverflow(accumulator, try readWord())
        case .and:
            accumulator &= try readWord()
        case .or:
            accumulator |= try readWord()
        case .xor:
            accumulator ^= try readWord()
        case .not:
            accumulator = ~accumulator
        case .loadImmediate:
            accumulator = instruction.operand
        case .loadMemory:
            accumulator = try readWord()
        case .storeMemory:
            try writeWord(accumulator, toAddress: Int(instruction.operand))
        case .jump:
            return Int(instruction.operand)
        case .jumpIndirect:
            return Int(try readWord())
        case .jumpZero:
            return accumulator == 0x0000 ? Int(instruction.operand) : pc + 1
        case .jumpMinus:
            return accumulator & 0x8000 != 0 ? Int(instruction.operand) : pc + 1
        case .jumpCarry:
            return carryFlag ? Int(instruction.operand) : pc + 1
        }
        
        return pc + 1
    }
    
    func wordAtAddress(_ address: Int) throws -> UInt16 {
        guard address < Int(Properties.memorySpace) else {
            throw CPUError.addressOutOfRange(address: address)
        }
        
        if let handler = inputHandlers[address] {
            return handler()
        }
        
        return ram[address]
    }
    
    func writeWord(_ word: UInt16, toAddress address: Int) throws {
        guard address < Int(Properties.memorySpace) else {
            throw CPUError.addressOutOfRange(address: address)
        }
        
        if let handler = outputHandlers[address] {
            handler(word)
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
            desc += String(describing: instruction.opcode)
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
        let scanner = Scanner(string: self)
        
        var tmpData: UInt32 = 0
        guard scanner.scanHexInt32(&tmpData) else {
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
