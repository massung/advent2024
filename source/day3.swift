import CoreFoundation
import Foundation

enum Cmd {
    case Mul(Int, Int)
    case Do
    case Dont
}

class Day3 {
    var cmds: [Cmd] = []
    
    class func run(test: Bool = false) {
        let day = Day3(test: test)
        
        print(day.part1())
        print(day.part2())
    }
    
    init(test: Bool = false) {
        for line in slurpLines(day: 3, test: test) {
            cmds += line
                .matches(of: /do(?:n't)?\(\)|mul\((\d+),(\d+)\)/)
                .map {
                    switch $0.output.0 {
                    case "do()": .Do
                    case "don't()": .Dont
                    default:
                            .Mul(
                                Int($0.output.1!)!,
                                Int($0.output.2!)!
                            )
                    }
                }
        }
    }
    
    func part1() -> Int {
        var ans = 0
                
        for cmd in cmds {
            if case .Mul(let x, let y) = cmd {
                ans += x * y
            }
        }
        
        return ans
    }
    
    func part2() -> Int {
        var ans = 0
        var enabled = true
                
        for cmd in cmds {
            switch cmd {
            case .Mul(let x, let y): ans += enabled ? x * y : 0
            case .Do: enabled = true
            case .Dont: enabled = false
            }
        }
        
        return ans
    }
}
