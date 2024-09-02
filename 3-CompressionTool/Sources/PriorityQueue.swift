//
//  PriorityQueue.swift
//
//
//  Created by Eswaramurthi, Arun on 29/08/24.
//

import Foundation

// A queue that adds the element based on priority and is always sorted
class PriorityQueue<T> where T:Nodable {
    private var values: Array<T>
    
    init(values: Array<T>) {
        self.values = values.sorted(by: {
            $0.weight < $1.weight
        })
    }
    
    var count: Int {
        values.count
    }
    
    func dequeue() -> T {
        return self.values.removeFirst()
    }
    
    func enqueue(_ element: T) {
        var indexToInsert = values.count
        for (index, value) in values.enumerated() {
            if value.weight > element.weight {
                indexToInsert = index
                break
            }
        }
        
        self.values.insert(element, at: indexToInsert)
    }
}
