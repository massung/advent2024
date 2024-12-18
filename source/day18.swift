import CoreFoundation
import Foundation

class Day18 {
    var locations: [Pos] = []
    var memory: [Pos : Bool] = [:]
    var size: Int = 0
    
    class func run(test: Bool = false) {
        let day = Day18(test: test)
        
        print(day.part1())
        print(day.part2())
    }
    
    init(test: Bool = false) {
        size = test ? 7 : 71
        
        for line in slurpLines(day: 18, test: test) {
            let m = line.matches(of: /\d+/)
            
            let x = Int(m[0].0)!
            let y = Int(m[1].0)!

            locations.append(Pos(x: x, y: y))
        }
    }
    
    func solve() -> Int? {
        let endPos = Pos(x: size - 1, y: size - 1)
        
        func H(_ pos: Pos) -> Int {
            abs(pos.x - endPos.x) + abs(pos.y - endPos.y)
        }
        
        var queue: [(Pos, Int)] = [(.zero, 0)]
        var visited: [Pos : Int] = [:]
        
        // A*
        while let (pos, q) = queue.popLast() {
            visited[pos] = q
            
            if pos == endPos {
                return q
            }
            
            for dir in Direction.allCases {
                let nextPos = dir.step(pos)
                
                if nextPos.x >= 0 && nextPos.y >= 0 && nextPos.x < size && nextPos.y < size {
                    if !(memory[nextPos] ?? false) && !visited.keys.contains(nextPos) {
                        queue.append((nextPos, q+1))
                    }
                }
            }
            
            queue.sort { $0.1 + H($0.0) > $1.1 + H($1.0) }
        }
        
        return nil
    }
    
    func part1() -> Int {
        if locations.count < 1024 {
            locations[0..<12].forEach { memory[$0] = true }
        } else {
            locations[0..<1024].forEach { memory[$0] = true }
        }
        
        return solve()!
    }
    
    func part2() -> String {
        let fromByte = locations.count < 1024 ? 12 : 1024
        
        // this only works if all the memory locations being dropped are unique
        assert(Set(locations).count == locations.count)
        
        // fill in all the memory locations, then remove them slowly
        locations.forEach { memory[$0] = true }
        
        // slowly "remove" memory locations and try to path
        for pos in locations[fromByte...].reversed() {
            memory[pos] = false
            
            if solve() != nil {
                return "\(pos.x),\(pos.y)"
            }
        }
        
        return "?,?"
    }
}
