import CoreFoundation
import Foundation

enum WarehouseObject {
    case wall
    case box
    case boxLeft
    case boxRight
}

class Day15 {
    var warehouse: [Substring] = []
    var movements: [Direction] = []
    
    let DIRECTIONS: [Character : Direction] = ["^": .up, "v": .down, ">": .right, "<": .left]
    
    var state: [Pos : WarehouseObject] = [:]
    var robot: Pos = .zero
    var scale: Int = 1

    class func run(test: Bool = false) {
        let day = Day15(test: test)
        
        print(day.part1())
        print(day.part2())
    }
    
    init(test: Bool = false) {
        for line in slurpLines(day: 15, test: test) {
            switch line.first {
            case "#":
                warehouse.append(line)
            case "<", ">", "v", "^":
                movements += line.map { DIRECTIONS[$0]! }
            default:
                break
            }
        }
    }
    
    func resetState(withScale: Int = 1) {
        state.removeAll()

        // set the scale to use
        scale = withScale
        
        // fill in the map state
        for (y, row) in warehouse.enumerated() {
            for (x, c) in row.enumerated() {
                let pos = Pos(x: x * scale, y: y)
                let nextPos = Pos(x: x * scale + 1, y: y)
                
                switch c {
                case "#":
                    state[pos] = .wall
                    
                    if scale > 1 {
                        state[nextPos] = .wall
                    }
                case "O":
                    if scale == 1 {
                        state[pos] = .box
                    } else {
                        state[pos] = .boxLeft
                        state[nextPos] = .boxRight
                    }
                case "@":
                    robot = pos
                default:
                    break
                }
            }
        }
    }
    
    func boxesToPush(_ direction: Direction) -> Set<Pos>? {
        var boxes: Set<Pos> = Set()
        var queue: Set<Pos> = Set([robot])
         
        // If moving up/down, then it's possible to have a single push affect
        // many boxes horizontally, and there can be space between boxes
        //
        //   [][]..[]
        //    []..[]
        //     [][]
        //      []
        //      @    ^
        //
        // So we have to keep track of every "box" being pushed individaully.
        
        // loop until the box queue is empty or there is a wall
        while let pos = queue.popFirst() {
            let nextPos = direction.step(pos)
            
            if state[pos] != nil {
                boxes.insert(pos)
            }
            
            switch state[nextPos] {
            case .wall:
                return nil
            case .box:
                queue.insert(nextPos)
            case .boxLeft:
                queue.insert(nextPos)
                
                if direction == .up || direction == .down {
                    queue.insert(nextPos + .right)
                }
            case .boxRight:
                queue.insert(nextPos)
                
                if direction == .up || direction == .down {
                    queue.insert(nextPos + .left)
                }
            default:
                break
            }
        }

        return boxes
    }
    
    func step(_ direction: Direction) {
        guard let boxes = boxesToPush(direction) else {
            return
        }
        
        // the objects that were moved
        var shift: [Pos : WarehouseObject] = [:]
        
        // clear all the positions from the state
        for pos in boxes {
            shift[pos] = state.removeValue(forKey: pos)
        }
        
        // re-add them, but shifted
        for pos in boxes {
            state[direction.step(pos)] = shift[pos]
        }

        // update the robot's position
        robot = direction.step(robot)
    }
    
    func printMap() {
        for y in warehouse.indices {
            let width = warehouse[y].count * scale
            
            for x in 0..<width {
                let pos = Pos(x: x, y: y)
                
                if robot == pos {
                    print("@", terminator: "")
                } else {
                    switch state[pos] {
                    case .wall:
                        print("#", terminator: "")
                    case .box:
                        print("O", terminator: "")
                    case .boxLeft:
                        print("[", terminator: "")
                    case .boxRight:
                        print("]", terminator: "")
                    default:
                        print(".", terminator: "")
                    }
                }
            }
            
            print()
        }
    }
    
    func gpsCoordinates() -> Int {
        var score = 0
        
        for (pos, object) in state {
            if object == .box || object == .boxLeft {
                score += pos.y * 100 + pos.x
            }
        }

        return score
    }
    
    func part1() -> Int {
        resetState()
        //printMap()
        
        for direction in movements {
            step(direction)
            //printMap()
        }
        
        return gpsCoordinates()
    }
    
    func part2() -> Int {
        resetState(withScale: 2)
        //printMap()
        
        for direction in movements {
            step(direction)
            //printMap()
        }
        
        return gpsCoordinates()
    }
}
