# Model.swift
A simple, stupid Model for Swift

# Feature

Support basic HTTP methods, all returns Promise:

```swift
    func create() -> Promise<Model> { return sync(method: .create) }
    func update() -> Promise<Model> { return sync(method: .update) }
    func patch() -> Promise<Model> { return sync(method: .patch) }
    func delete() -> Promise<Model> { return sync(method: .delete) }
    func read() -> Promise<Model> { return sync(method: .read) }
```

Also collection `fetch` method:

```swift
    static func fetch(url: String?, params: [String: String]?) -> Promise<[Model]> {
```

# Dependencies
- PromiseKit
- Alamofire

# License
MIT
