@testable import Navigation
import XCTest

final class StackTests: XCTestCase {
    func testPeek() {
        var input: Stack<Int> = [1]
        var output = input.peek()
        var expected = 1
        XCTAssertEqual(output, expected)
        input.push(2)
        output = input.peek()
        expected = 2
        XCTAssertEqual(output, expected)
    }
    
    func testPush() {
        var input: Stack<Int> = []
        var output = input.push(1)
        var expected = Stack<Int>([1])
        XCTAssertEqual(output, expected)
        output.push(2)
        expected = Stack<Int>([1,2])
        XCTAssertEqual(output, expected)
    }
    
    func testPop() {
        var input: Stack<Int> = [1, 2]
        var output = input.pop()
        var expected = 2
        XCTAssertEqual(output, expected)
        output = input.pop()
        expected = 1
        XCTAssertEqual(output, expected)
    }
    
    func testIsEmpty() {
        var input: Stack<Int> = [1]
        var output = input.isEmpty
        var expected = false
        XCTAssertEqual(output, expected)
        input.pop()
        output = input.isEmpty
        expected = true
        XCTAssertEqual(output, expected)
    }
    
    func testContainsWhere() {
        let stack: Stack<Int> = [1, 2, 3]
        XCTAssert(stack.contains(where: { $0 == 2 }))
        XCTAssertFalse(stack.contains(where: { $0 == 4 }))
    }
    
    func testPopToPredicate() {
        let expectedStack: Stack<Int> = [1, 2]
        var actualStack: Stack<Int> = [1, 2, 3, 4]
        XCTAssertNotEqual(expectedStack, actualStack)
        actualStack.pop(to: { $0 == 2 })
        XCTAssertEqual(expectedStack, actualStack)
    }
    
    func testContainsElement() {
        let stack: Stack<Int> = [1, 2, 3]
        XCTAssert(stack.contains(2))
        XCTAssertFalse(stack.contains(4))
    }
    
    func testPopToElement() {
        let expectedStack: Stack<Int> = [1, 2]
        var actualStack: Stack<Int> = [1, 2, 3, 4]
        XCTAssertNotEqual(expectedStack, actualStack)
        actualStack.pop(to: 2)
        XCTAssertEqual(expectedStack, actualStack)
    }
    
    func testEqual() {
        let expectedStack: Stack<Int> = [1, 2, 3]
        var actualStack: Stack<Int> = [1, 2]
        XCTAssertNotEqual(expectedStack, actualStack)
        actualStack.push(3)
        XCTAssertEqual(expectedStack, actualStack)
    }
    
    func testDescription() {
        var input: Stack<Int> = [1]
        var output = input.description
        var expected = "[1]"
        XCTAssertEqual(output, expected)
        input.pop()
        output = input.description
        expected = "[]"
        XCTAssertEqual(output, expected)
    }
    
    func testInitByArrayLiteral() {
        let stack: Stack<Int> = [1, 2, 3]
        XCTAssertEqual(3, stack.peek())
    }
    
    static let allTests = [
        ("testPeek", testPeek),
        ("testPush", testPush),
        ("testPop", testPop),
        ("testIsEmpty", testIsEmpty),
        ("testContainsWhere", testContainsWhere),
        ("testPopToPredicate", testPopToPredicate),
        ("testContainsElement", testContainsElement),
        ("testPopToElement", testPopToElement),
        ("testEqual", testEqual),
        ("testDescription", testDescription),
        ("testInitByArrayLiteral", testInitByArrayLiteral)
    ]
}
