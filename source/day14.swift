import CoreFoundation
import Foundation

struct Robot {
    let pos: Pos
    let vel: Pos
}

enum Quadrant {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

class Day14 {
    var robots: [Robot] = []
    
    let tilesWide = 101
    let tilesHigh = 103
    
    class func run(test: Bool = false) {
        let day = Day14(test: test)
        
        print(day.part1())
        print(day.part2())
    }
    
    init(test: Bool = false) {
        for line in slurpLines(day: 14, test: test) {
            let n = line.matches(of: /-?\d+/).map { Int(line[$0.range])! }
            let pos = Pos(x: n[0], y:n[1])
            let vel = Pos(x: n[2], y: n[3])
            
            robots.append(Robot(pos: pos, vel: vel))
        }
    }
    
    func simulate(_ robot: Robot, _ steps: Int) -> Pos {
        var x = (robot.pos.x + robot.vel.x * steps) % tilesWide
        var y = (robot.pos.y + robot.vel.y * steps) % tilesHigh
        
        if x < 0 { x += tilesWide }
        if y < 0 { y += tilesHigh }
        
        return Pos(x: x, y: y)
    }
    
    func quadrant(_ pos: Pos) -> Quadrant? {
        let xMid = tilesWide / 2
        let yMid = tilesHigh / 2
        
        switch ((pos.x - xMid).signum(), (pos.y - yMid).signum()) {
        case (-1, -1): return .topLeft
        case (1, -1): return .topRight
        case (-1, 1): return .bottomLeft
        case (1, 1): return .bottomRight
        default:
            break
        }
        
        return nil
    }
    
    func drawXMasTree(atStep: Int) -> Bool {
        var picture: [[Character]] = Array(repeating: Array(repeating: ".", count: tilesWide), count: tilesHigh)
        
        let xMid = tilesWide / 2
        let yMid = tilesHigh / 2
        
        for robot in robots {
            let pos = simulate(robot, atStep)
            picture[pos.y][pos.x] = "*"
        }
        
        // is there a vertical line segement somewhere in the middle?
        for x in -20...20 {
            if (-6...6).allSatisfy({ picture[yMid + $0][xMid + x] == "*" }) {
                for row in picture {
                    print(String(row))
                }
                
                return true
            }
        }
        
        return false
    }
    
    func part1() -> Int {
        let quadrants: [Quadrant : Int] = robots
            .compactMap { quadrant(simulate($0, 100)) }
            .reduce(into: [:]) {
                $0[$1] = ($0[$1] ?? 0) + 1
            }
        
        return quadrants.values.reduce(1, *)
    }
    
    func part2() -> Int {
        for i in 1...10000 {
            if drawXMasTree(atStep: i) {
                return i
            }
        }
        
        return 0
    }
}
