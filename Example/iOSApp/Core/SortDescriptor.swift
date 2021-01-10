//
//  SortDescriptor.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/4/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
// http://chris.eidhof.nl/post/sort-descriptors-in-swift/

import Foundation

typealias SortDescriptor<Value> = (Value, Value) -> Bool

func sortDescriptor<Value, Key>(key: @escaping (Value) -> Key,
                                _ isOrderedBefore: @escaping (Key, Key) -> Bool) -> SortDescriptor<Value> {
    return {
        print("func sortDescriptor<Value, Key>(key: @escaping (Value) -> Key, _ isOrderedBefore: @escaping (Key, Key) -> Bool) -> SortDescriptor<Value>")
        return isOrderedBefore(key($0), key($1)) }
}

func sortDescriptor<Value, Key>(key: @escaping (Value) -> Key) -> SortDescriptor<Value> where Key: Comparable {
    return {
        print("sortDescriptor<Value, Key>(key: @escaping (Value) -> Key) -> SortDescriptor<Value> where Key: Comparable")
        return key($0) < key($1) }
}

func sortDescriptor<Value, Key>(key: @escaping (Value) -> Key,
                                ascending: Bool = true,
                                _ comparator: @escaping (Key) -> (Key) -> ComparisonResult) -> SortDescriptor<Value> {
    return { lhs, rhs in
        print("\(lhs) String \(rhs)")
        let order: ComparisonResult = ascending ? .orderedAscending : .orderedDescending
        return comparator(key(lhs))(key(rhs)) == order
    }
}

func sortDescriptor<Value>(key: @escaping (Value) -> Bool,
                           ascending: Bool = true) -> SortDescriptor<Value> {
    return { lhs, rhs in
        print("%@ Bool %@", lhs, rhs)
        if ascending && key(lhs) == true && key(rhs) == false {
            return false
        }
        else if !ascending && key(lhs) == false && key(rhs) == true {
            return false
        }
        else {
            return true
        }
    }
}

func combine<Value>(sortDescriptors: [SortDescriptor<Value>]) -> SortDescriptor<Value> {
    return { lhs, rhs in
        print("\n=======================================================")
        for isOrdered in sortDescriptors {
            if isOrdered(lhs,rhs) { return true }
            if isOrdered(rhs,lhs) { return false }
        }
        return false
    }
}

func lift<A>(_ compare: @escaping (A) -> (A) -> ComparisonResult) -> (A?) -> (A?) -> ComparisonResult {
    return { lhs in { rhs in
        switch (lhs, rhs) {
        case (nil, nil): return .orderedSame
        case (nil, _): return .orderedAscending
        case (_, nil): return .orderedDescending
        case let (l?, r?): return compare(l)(r)
        default: fatalError() // Impossible case
        }
    } }
}
