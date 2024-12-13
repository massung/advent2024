import CoreFoundation
import Foundation

struct PrizeMachine {
    let a, b, prize: Pos
}

class Day13 {
    var machines: [PrizeMachine] = []
    
    class func run(test: Bool = false) {
        let day = Day13(test: test)
        
        print(day.part1())
        print(day.part2())
    }
    
    init(test: Bool = false) {
        var a: Pos = .zero
        var b: Pos = .zero
        
        for line in slurpLines(day: 13, test: test) {
            let numbers = line.matches(of: /\d+/).map { Int(line[$0.range])! }
            
            if numbers.count == 2 {
                if line.starts(with: "Button A:") {
                    a = Pos(x: numbers[0], y: numbers[1])
                } else if line.starts(with: "Button B:") {
                    b = Pos(x: numbers[0], y: numbers[1])
                } else {
                    let prize = Pos(x: numbers[0], y: numbers[1])
                    
                    // create a new machine
                    machines.append(PrizeMachine(a: a, b: b, prize: prize))
                }
            }
        }
    }
    
    func solve(_ machine: PrizeMachine, offset: Int = 0) -> (Int, Int)? {
        // This is just a pair of linear equations. For example, from the test data:
        //
        // 94a + 22b = 8400 = x
        // 34a + 67b = 5400 = y
        //
        // Since these are linear equations, there should only be a single intersection
        // unless the lines are parallel. And we only care about an intersection if
        // both A and B are positive, whole numbers.
        
        let X = machine.prize.x + offset  // 8400
        let Y = machine.prize.y + offset  // 5400
        
        let xA = machine.a.x  // 94
        let yA = machine.a.y  // 34
        let xB = machine.b.x  // 22
        let yB = machine.b.y  // 67
        
        // Solving for A (button presses)...
        //
        // X = (xA * A) + (xB * B)
        //
        // A = [X - (xB * B)] / xA
        //
        // Substituting...
        //
        // Y = (yA * A) + (yB * B)
        //
        //
        //          X - (xB * B)
        // Y = yA * ------------ + (yB * B)
        //               xA
        //
        //
        //     (yA * X) - (yA * xB * B)
        // Y = ------------------------ + (yB * B)
        //               xA
        //
        //
        //     (yA * X) - (yA * xB * B)   xA * yB * B
        // Y = ------------------------ + -----------
        //                xA                   xA
        //
        //
        //     (yA * X) - (yA * xB * B) + (xA * yB * B)
        // Y = ----------------------------------------
        //                       xA
        //
        //
        //     (yA * X) + [(xA * yB) - (yA * xB)] * B
        // Y = --------------------------------------
        //                      xA
        //
        //
        //      (Y * xA) + (yA * X)
        // B = ---------------------
        //     (xA * yB) - (yA * xB)
        //
        //
        // Solve for # of B presses, then # of A presses...
        
        let B = ((Y * xA) - (yA * X)) / ((xA * yB) - (yA * xB))
        let A = (X - (xB * B)) / xA
        
        // verify the solution
        if A < 0 || B < 0 || (xA * A) + (xB * B) != X || (yA * A) + (yB * B) != Y {
            return nil
        }

        // number of presses for each button
        return (A, B)
    }
    
    func solveMachine(_ machine: PrizeMachine, offset: Int = 0) -> Int {
        return solve(machine, offset: offset).map { $0.0 * 3 + $0.1 } ?? 0
    }
    
    func part1() -> Int {
        return machines.reduce(0) { $0 + solveMachine($1) }
    }
    
    func part2() -> Int {
        return machines.reduce(0) { $0 + solveMachine($1, offset: 10000000000000) }
    }
}
