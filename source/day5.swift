import CoreFoundation
import Foundation

class Day5 {
    var rules: [Int: [Int]] = [:]
    var pages: [[Int]] = []
    
    class func run(test: Bool = false) {
        let day = Day5(test: test)
        
        print(day.part1())
        print(day.part2())
    }
    
    init(test: Bool = false) {
        var parsePages = false
        
        for line in slurpLines(day: 5, test: test) {
            if line == "" {
                parsePages = true
                continue
            }
            
            if parsePages {
                pages.append(line.split(separator: ",").map {Int($0)!})
            } else {
                let rule = line.split(separator: "|").map {Int($0)!}
                
                // Indicate which pages must come BEFORE the key page.
                rules[rule[1], setDefault: []].append(rule[0])
            }
        }
    }
    
    func isOrderValid(_ pageList: [Int]) -> Bool {
        var mustBeBefore: [Int] = []
        
        // ensure each page found is NOT in the the list of having to have come earlier
        for page in pageList {
            if mustBeBefore.contains(page) {
                return false
            }
            
            mustBeBefore += rules[page] ?? []
        }
        
        return true
    }
    
    func part1() -> Int {
        return pages.reduce(0) {
            $0 + (isOrderValid($1) ? $1[$1.count / 2] : 0)
        }
    }
    
    func part2() -> Int {
        var ans = 0
        
        for pageList in pages {
            if !isOrderValid(pageList) {
                let fixed = pageList.sorted(by:) {
                    return !(rules[$0] ?? []).contains($1)
                }
                
                ans += fixed[fixed.count / 2]
            }
        }
        
        return ans
    }
}
