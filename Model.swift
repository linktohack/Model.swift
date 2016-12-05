//
//  Model.swift
//  Model
//
//  Created by Quang-Linh LE on 16/12/3.
//  Copyright © 2016 Quang-Linh LE. All rights reserved.
//

import Alamofire
import PromiseKit

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
    
    func sync(method: Method) -> Promise<Model>{
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
        
        return Promise<Model>(resolvers: { (resolve, reject) in
            Alamofire.request(parameterizedUrl!, method: m, parameters: parameters).responseJSON(completionHandler: {res in
                if let json = res.result.value as? [String: Any?] {
                    let _ = self.fromJSON(json)
                    resolve(self)
                } else {
                    reject("Error" as! Error)
                }
            })
        })
    }
    
    func create() -> Promise<Model> { return sync(method: .create) }
    func update() -> Promise<Model> { return sync(method: .update) }
    func patch() -> Promise<Model> { return sync(method: .patch) }
    func delete() -> Promise<Model> { return sync(method: .delete) }
    func read() -> Promise<Model> { return sync(method: .read) }

    
    static func fetch(url: String?, params: [String: String]?) -> Promise<[Model]> {
        let parameterizedUrl = params?.reduce(url!, { (acc: String, it: (key: String, value: String)) -> String in
            return acc.replacingOccurrences(of: [":", it.key].joined(), with: "")
        })
        
        return Promise<[Model]>(resolvers: { (resolve, reject) in
            Alamofire.request(parameterizedUrl!, method: .get).responseJSON(completionHandler: {res in
                if let json = res.result.value as? [[String: Any?]] {
                    resolve(json.map({ self.init(url: url, params: params).fromJSON($0) }))
                } else {
                    reject("Error" as! Error)
                }
            })
        })
    }
}
