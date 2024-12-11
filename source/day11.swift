import CoreFoundation
import Foundation
import BigInt

class Day11 {
    var numbers: [BigInt] = []
    var cache: [BigInt: [Int]] = [:]
    
    class func run(test: Bool = false) {
        let day = Day11(test: test)
        
        print(day.part1())
        print(day.part2())
    }
    
    init(test: Bool = false) {
        numbers = slurp(day: 11, test: test).split(separator: /\s+/).map() { BigInt(String($0))! }
    }
    
    func blink(_ n: BigInt) -> [BigInt] {
        if n == 0 {
            return [BigInt(1)]
        }
        
        let s = String(n)
        
        if s.count % 2 == 0 {
            let left = BigInt(s.prefix(s.count / 2))!
            let right = BigInt(s.suffix(s.count / 2))!
            
            return [left, right]
        }
        
        return [n * 2024]
    }
    
    func solve(_ n: BigInt, steps: Int) -> Int {
        if let ans = cache[n] {
            if steps < ans.count {
                return ans[steps]
            }
        }
        
        // index 0 = no change, just this number
        var ans = [1]
        
        if steps > 0 {
            let next = blink(n)
            
            // recursively solve each of the next numbers
            next.forEach { _ = solve($0, steps: steps - 1) }
            
            // lookup the new, cached answers
            let counts = next.map { cache[$0]! }
            
            // validate that each cached answer has enough to finish this
            assert(counts.first!.count >= steps && counts.last!.count >= steps)
            
            // counts will have up to 2 arrays, sum the zip of them
            for i in 0..<steps {
                ans.append(counts.reduce(0) { $0 + $1[i] })
            }
        }
        
        // update the cache with the new answer
        cache[n] = ans
        
        // the total count of numbers after N blinks
        return ans.last!
    }
    
    func part1() -> Int {
        return numbers.reduce(0) { $0 + solve($1, steps: 25) }
    }
    
    func part2() -> Int {
        return numbers.reduce(0) { $0 + solve($1, steps: 75) }
    }
}
