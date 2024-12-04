import CoreFoundation
import Foundation

class Day4 {
    var puzzle: [[Substring.Element]] = []
    var width: Int = 0
    var height: Int = 0
    
    class func run(test: Bool = false) {
        let day = Day4(test: test)
        
        print(day.part1())
        print(day.part2())
    }
    
    init(test: Bool = false) {
        puzzle = slurpMatrix(day: 4, test: test)
        height = puzzle.count
        width = puzzle[0].count
    }
    
    func findXMAS(_ x: Int, _ y: Int, _ dx: Int, _ dy: Int) -> Bool {
        for (i, c) in "XMAS".enumerated() {
            guard let row = puzzle[safe: y + dy*i] else {
                return false
            }
            
            if row[safe: x + dx*i] != c {
                return false
            }
        }
        
        return true
    }
    
    func part1() -> Int {
        var found: Int = 0
        
        // search directions for the word search
        let dirs: [(Int, Int)] = [
            (-1, -1), (0, -1), (1, -1), (-1,  0), (1,  0), (-1,  1), (0,  1), (1,  1),
        ]
        
        // search all rows and columns in all directions
        for y in 0..<height {
            for x in 0..<width {
                found += dirs.count(where: {findXMAS(x, y, $0.0, $0.1)})
            }
        }
        
        return found
    }
    
    func part2() -> Int {
        var found: Int = 0
        
        for y in 1..<height - 1 {
            for x in 1..<width - 1 {
                if puzzle[y][x] == "A" {
                    let diag0 = String([puzzle[y-1][x-1], puzzle[y+1][x+1]])
                    let diag1 = String([puzzle[y-1][x+1], puzzle[y+1][x-1]])
                    
                    if (diag0 == "MS" || diag0 == "SM") && (diag1 == "MS" || diag1 == "SM") {
                        found += 1
                    }
                }
            }
        }
        
        return found
    }
}
