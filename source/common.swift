import CoreFoundation
import Foundation

func slurp(day: Int, test: Bool) -> String {
    let base = test ? "test" : "real"
    let path = "day\(day)/\(base).txt"
    
    return try! String(contentsOfFile: path, encoding: .utf8)
}

func slurpLines(day: Int, test: Bool) -> [Substring] {
    return slurp(day: day, test: test).split(separator: "\n", omittingEmptySubsequences: false)
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
