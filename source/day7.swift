import CoreFoundation
import Foundation

enum Op: CaseIterable {
    case add
    case mul
    case cat
}

struct Calc {
    let ans: Int
    let nums: [Int]
}

class Day7 {
    var calcs: [Calc] = []
    
    class func run(test: Bool = false) {
        let day = Day7(test: test)
        
        print(day.part1())
        print(day.part2())
    }
    
    init(test: Bool = false) {
        for line in slurpLines(day: 7, test: test) {
            let m = line.matches(of: /\d+/)
            let ans = Int(m[0].output)!
            let nums = m[1...].map() { Int($0.output)! }
            
            calcs.append(Calc(ans: ans, nums: nums))
        }
    }
    
    func solve(calc: Calc, i: Int = 0, ops: [Op] = Op.allCases, total: Int = 0) -> Int? {
        if total > calc.ans {
            return nil  // break early condition
        }
        
        // all numbers used, success or failure?
        if i == calc.nums.count {
            return total == calc.ans ? total : nil
        }
        
        // try one of the operations
        for op in ops {
            let n = switch op {
            case .add: total + calc.nums[i]
            case .mul: total * calc.nums[i]
            case .cat: Int("\(total)\(calc.nums[i])")!
            }
            
            // recurse to try all combinations
            if solve(calc: calc, i: i+1, ops: ops, total: n) == calc.ans {
                return calc.ans
            }
        }
        
        // no combinations work
        return nil
    }
    
    func calibrationResult(ops: [Op] = Op.allCases) -> Int {
        return calcs.reduce(0) { $0 + (solve(calc: $1, ops: ops) ?? 0) }
    }
    
    func part1() -> Int {
        return calibrationResult(ops: [.mul, .add])
    }
    
    func part2() -> Int {
        return calibrationResult(ops: [.cat, .mul, .add])
    }
}
