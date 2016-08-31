//
//  AssociatedObjects.swift
//  AssociatedObjects
//
//  Created by James Taylor on 2016-08-31.
//  Copyright © 2016 James Taylor. All rights reserved.
//

import Foundation

enum AssociationPolicy: UInt {
    // raw values map to objc_AssociationPolicy's raw values
    case assign = 0
    case copy = 771
    case copyNonatomic = 3
    case retain = 769
    case retainNonatomic = 1
    
    private var objc: objc_AssociationPolicy {
        return objc_AssociationPolicy(rawValue: rawValue)!
    }
}

protocol AssociatedObjects: class {}

extension AssociatedObjects {
    /// wrapper around `objc_getAssociatedObject`
    func getAssociatedObject(key key: UnsafePointer<Void>) -> AnyObject? {
        return objc_getAssociatedObject(self, key)
    }
    /// wrapper around `objc_setAssociatedObject`
    func setAssociatedObject(object: AnyObject, key: UnsafePointer<Void>, policy: AssociationPolicy = .retainNonatomic) {
        objc_setAssociatedObject(self, key, object, policy.objc)
    }
    /// wrapper around 'objc_removeAssociatedObjects'
    func removeAssociatedObjects() {
        objc_removeAssociatedObjects(self)
    }
}

extension NSObject: AssociatedObjects {}