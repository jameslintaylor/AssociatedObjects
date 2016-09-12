//
//  AssociatedObjects.swift
//  AssociatedObjects
//
//  Created by James Taylor on 2016-08-31.
//  Copyright © 2016 James Taylor. All rights reserved.
//

import Foundation

public enum AssociationPolicy: UInt {
    // raw values map to objc_AssociationPolicy's raw values
    case assign = 0
    case copy = 771
    case copyNonatomic = 3
    case retain = 769
    case retainNonatomic = 1
    
    fileprivate var objc: objc_AssociationPolicy {
        return objc_AssociationPolicy(rawValue: rawValue)!
    }
}

public protocol AssociatedObjects: class {}

// transparent wrappers

public extension AssociatedObjects {
    /// wrapper around `objc_getAssociatedObject`
    func ao_get(pkey: UnsafeRawPointer) -> Any? {
        return objc_getAssociatedObject(self, pkey)
    }
    /// wrapper around `objc_setAssociatedObject`
    func ao_set(_ value: Any, pkey: UnsafeRawPointer, policy: AssociationPolicy = .retainNonatomic) {
        objc_setAssociatedObject(self, pkey, value, policy.objc)
    }
    /// wrapper around 'objc_removeAssociatedObjects'
    func ao_removeAll() {
        objc_removeAssociatedObjects(self)
    }
}

// string key managed wrappers

fileprivate class MutableBox<T> {
    private(set) var value: T
    init(_ value: T) {
        self.value = value
    }
    
    // accepts a closure that can mutate `value` from within
    func mutate(f: (inout T) throws -> ()) rethrows {
        try f(&value)
    }
}

fileprivate typealias KeyBox = MutableBox<[String: UnsafePointer<Int8>]>
fileprivate var keyBoxKey = "_" as Character

fileprivate extension AssociatedObjects {
    // the box containing the dictionary we'll use to manage string keys
    fileprivate var keybox: KeyBox {
        return ao_get(pkey: &keyBoxKey) as? KeyBox ?? {
            let keybox = KeyBox([:])
            ao_set(keybox, pkey: &keyBoxKey)
            return keybox
        }()
    }
}

public extension AssociatedObjects {
    /// `String` key managed wrapper around `objc_setAssociatedObject`
    func ao_set(_ value: Any, key: String) {
        key.withCString { p in
            ao_set(value, pkey: p)
            // store the key
            keybox.mutate { $0[key] = p }
        }
    }
    /// `String` key managed wrapper around `objc_getAssociatedObject`
    func ao_get(key: String) -> Any? {
        guard let p = keybox.value[key] else { return nil }
        return ao_get(pkey: p)
    }
}

extension NSObject: AssociatedObjects {}
