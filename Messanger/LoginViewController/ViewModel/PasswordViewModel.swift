//
//  PasswordViewModel.swift
//  Messanger
//
//  Created by Peter on 25.04.2022.
//

import Foundation
import RxRelay

class PasswordViewModel : ValidationViewModel {
     
    internal var errorMessage: String = "Please enter a valid Password"
    
    var data: BehaviorRelay<String> = BehaviorRelay(value: "")
    var errorValue: BehaviorRelay<String?> = BehaviorRelay(value: "")
    
    internal func validateCredentials() -> Bool {
        guard validateLength(text: data.value, size: (6,15)) else {
            errorValue.accept(errorMessage)
            return false
        }
        
        errorValue.accept("")
        return true
    }
    
    private func validateLength(text: String, size: (min: Int, max: Int)) -> Bool {
        return (size.min...size.max).contains(text.count)
    }
}
