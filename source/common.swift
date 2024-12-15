import CoreFoundation
import Foundation

func slurp(day: Int, test: Bool) -> String {
    let base = test ? "test" : "real"
    let path = "day\(day)/\(base).txt"
    
    return try! String(contentsOfFile: path, encoding: .utf8).trimmingCharacters(in: .newlines)
}

func slurpLines(day: Int, test: Bool) -> [Substring] {
    var lines = slurp(day: day, test: test).split(separator: "\n", omittingEmptySubsequences: false)
    
    // drop empty, trailing lines
    if lines.last?.isEmpty ?? false {
        lines.removeLast()
    }
    
    return lines
}

func slurpMatrix(day: Int, test: Bool) -> [[Substring.Element]] {
    return slurpLines(day: day, test: test).map {Array($0)}
}

// helper extensions
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Dictionary {
    subscript(key: Key, setDefault defaultValue: @autoclosure () -> Value) -> Value {
        get {
            return self[key] ?? defaultValue()
        }
        set {
            self[key] = newValue
        }
    }
}

// common structs
struct Pos : Hashable {
    let x: Int
    let y: Int
    
    static let zero: Pos = Pos(x: 0, y: 0)
    static let up: Pos = Pos(x: 0, y: -1)
    static let down: Pos = Pos(x: 0, y: 1)
    static let right: Pos = Pos(x: 1, y: 0)
    static let left: Pos = Pos(x: -1, y: 0)
    
    func hash(into h: inout Hasher) {
        h.combine(x)
        h.combine(y)
    }
    
    static func +(lhs: Pos, rhs: Pos) -> Pos {
        return Pos(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

// common enums
enum Direction {
    case up
    case down
    case right
    case left
    
    func step(_ pos: Pos, times: Int = 1) -> Pos {
        switch self {
        case .up: return Pos(x: pos.x, y: pos.y - times)
        case .down: return Pos(x: pos.x, y: pos.y + times)
        case .right: return Pos(x: pos.x + times, y: pos.y)
        case .left: return Pos(x: pos.x - times, y: pos.y)
        }
    }
    
    func turn() -> Direction {
        switch self {
        case .up: return .right
        case .right: return .down
        case .down: return .left
        case .left: return .up
        }
    }
}
