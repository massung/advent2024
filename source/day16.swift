import CoreFoundation
import Foundation

enum PathAction : CaseIterable {
    case walkForward
    case walkLeft
    case walkRight
    
    func cost() -> Int {
        self == .walkForward ? 1 : 1001  // turn + walkForward
    }
}

class Path {
    let pos: Pos
    let dir: Direction
    let cost: Int
    let path: Set<Pos>
    
    init(pos: Pos, dir: Direction, cost: Int = 0, from: Path? = nil) {
        self.pos = pos
        self.dir = dir
        self.cost = cost
        self.path = (from?.path ?? Set()).union([pos])
    }
}

class Day16 {
    var matrix: [[Character]] = []
    var startPos: Pos = .zero
    var endPos: Pos = .zero
    
    class func run(test: Bool = false) {
        let day = Day16(test: test)
        let solutions = day.solve()
        
        print(day.part1(solutions))
        print(day.part2(solutions))
    }
    
    init(test: Bool = false) {
        matrix = slurpMatrix(day: 16, test: test)
        
        // start and end are always at the same location
        startPos = Pos(x: 1, y: matrix.indices.last! - 1)
        endPos = Pos(x: matrix[1].indices.last! - 1, y: 1)
    }
    
    func solve() -> [Path] {
        let initialPath = Path(pos: startPos, dir: .right)
        
        var queue: [Path] = [initialPath]
        var visited: [State : Int] = [State(pos: startPos, dir: .right): 0]
        var solutions: [Path] = []
        
        // search every possible space and find the minimum cost to get there
        while let path = queue.popLast() {
            let pos = path.pos
            let dir = path.dir
            let best = solutions.first?.cost ?? .max
            let state = State(pos: pos, dir: dir)
            
            // has this position + direction already been visited?
            if let cost = visited[state] {
                if path.cost > cost {
                    continue
                }
            }
            
            // update the visited state with a better cost
            visited[state] = path.cost
            
            // has the goal been reached?
            if pos == endPos {
                if path.cost < best  {
                    solutions = [path]
                } else if path.cost == best {
                    solutions.append(path)
                }
                
                continue
            }
            
            // if the cost of this path is too high, stop
            if path.cost > best {
                continue
            }
            
            // try and walk in all directions
            for action in PathAction.allCases {
                let cost = path.cost + action.cost()
                let nextDir = action == .walkForward ? dir : dir.turn(ccw: action == .walkLeft)
                let nextPos = nextDir.step(pos)
                
                // is it possible to move there?
                if matrix[nextPos.y][nextPos.x] != "#" {
                    queue.append(Path(pos: nextPos, dir: nextDir, cost: cost, from: path))
                }
            }
            
            // sort the queue and search cheaper paths first
            queue.sort(by:) { $0.cost > $1.cost }
        }
        
        return solutions
    }
    
    func part1(_ solutions: [Path]) -> Int {
        return solutions.first?.cost ?? 0
    }
    
    func part2(_ solutions: [Path]) -> Int {
        return solutions.reduce(Set()) { $0.union($1.path) }.count
    }
}
