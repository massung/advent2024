import CoreFoundation
import Foundation

class Day19 {
    var patterns: [String] = []
    var towels: [String] = []
    
    class func run(test: Bool = false) {
        let day = Day19(test: test)
        
        print(day.part1())
        print(day.part2())
    }
    
    init(test: Bool = false) {
        let lines = slurpLines(day: 19, test: test)

        patterns = lines[0].split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
        towels = lines[2...].map(String.init)
    }
    
    func solve(towel: String.SubSequence, cache: inout [String.Index : Int]) -> Int {
        if towel.isEmpty {
            return 1
        }
        
        // was the solution from here already calculated?
        if let ans = cache[towel.startIndex] {
            return ans
        }
        
        // try and match patterns
        let ans = patterns.reduce(0) { n, pattern in
            if towel.starts(with: pattern) {
                return n + solve(towel: towel.dropFirst(pattern.count), cache: &cache)
            } else {
                return n
            }
        }
        
        // don't retry from here
        cache[towel.startIndex] = ans
        
        return ans
    }
    
    func part1() -> Int {
        return towels.count { towel in
            var cache: [String.Index : Int] = [:]
            return solve(towel: towel[...], cache: &cache) > 0
        }
    }
    
    func part2() -> Int {
        return towels.reduce(0) { ans, towel in
            var cache: [String.Index : Int] = [:]
            return ans + solve(towel: towel[...], cache: &cache)
        }
    }
}
