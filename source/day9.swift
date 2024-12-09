import CoreFoundation
import Foundation

class Node {
    var pos: Int
    var size: Int
    var fileId: Int? = nil
    
    // linked list pointers
    var next: Node? = nil
    var prev: Node? = nil
    
    init(size: Int, fileId: Int? = nil, appendTo prev: Node? = nil) {
        self.pos = (prev?.pos ?? 0) + (prev?.size ?? 0)
        self.fileId = fileId
        self.size = size
        self.next = prev?.next
        self.prev = prev
        
        // insert into a linked list
        prev?.next?.prev = self
        prev?.next = self
    }
    
    func nextEmpty(minSize: Int = 1, before: Int = .max) -> Node? {
        if pos >= before {
            return nil
        }
        
        // find the next empty node large enough
        return (fileId == nil && size >= minSize) ? self : next?.nextEmpty(minSize: minSize, before: before)
    }
    
    func prevFile() -> Node? {
        return (fileId != nil && size > 0) ? self : prev?.prevFile()
    }
    
    func insert(fileId: Int, size fileSize: Int) -> Node {
        assert(self.fileId == nil && self.size >= fileSize)
        
        // create a new node for the file
        let newNode = Node(size: fileSize, fileId: fileId, appendTo: prev)
        
        // reduce the size of this block
        size -= fileSize
        
        return newNode
    }
}

class Day9 {
    var disk: Node? = nil
    var lastNode: Node? = nil
    var fileSizes: [Int : Int] = [:]
    
    class func run(test: Bool = false) {
        print(Day9(test: test).part1())
        print(Day9(test: test).part2())
    }
    
    init(test: Bool = false) {
        let zero: UInt8 = Character("0").asciiValue!
        let inputString = slurp(day: 9, test: test)
        let inputData: Data = inputString.data(using: .ascii)!
        
        // build the disk nodes linked list
        for (fileId, i) in stride(from: 0, to: inputData.count, by: 2).enumerated() {
            let fileNode = Node(size: Int(inputData[i] - zero), fileId: fileId, appendTo: lastNode)

            // create the root disk file node
            if disk == nil {
                disk = fileNode
            }
            
            // update the tail pointer
            lastNode = fileNode
            
            // add the empty space after the file
            if inputData.count > i + 1 {
                lastNode = Node(size: Int(inputData[i+1] - zero), appendTo: fileNode)
            }
        }
    }
    
    func debugDisk() {
        var node: Node? = disk
        
        while node != nil {
            for _ in 0..<node!.size {
                print(node?.fileId ?? ".", terminator: "")
            }
            
            node = node?.next
        }
        
        print()
    }
    
    func checksum() -> Int {
        var sum: Int = 0
        var pos: Int = 0
        var node: Node? = disk

        while node != nil {
            for _ in 0..<node!.size {
                sum += (node?.fileId ?? 0) * pos
                pos += 1
            }
            
            // advance
            node = node?.next
        }
        
        return sum
    }
    
    func part1() -> Int {
        var emptyNode = disk?.nextEmpty()
        var fileNode = lastNode
        
        while let empty = emptyNode, let file = fileNode {
            if empty.pos >= file.pos {
                break
            }
            
            // create a new file node before the empty block
            let n = min(empty.size, file.size)
            let newFile = empty.insert(fileId: file.fileId!, size: n)
        
            // the empty node has no space free, find the next empty node
            if empty.size == 0 {
                emptyNode = newFile.nextEmpty()
            }
            
            // decrease the size of the moved file
            file.size -= n
            
            // if the file was moved completely, then find the previous one
            if file.size == 0 {
                fileNode = file.prevFile()
            }
        }
        
        return checksum()
    }
    
    func part2() -> Int {
        var fileNode = lastNode?.prevFile()
        
        while let file = fileNode {
            if let empty = disk?.nextEmpty(minSize: file.size, before: file.pos) {
                _ = empty.insert(fileId: file.fileId!, size: file.size)
                
                // free the space where the file was
                file.fileId = nil
            }
            
            // find the next file
            fileNode = file.prev?.prevFile()
        }
        
        return checksum()
    }
}
