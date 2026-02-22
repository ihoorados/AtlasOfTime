import Foundation

actor LRUCache<Key: Hashable & Sendable, Value: Sendable> {
    private final class Node {
        let key: Key
        var value: Value
        var previous: Node?
        var next: Node?

        init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
    }

    private let capacity: Int
    private var nodesByKey: [Key: Node] = [:]
    private var head: Node?
    private var tail: Node?

    init(capacity: Int) {
        self.capacity = max(1, capacity)
    }

    func value(for key: Key) -> Value? {
        guard let node = nodesByKey[key] else { return nil }
        moveToHead(node)
        return node.value
    }

    func setValue(_ value: Value, for key: Key) {
        if let node = nodesByKey[key] {
            node.value = value
            moveToHead(node)
            return
        }

        let node = Node(key: key, value: value)
        nodesByKey[key] = node
        insertAtHead(node)

        if nodesByKey.count > capacity, let nodeToEvict = tail {
            remove(nodeToEvict)
            nodesByKey[nodeToEvict.key] = nil
        }
    }

    func removeAll() {
        nodesByKey.removeAll()
        head = nil
        tail = nil
    }

    private func insertAtHead(_ node: Node) {
        node.previous = nil
        node.next = head
        head?.previous = node
        head = node

        if tail == nil {
            tail = node
        }
    }

    private func moveToHead(_ node: Node) {
        guard head !== node else { return }
        remove(node)
        insertAtHead(node)
    }

    private func remove(_ node: Node) {
        let previous = node.previous
        let next = node.next

        previous?.next = next
        next?.previous = previous

        if head === node { head = next }
        if tail === node { tail = previous }

        node.previous = nil
        node.next = nil
    }
}
