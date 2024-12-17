import CoreFoundation
import Foundation

struct VM {
    var a: Int
    var b: Int
    var c: Int
    var p: Int = 0
    
    func combo(_ op: Int) -> Int {
        switch op {
        case 0...3: return op
        case 4: return a
        case 5: return b
        case 6: return c
        default: assert(false, "invalid combo operand!")
        }
    }
    
    enum Inst {
        case adv(op: Int) // a = a / 2^COMBO
        case bxl(op: Int) // b = b | LITERAL
        case bst(op: Int) // b = COMBO & 7
        case jnz(op: Int) // if a != 0 then p = LITERAL
        case bxc(op: Int) // b = b ^ c
        case out(op: Int) // print COMBO & 7
        case bdv(op: Int) // b = a / 2^COMBO
        case cdv(op: Int) // c = a / 2^COMBO
    }
}

enum VMError : Error {
    case halt
}

class Day17 {
    var initialRegisters: (Int, Int, Int) = (0, 0, 0)
    var program: [Int] = []
    var instructions: [VM.Inst] = []
    
    class func run(test: Bool = false) {
        let day = Day17(test: test)
        
        print(day.part1())
        print(day.part2())
    }
    
    init(test: Bool = false) {
        let input = slurpLines(day: 17, test: test)
        
        // initial registers
        let a = Int(input[0].matches(of: /\d+/).first!.0)!
        let b = Int(input[1].matches(of: /\d+/).first!.0)!
        let c = Int(input[2].matches(of: /\d+/).first!.0)!
        
        // initialize
        initialRegisters = (a, b, c)
        
        // parse the program
        program = input[4].matches(of: /\d+/).map { Int($0.0)! }
        
        // every instruction should have an opcode
        assert(program.count & 1 == 0)
        
        // convert to instructions
        for i in stride(from: 0, to: program.count, by: 2) {
            let op = program[i+1]
            
            switch program[i] {
            case 0: instructions.append(.adv(op: op))
            case 1: instructions.append(.bxl(op: op))
            case 2: instructions.append(.bst(op: op))
            case 3: instructions.append(.jnz(op: op))
            case 4: instructions.append(.bxc(op: op))
            case 5: instructions.append(.out(op: op))
            case 6: instructions.append(.bdv(op: op))
            case 7: instructions.append(.cdv(op: op))
            default:
                assert(false)
            }
        }
    }
    
    func run(a: Int? = nil) -> [Int] {
        var vm: VM = VM(a: a ?? initialRegisters.0, b: initialRegisters.1, c: initialRegisters.2)
        var output: [Int] = []
        
        while let inst = instructions[safe: vm.p] {
            vm.p += 1
            
            switch inst {
            case .adv(op: let op):
                vm.a /= 1 << vm.combo(op)
            case .bxl(op: let op):
                vm.b ^= op
            case .bst(op: let op):
                vm.b = vm.combo(op) & 7
            case .jnz(op: let op):
                if vm.a != 0 {
                    vm.p = op
                }
            case .bxc:
                vm.b ^= vm.c
            case .out(op: let op):
                output.append(vm.combo(op) & 7)
            case .bdv(op: let op):
                vm.b = vm.a / (1 << vm.combo(op))
            case .cdv(op: let op):
                vm.c = vm.a / (1 << vm.combo(op))
            }
        }
        
        return output
    }
    
    func searchQuine(from: Int = 0, iter: Int? = nil) -> Int? {
        let n = iter ?? program.count - 1
        let p = program[n...]
        
        for a in from..<from+8 {
            let output = run(a: a)
            
            if output[...] == p {
                if n == 0 {
                    return a
                }

                // recurse as it's possible there are multiple matches
                if let ans = searchQuine(from: a * 8, iter: n - 1) {
                    return ans
                }
            }
        }
        
        // no match? inconceivable!
        return nil
    }
    
    func part1() -> String {
        return run().map { String($0) }.joined(separator: ",")
    }
    
    func part2() -> Int {
        // Because this puzzle suffers from the "halting problem", we know that A must
        // decrement. Inspecting the program code, we can see that the program only
        // outputs once each iteration and decrements A each iteration. The only possible
        // way to reduce A is with the `adv` instruction, and we see there's only one
        // of those with a divide by 8.
        //
        // For this reason, we know how long the program (N) and realize that since only
        // a single output is generated per loop, there must be N iterations. And since
        // A is reduced each iteration, we know that the solution must be within the
        // domain 8^N ..< 8^N+1.
        //
        // That's too large a range to exhaustively search. But, since we know that every
        // iteration reduces A, that implicitly reduces the search space for the rest
        // of the program left to produce.
        //
        // So, if we start from the end of the program, the search space is now just 0..<8.
        // If we find a match, then we multiply and have a new search space, also in the
        // domain of X..<X+8.
        //
        // However, it's possible that there are multiple matches, so it must be solved
        // recursively, incase one path fails to match the entire program.
        
        return searchQuine()!
    }
}
