//
//  UserModel.swift
//  Messanger
//
//  Created by Peter on 28.04.2022.
//

import Foundation

struct UserModel {
    var firstName: String
    var lastName: String
    var email: String
    
    init(firstName: String = "", lastName: String = "", email: String = "") {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}
