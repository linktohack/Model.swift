//
//  Model.swift
//  Model
//
//  Created by Quang-Linh LE on 16/12/3.
//  Copyright © 2016 Quang-Linh LE. All rights reserved.
//

import Alamofire
import RxSwift

class Model {
    enum Method {
        case create, update, patch, delete, read
    }
    
    var url: String? = nil
    var params: [String: String]? = nil
    
    internal var _id: String? = nil
    
    var idAttribute: String? {
        get { return _id }
        set { _id = newValue }
    }
    
    required init(url: String?, params: [String: String]?) {
        self.url = url
        self.params = params
    }
    
    init(json: [String: Any?]) {
        let _ = fromJSON(json)
    }
    
    func toJSON() -> [String: Any?] {
        return [:]
    }
    
    func fromJSON(_ json: [String: Any?]) -> Model {
        self.idAttribute = json["id"] as? String
        return self
    }
    
    func sync(method: Method) -> Observable<Model>{
        let methodMap = [
            Method.create: HTTPMethod.post,
            Method.update: HTTPMethod.put,
            Method.patch: HTTPMethod.patch,
            Method.delete: HTTPMethod.delete,
            Method.read: HTTPMethod.get
        ]
        
        let m = methodMap[method]!
        
        let parameterizedUrl = params?.reduce(self.url!, { (acc: String, it: (key: String, value: String)) -> String in
            return acc.replacingOccurrences(of: [":", it.key].joined(), with: it.value)
        }).replacingOccurrences(of: ":_id", with: idAttribute ?? "")
        
        
        let parameters = m != .get ? toJSON() : [:]
        
        return Observable.create { subscriber in
            let request = Alamofire.request(parameterizedUrl!, method: m, parameters: parameters).responseJSON(completionHandler: {res in
                if res.result.isFailure {
                    subscriber.onError(res.result.error!)
                } else {
                    let _ = self.fromJSON(res.result.value! as! [String : Any?])
                    subscriber.onNext(self)
                    subscriber.onCompleted()
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        }
        
    }
    
    func create() -> Observable<Model> { return sync(method: .create) }
    func update() -> Observable<Model> { return sync(method: .update) }
    func patch() -> Observable<Model> { return sync(method: .patch) }
    func delete() -> Observable<Model> { return sync(method: .delete) }
    func read() -> Observable<Model> { return sync(method: .read) }

    static func fetch(url: String?, params: [String: String]?) -> Observable<[Model]> {
        let parameterizedUrl = params?.reduce(url!, { (acc: String, it: (key: String, value: String)) -> String in
            return acc.replacingOccurrences(of: [":", it.key].joined(), with: "")
        }).replacingOccurrences(of: ":_id", with: "")
        
        return Observable.create {subscriber in
            let request = Alamofire.request(parameterizedUrl!, method: .get).responseJSON(completionHandler: {res in
                if res.result.isFailure {
                    subscriber.onError(res.result.error!)
                    subscriber.onCompleted()
                } else {
                    subscriber.onNext((res.result.value as! [[String: Any?]]).map({ self.init(url: url, params: params).fromJSON($0) }))
                    subscriber.onCompleted()
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
