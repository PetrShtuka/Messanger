//
//  FBRequest.swift
//  Messanger
//
//  Created by Peter on 28.04.2022.
//

import Foundation
import FacebookLogin

class FBRequest {
    
    static var shared = FBRequest()
    
    private var graph = "me"
    private var parameter = ["fields":
                                "email ,first_name, last_name, picture.type(large)"]
    private var token: String?
    
    func facebookRequest() -> GraphRequest {
        let graphRequest = FBSDKLoginKit.GraphRequest(graphPath: graph,
                                                  parameters: parameter,
                                                  tokenString: token,
                                                version: nil,
                                                httpMethod: .get)
    return graphRequest
    }
}
