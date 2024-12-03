import CoreFoundation
import Foundation

class Day1 {
    var xs: [Int] = []
    var ys: [Int] = []
    
    class func run(test: Bool = false) {
        let day = Day1(test: test)
        
        print(day.part1())
        print(day.part2())
    }
    
    init(test: Bool = false) {
        for line in slurpLines(day: 1, test: test) {
            let ns = line.split(separator: /\s+/, maxSplits: 1)
            
            xs.append(Int(ns[0])!)
            ys.append(Int(ns[1])!)
        }
        
        // sort for simple merging
        xs.sort(by: {$0 < $1})
        ys.sort(by: {$0 < $1})
    }
    
    func part1() -> Int {
        return zip(xs, ys).reduce(0, {$0 + abs($1.0 - $1.1)})
    }
    
    func part2() -> Int {
        var counts: [Int: Int] = [:]
        
        for y in ys {
            counts[y] = (counts[y] ?? 0) + 1
        }
        
        return xs.reduce(0, {$0 + (counts[$1] ?? 0) * $1})
    }
}
