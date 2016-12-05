//
//  User.swift
//  Model
//
//  Created by Quang-Linh LE on 16/12/3.
//  Copyright © 2016 Quang-Linh LE. All rights reserved.
//

class User: Model {
    var id: String? = nil
    var name: String? = nil
    var email: String? = nil
    var password: String? = nil
    
    override var idAttribute: String? {
        get { return id }
        set { id = newValue }
    }
    
    override func toJSON() -> [String : Any?] {
        return [
            "id": id,
            "name": name,
            "email": email,
            "password": password
        ]
    }
    
    override func fromJSON(_ json: [String : Any?]) -> Model {
        id = json["id"] as? String
        name = json["name"] as? String
        email = json["email"] as? String
        password = json["password"] as? String
        
        return self
    }
}
