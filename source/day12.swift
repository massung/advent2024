import CoreFoundation
import Foundation

enum Edge: CaseIterable {
    case up
    case down
    case right
    case left
}

typealias EdgeSet = Set<Edge>

class Day12 {
    var garden: [[Character]] = []
    var plots: [Character : Set<Pos>] = [:]
    
    let DIRECTIONS: [(Int, Int, Edge)] = [
        (0, -1, .up),
        (0, 1, .down),
        (1, 0, .right),
        (-1, 0, .left),
    ]
    
    class func run(test: Bool = false) {
        let day = Day12(test: test)
        
        print(day.part1())
        print(day.part2())
    }
    
    init(test: Bool = false) {
        garden = slurpMatrix(day: 12, test: test)
        
        // create a mapping of plot -> positions
        for (y, row) in garden.enumerated() {
            for (x, c) in row.enumerated() {
                plots[c, setDefault: Set()].insert(Pos(x: x, y: y))
            }
        }
    }
    
    func inGarden(_ x: Int, _ y: Int) -> Bool {
        return x >= 0 && y >= 0 && y < garden.count && x < garden[y].count
    }
    
    func getPlot(_ x: Int, _ y: Int) -> Character {
        return inGarden(x, y) ? garden[y][x] : "."
    }
    
    func getNeighbors(_ pos: Pos) -> [Pos] {
        return DIRECTIONS.map { Pos(x: pos.x + $0.0, y: pos.y + $0.1) }
    }
    
    func getNeighbors(_ pos: Pos, forPlot plot: Character) -> [Pos] {
        return getNeighbors(pos).filter { getPlot($0.x, $0.y) == plot }
    }
    
    func getNeighbors(_ pos: Pos, inSet: Set<Pos>) -> [Pos] {
        return getNeighbors(pos).filter { inSet.contains($0) }
    }
    
    func getRegions(_ plot: Character) -> [Set<Pos>] {
        var regions: [Set<Pos>] = []
        
        // use flood-fill to find adjacent tiles
        if let positions = plots[plot] {
            var remaining = Set(positions)
            
            while let pos = remaining.popFirst() {
                var region = Set([pos])
                var queue = Set([pos])

                while let nextPos = queue.popFirst() {
                    for neighbor in getNeighbors(nextPos, forPlot: plot) {
                        if remaining.contains(neighbor) {
                            region.insert(neighbor)
                            queue.insert(neighbor)
                            remaining.remove(neighbor)
                        }
                    }
                }
                    
                // add the new region to the list
                regions.append(region)
            }
        }
        
        return regions
    }
    
    func edgesOfRegion(region: Set<Pos>, plot: Character) -> [Pos : EdgeSet] {
        var edges: [Pos : EdgeSet] = [:]
        
        for pos in region {
            var set = EdgeSet([])
            
            for (dx, dy, edge) in DIRECTIONS {
                if getPlot(pos.x + dx, pos.y + dy) != plot {
                    set.insert(edge)
                }
            }

            // only add the position if it has edges
            if set.count > 0 {
                edges[pos] = set
            }
        }
        
        return edges
    }
    
    func sidesOfEdges(edges regionEdges: [Pos : EdgeSet], plot: Character) -> [Set<Pos>] {
        var sides: [Set<Pos>] = []
        
        for edge in Edge.allCases {
            var remaining = Set(regionEdges.filter({ $0.value.contains(edge) }).keys)
            
            while let pos = remaining.popFirst() {
                var side = Set([pos])
                var queue = Set([pos])
                
                // find all neighbors with an edge along the same direction
                while let nextPos = queue.popFirst() {
                    for neighbor in getNeighbors(nextPos, inSet: remaining) {
                        if !side.contains(neighbor) {
                            side.insert(neighbor)
                            queue.insert(neighbor)
                            remaining.remove(neighbor)
                        }
                    }
                }
                
                sides.append(side)
            }
        }
        
        return sides
    }
    
    func costOfPlot(_ plot: Character) -> Int {
        return getRegions(plot).reduce(0) {
            let area = $1.count
            let perimeter = edgesOfRegion(region: $1, plot: plot).values.reduce(0) { $0 + $1.count }
            
            return $0 + area * perimeter
        }
    }
    
    func discountedCostOfPlot(_ plot: Character) -> Int {
        return getRegions(plot).reduce(0) {
            let area = $1.count
            let edges = edgesOfRegion(region: $1, plot: plot)
            let sides = sidesOfEdges(edges: edges, plot: plot)
            
            return $0 + area * sides.count
        }
    }
    
    func part1() -> Int {
        return plots.keys.reduce(0) { $0 + costOfPlot($1) }
    }
    
    func part2() -> Int {
        return plots.keys.reduce(0) { $0 + discountedCostOfPlot($1) }
    }
}
