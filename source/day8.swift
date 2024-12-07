import CoreFoundation
import Foundation

class Day8 {
    var calcs: [Calc] = []
    
    class func run(test: Bool = false) {
        let day = Day8(test: test)
        
        print(day.part1())
        print(day.part2())
    }
    
    init(test: Bool = false) {
        for line in slurpLines(day: 8, test: test) {
            
        }
    }
    
    func part1() -> Int {
        return 0
    }
    
    func part2() -> Int {
        return 0
    }
}
