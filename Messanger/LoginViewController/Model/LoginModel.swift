//
//  LoginModel.swift
//  Messanger
//
//  Created by Peter on 25.04.2022.
//

import Foundation

class LoginModel {
    
    var email = ""
    var password = ""
    
    convenience init(email : String, password : String) {
        self.init()
        self.email = email
        self.password = password
    }
}
