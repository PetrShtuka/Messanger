//
//  LoginModel.swift
//  Messanger
//
//  Created by Peter on 25.04.2022.
//

import Foundation

struct LoginModel {
    
    var email = ""
    var password = ""
    
    init(email : String, password : String) {
        self.email = email
        self.password = password
    }
}
