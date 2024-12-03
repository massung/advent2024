import CoreFoundation
import Foundation

func slurp(day: Int, test: Bool) -> String {
    let base = test ? "test" : "real"
    let path = "day\(day)/\(base).txt"
    
    return try! String(contentsOfFile: path, encoding: .utf8)
}

func slurpLines(day: Int, test: Bool) -> [Substring] {
    slurp(day: day, test: test).split(separator: "\n", omittingEmptySubsequences: true)
}
