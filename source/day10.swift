import CoreFoundation
import Foundation

class Day10 {
    var starts: [(Int, Int)] = []
    var trails: [[Int]] = []
    
    class func run(test: Bool = false) {
        let day = Day10(test: test)
        
        print(day.part1())
        print(day.part2())
    }
    
    init(test: Bool = false) {
        let zero: UInt8 = Character("0").asciiValue!
        
        trails = slurpMatrix(day: 10, test: test).map () {
            $0.map() { Int($0.asciiValue! - zero) }
        }
        
        // find all the start positions
        for (y, row) in trails.enumerated() {
            for (x, height) in row.enumerated() {
                if height == 0 {
                    starts.append((x, y))
                }
            }
        }
    }
    
    func trailHeight(_ x: Int, _ y: Int) -> Int? {
        return (x < 0 || y < 0 || y >= trails.count || x >= trails[y].count) ? nil : trails[y][x]
    }
    
    func trailPaths(_ x: Int, _ y: Int) -> [(Int, Int)] {
        return [(x-1, y), (x+1, y), (x, y-1), (x, y+1)]
    }
    
    func trails(fromHeight: Int = -1, x: Int, y: Int) -> [Pos] {
        guard let height = trailHeight(x, y) else {
            return []
        }
        
        // not a valid trail path?
        if height != fromHeight + 1 {
            return []
        }
        
        // reached the top?
        if height == 9 {
            return [Pos(x: x, y: y)]
        }
        
        return trailPaths(x, y).reduce([]) {
            $0 + trails(fromHeight: height, x: $1.0, y: $1.1)
        }
    }
    
    func part1() -> Int {
        return starts.reduce(0) { $0 + Set(trails(x: $1.0, y: $1.1)).count }
    }
    
    func part2() -> Int {
        return starts.reduce(0) { $0 + trails(x: $1.0, y: $1.1).count }
    }
}
