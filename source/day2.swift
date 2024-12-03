import CoreFoundation
import Foundation

class Day2 {
    var reports: [[Int]] = []
    
    class func run(test: Bool = false) {
        let day = Day2(test: test)
        
        print(day.part1())
        print(day.part2())
    }
    
    init(test: Bool = false) {
        for line in slurpLines(day: 2, test: test) {
            reports.append(line.split(separator: /\s+/).map({Int($0)!}))
        }
    }
    
    func isSafe(report: [Int], dampen: Bool = false, skipFirst: Bool = false) -> Bool {
        var dampened: Bool = !dampen || skipFirst
        
        // get the initial index to start reading at
        let startIndex: Int = skipFirst ? 2 : 1
        
        // first "previous" reading
        var p: Int = report[startIndex - 1]
        var s: Int? = nil
        
        for i in startIndex..<report.count {
            let d = report[i] - p
            
            // is the change too large or in a different direction?
            if abs(d) > 3 || (s != nil && d.signum() != s) {
                if dampened {
                    return false
                }
                
                // skip this level reading, don't skip again
                dampened = true
                continue
            }
            
            // update state
            p = report[i]
            s = d.signum()
        }
        
        return true
    }
    
    func part1() -> Int {
        return reports.count(where: {isSafe(report: $0)})
    }
    
    func part2() -> Int {
        return reports.count(where: {
            isSafe(report: $0, dampen: true) ||
            isSafe(report: $0, dampen: true, skipFirst: true)
        })
    }
}
