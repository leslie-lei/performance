//: Playground - noun: a place where people can play

import Foundation
import QuartzCore

func splitWithBufferPointer() {
    var bytes: [UInt8] = []
    bytes.reserveCapacity(32)

    for _ in 0..<8 {
        let rand: UInt32 = arc4random()

        var bigEndian = rand.bigEndian
        let count = MemoryLayout<UInt32>.size
        let bytePtr = withUnsafePointer(to: &bigEndian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }

        bytePtr.map({ (byte) in
            let remainder = byte % 16
            if remainder < 10 {
                bytes.append(UInt8(remainder + 48)) // 48 - 57 (0-9)
            } else {
                bytes.append(UInt8(remainder + 87)) // 97 - 102 (a-f)
            }
        })
    }
}

func splitWithBitmaskManual() {
    var bytes: [UInt8] = []
    bytes.reserveCapacity(32)

    for _ in 0..<8 {
        let rand: UInt32 = arc4random()

        let first = UInt8(truncatingBitPattern: rand)
        let second = UInt8(truncatingBitPattern: rand >> 8)
        let third = UInt8(truncatingBitPattern: rand >> 16)
        let fourth = UInt8(truncatingBitPattern: rand >> 24)

        let four = [first, second, third, fourth]

        for byte in four {
            let remainder = byte % 16
            if remainder < 10 {
                bytes.append(UInt8(remainder + 48)) // 48 - 57 (0-9)
            } else {
                bytes.append(UInt8(remainder + 87)) // 97 - 102 (a-f)
            }
        }
    }
}

func splitWithBitmaskLoop() {
    var bytes: [UInt8] = []
    bytes.reserveCapacity(32)

    for _ in 0..<8 {
        let rand: UInt32 = arc4random()

        let byteArray = stride(from: 24, to: 0, by: -8).map {
            UInt8(truncatingBitPattern: rand >> UInt32($0))
        }

        for byte in byteArray {
            let remainder = byte % 16
            if remainder < 10 {
                bytes.append(UInt8(remainder + 48)) // 48 - 57 (0-9)
            } else {
                bytes.append(UInt8(remainder + 87)) // 97 - 102 (a-f)
            }
        }
    }
}

var res: [Int:[Double]] = [0: [], 1: [], 2: []]

func run_one() {
    let start = CACurrentMediaTime()
    for _ in 0...1000 {
        splitWithBufferPointer()
    }

    let end = CACurrentMediaTime()
    res[0]?.append(end-start)
}

func run_two() {
    let start = CACurrentMediaTime()
    for _ in 0...1000 {
        splitWithBitmaskManual()
    }

    let end = CACurrentMediaTime()
    res[1]?.append(end-start)
}

func run_three() {
    let start = CACurrentMediaTime()
    for _ in 0..<1000 {
        splitWithBitmaskLoop()
    }

    let end = CACurrentMediaTime()
    res[2]?.append(end-start)
}

// Run 10 tries, each function 1K times.
for _ in 0..<10 {
    run_one()
    run_two()
    run_three()
}

extension Array where Element: FloatingPoint {
    /// Returns the sum of all elements in the array
    var total: Element {
        return reduce(0, +)
    }
    /// Returns the average of all elements in the array
    var average: Element {
        return isEmpty ? 0 : total / Element(count)
    }
}

let one = res[0]?.average
let two = res[1]?.average
let three = res[2]?.average

print("one: \(one); two: \(two); three: \(three)")
// one: Optional(24.956257089088798); two: Optional(19.863341977904465); three: Optional(13.57245378646026)


