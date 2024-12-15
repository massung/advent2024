import CoreFoundation
import Foundation

struct State : Hashable {
    let pos: Pos
    let dir: Direction
    
    func hash(into h: inout Hasher) {
        h.combine(pos)
        h.combine(dir)
    }
}

enum WalkError : Error {
    case loop
}

class Day6 {
    var obstacles: Set<Pos> = Set()
    var initialState: State = State(pos: Pos(x: 0, y: 0), dir: .up)
    var width: Int = 0
    var height: Int = 0
    
    class func run(test: Bool = false) {
        let day = Day6(test: test)
        
        print(day.part1())
        print(day.part2())
    }
    
    init(test: Bool = false) {
        let lines = slurpLines(day: 6, test: test)
        
        // dimensions
        height = lines.count
        width = lines[0].count
    
        // find all obstacles and the start position
        for (y, line) in lines.enumerated() {
            for (x, c) in line.enumerated() {
                switch c {
                case "#":
                    obstacles.insert(Pos(x: x, y: y))
                case "^":
                    initialState = State(pos: Pos(x: x, y: y), dir: .up)
                default:
                    break
                }
            }
        }
    }
    
    func outOfBounds(_ pos: Pos) -> Bool {
        return pos.x < 0 || pos.y < 0 || pos.x >= width || pos.y >= height
    }
    
    func walk(_ state: State) -> State? {
        let newPos = state.dir.step(state.pos)
        
        if outOfBounds(newPos) {
            return nil
        }

        if obstacles.contains(newPos) {
            return State(pos: state.pos, dir: state.dir.turn())
        }
        
        return State(pos: newPos, dir: state.dir)
    }
    
    func makePath(_ fromState: State) throws(WalkError) -> Set<State> {
        var state = fromState
        var path = Set<State>([state])
        
        while let nextState = walk(state) {
            state = nextState
            
            if path.contains(state) {
                throw WalkError.loop
            }
            
            path.insert(state)
        }
        
        return path
    }
    
    func part1() -> Int {
        var visited: Set<Pos> = Set()
        
        // get all the unique positions in the history
        for state in try! makePath(initialState) {
            visited.insert(state.pos)
        }
        
        return visited.count
    }
    
    func part2() -> Int {
        var obstaclePositions: Set<Pos> = Set()
        
        // walk the actual path and try and insert obstacles
        for state in try! makePath(initialState) {
            if state.pos == initialState.pos {
                continue
            }
            
            // add an obstacle at this position
            obstacles.insert(state.pos)

            // was there a loop?
            if (try? makePath(initialState)) == nil {
                obstaclePositions.insert(state.pos)
            }
            
            // remove the obstacle
            obstacles.remove(state.pos)
        }

        return obstaclePositions.count
    }
}
