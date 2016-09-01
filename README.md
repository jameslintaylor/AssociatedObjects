# add stored properties to existing types!

**AssociatedObjects** provides swift wrappers around `objc_getAssociatedObject`, `objc_setAssociatedObject` and `objc_removeAssociatedObjects`... that's it

to expose the wrappers for your custom object, just `extension MyObject: AssociatedObjects {}` and enjoy! for convenience, `NSObject` already does this

**typically** we use associated objects to add stored properties to existing types...
```swift
extension UIView {

    // the key we'll associate `storedProperty` to
    private var storedPropertyKey: Character = "_"

    var storedProperty: T {
        get {
            // return the existing property if it exists, otherwise create a new one
            return getAssociatedObject(key: &UIView.storedPropertyKey) as? T ?? {
                let new = T()
                self.storedProperty = new
                return new
            }()
        }
        set {
            setAssociatedObject(newValue, key: &UIView.storedPropertyKey)
        }
}
```

### a note on keys...
when passing a key to `getAssociatedObject` or `setAssociatedObject`, the pointer to that key is what is used to index the property.
```swift
// somewhat counter-intuitively, doing this doesn't work! 
a.setAssociatedObject(b, key: "🔑")
a.getAssociatedObject(key: "🔑")

// instead, you should pass the pointer to a 'constant' variable (a Character is recommended)
var key: Character = "🔑"
a.setAssociatedObject(b, key: &key)
a.getAssociatedObject(key: &key)
```

### association policies
`setAssociatedObject` takes an optional `policy` parameter. this determines how the new associated object should be referenced by the owner
```swift
enum AssociationPolicy {
    case assign 
    case copy 
    case copyNonatomic
    case retain
    case retainNonatomic 
}
```
these match 1:1 with [`objc_AssociationPolicy`](https://developer.apple.com/reference/objectivec/objc_associationpolicy)


