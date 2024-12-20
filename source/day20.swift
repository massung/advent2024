import CoreFoundation
import Foundation

class Day20 {
    var maze: [[Character]] = []
    var startPos: Pos = .zero
    var endPos: Pos = .zero
    var testData: Bool = false
    
    class func run(test: Bool = false) {
        let day = Day20(test: test)
        
        print(day.part1())
        print(day.part2())
    }
    
    init(test: Bool = false) {
        testData = test
        maze = slurpMatrix(day: 20, test: test)

        for (y, row) in maze.enumerated() {
            if let x = row.firstIndex(of: "S") {
                startPos = Pos(x: row.distance(from: row.startIndex, to: x), y: y)
            }
            
            if let x = row.firstIndex(of: "E") {
                endPos = Pos(x: row.distance(from: row.startIndex, to: x), y: y)
            }
        }
    }
    
    func inBounds(_ pos: Pos) -> Bool {
        return pos.x >= 1 && pos.y >= 1 && pos.y < maze.count - 1 && pos.x < maze[pos.y].count - 1
    }
    
    func isWall(_ pos: Pos) -> Bool {
        return maze[pos.y][pos.x] == "#"
    }
    
    func solve() -> [Pos : Int] {
        var solution: [Pos : Int] = [endPos: 0]
        var path: [Pos] = []
        var pos: Pos = startPos
        
        while pos != endPos {
            let prev = path.last
            
            // add this position to the path
            path.append(pos)
            
            // find the next position that isn't the previous
            for dir in Direction.allCases {
                let nextPos = dir.step(pos)
                
                if nextPos != prev && inBounds(nextPos) && !isWall(nextPos) {
                    pos = nextPos
                    break
                }
            }
        }
        
        // build the solution cache
        for (q, pos) in path.reversed().enumerated() {
            solution[pos] = q + 1
        }
        
        return solution
    }
    
    func cheatPaths(from: Pos, length: Int, solutions: [Pos : Int]) -> [Int] {
        var costs: [Int] = []
        
        for x in -length...length {
            for y in -length...length {
                let pos = from + Pos(x: x, y: y)
                let dist = abs(x) + abs(y)
                
                if let cost = solutions[pos], dist <= length {
                    costs.append(cost + dist)
                }
            }
        }
        
        return costs
    }
    
    func cheatCosts(from: Pos, length: Int, solutions: [Pos : Int], minSavings: Int = 0) -> [Int] {
        let baseCost = solutions[from]!
        
        // find all the possible paths from here
        return cheatPaths(from: from, length: length, solutions: solutions).compactMap { cost in
            let savings = baseCost - cost
            return savings >= minSavings ? savings : nil
        }
    }
    
    func part1() -> Int {
        let solutions = solve()
        let minSavings = testData ? 0 : 100
        
        // at every space along the path, try and cheat
        let ans = solutions.keys.reduce(0) { ans, pos in
            ans + cheatCosts(from: pos, length: 2, solutions: solutions, minSavings: minSavings).count
        }
        
        return ans
    }
    
    func part2() -> Int {
        let solutions = solve()
        let minSavings = testData ? 0 : 100
        
        // at every space along the path, try and cheat
        let ans = solutions.keys.reduce(0) { ans, pos in
            ans + cheatCosts(from: pos, length: 20, solutions: solutions, minSavings: minSavings).count
        }
        
        return ans
    }
}
