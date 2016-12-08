# Model.swift
A simple, stupid Model for Swift

# Feature

Support basic HTTP methods, all returns Observable:

```swift
    func create() -> Observable<Model> { return sync(method: .create) }
    func update() -> Observable<Model> { return sync(method: .update) }
    func patch() -> Observable<Model> { return sync(method: .patch) }
    func delete() -> Observable<Model> { return sync(method: .delete) }
    func read() -> Observable<Model> { return sync(method: .read) }
```

Also collection `fetch` method:

```swift
    static func fetch(url: String?, params: [String: String]?) -> Promise<[Model]> {
```

# Dependencies
- Alamofire
- RxSwift

# License
MIT
