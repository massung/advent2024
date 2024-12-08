import CoreFoundation
import Foundation

class Day8 {
    var towers: [Substring.Element : [Pos]] = [:]
    var width: Int = 0
    var height: Int = 0
    
    class func run(test: Bool = false) {
        let day = Day8(test: test)
        
        print(day.part1())
        print(day.part2())
    }
    
    init(test: Bool = false) {
        for (y, line) in slurpLines(day: 8, test: test).enumerated() {
            width = line.count
            height += 1
            
            for (x, c) in line.enumerated() {
                if c != "." {
                    towers[c, setDefault: []].append(Pos(x: x, y: y))
                }
            }
            
            // sort all the towers by X coordinate
            towers = towers.mapValues() {
                $0.sorted(by:) { $0.x < $1.x }
            }
        }
    }
    
    func inBounds(_ pos: Pos) -> Bool {
        return pos.x >= 0 && pos.y >= 0 && pos.x < width && pos.y < height
    }
    
    func pairs(_ towers: [Pos]) -> [(Pos, Pos)] {
        var pairs: [(Pos, Pos)] = []
        
        // pairs are always in the order of (LEFT, RIGHT)
        for a in 0..<towers.count - 1 {
            for b in a+1..<towers.count {
                pairs.append((towers[a], towers[b]))
            }
        }
        
        return pairs
    }
    
    func antinodes(_ towers: [Pos]) -> Set<Pos> {
        var positions = Set<Pos>()
        
        for (a, b) in pairs(towers) {
            let dx = b.x - a.x
            let dy = b.y - a.y
            
            positions.insert(Pos(x: a.x-dx, y: a.y-dy))
            positions.insert(Pos(x: b.x+dx, y: b.y+dy))
        }
        
        // remove positions not in bounds
        return positions.filter() { inBounds($0) }
    }
    
    func resonatingAntinodes(_ towers: [Pos]) -> Set<Pos> {
        var positions = Set<Pos>()
        
        for (a, b) in pairs(towers) {
            let dx = b.x - a.x
            let dy = b.y - a.y
            
            // loop from B -> A adding antinodes
            for i in 1... {
                let na = Pos(x: a.x - dx*i, y: a.y - dy*i)
                let nb = Pos(x: b.x + dx*i, y: b.y + dy*i)
                
                let (inA, inB) = (inBounds(na), inBounds(nb))
                
                if inA { positions.insert(na) }
                if inB { positions.insert(nb) }
                
                if !(inA || inB) {
                    break // compleete off map in both directions
                }
            }
        }
        
        // are all these towers also antinodes?
        if towers.count > 2 {
            positions.formUnion(towers)
        }
        
        // remove positions not in bounds
        return positions.filter() { inBounds($0) }
    }
    
    func part1() -> Int {
        var antinodePositions = Set<Pos>()
        
        for towerPositions in towers.values {
            for antinodePosition in antinodes(towerPositions) {
                antinodePositions.insert(antinodePosition)
            }
        }
        
        return antinodePositions.count
    }
    
    func part2() -> Int {
        var antinodePositions = Set<Pos>()
        
        for towerPositions in towers.values {
            for antinodePosition in resonatingAntinodes(towerPositions) {
                antinodePositions.insert(antinodePosition)
            }
        }
        
        return antinodePositions.count
    }
}
