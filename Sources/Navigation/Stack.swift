import Foundation

public protocol Stacking {
    associatedtype Element
    
    func peek() -> Element?
    
    @discardableResult
    mutating func push(_ element: Element) -> Self
    
    @discardableResult
    mutating func pop() -> Element?
}

extension Stacking {
    @inlinable
    public var isEmpty: Bool { peek() == nil }
}

public struct Stack<Element> {
    
    // MARK: - Private properties
    
    /// the top element of the stack is the last in the array
    @usableFromInline
    internal var storage: [Element]
    
    // MARK: - Init
    
    public init(_ initialValues: [Element] = []) {
        storage = initialValues
    }
}

extension Stack: Stacking {
    @inlinable
    public func peek() -> Element? {
        storage.last
    }
    
    @inlinable
    @discardableResult
    public mutating func push(_ element: Element) -> Stack<Element> {
        storage.append(element)
        return self
    }
    
    @inlinable
    @discardableResult
    public mutating func pop() -> Element? {
        storage.popLast()
    }
}

extension Stack {
    @inlinable
    public func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        try storage.reversed().contains(where: predicate)
    }
    
    @inlinable
    @discardableResult
    public mutating func pop(to predicate: (Element) throws -> Bool) rethrows -> [Element]? {
        guard let index = try storage.lastIndex(where: predicate) else { return nil }
        let poppedItems = Array(storage[index+1..<storage.count])
        storage = Array(storage[0...index])
        return poppedItems
    }
}

extension Stack where Element: Equatable {
    @inlinable
    public func contains(_ element: Element) -> Bool {
        storage.reversed().contains(element)
    }
    
    @inlinable
    @discardableResult
    public mutating func pop(to element: Element) -> [Element]? {
        guard let index = storage.lastIndex(of: element) else { return nil }
        let poppedItems = Array(storage[index+1..<storage.count])
        storage = Array(storage[0...index])
        return poppedItems
    }
}

extension Stack: Equatable where Element: Equatable {
    @inlinable
    public static func ==(lhs: Stack<Element>, rhs: Stack<Element>) -> Bool {
        lhs.storage == rhs.storage
    }
}

extension Stack: CustomStringConvertible {
    @inlinable
    public var description: String { "\(storage)" }
}

extension Stack: ExpressibleByArrayLiteral {
    @inlinable
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}
