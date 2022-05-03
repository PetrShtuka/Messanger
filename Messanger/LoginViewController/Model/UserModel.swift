//
//  UserModel.swift
//  Messanger
//
//  Created by Peter on 28.04.2022.
//

import Foundation

struct UserModel {
    var userId: String = ""
    var type: LoginType = .google
    var name: String = ""
    var email: String = ""
    var profilePic: String = ""
}
