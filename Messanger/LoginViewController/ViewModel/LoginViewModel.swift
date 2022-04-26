//
//  LoginViewModel.swift
//  Messanger
//
//  Created by Peter on 25.04.2022.
//

import Foundation
import Firebase
import RxRelay

class LoginViewModel {
    
    private var user: LoginModel?
    private let isLoading : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private let emailIdViewModel = EmailIdViewModel()
    private let passwordViewModel = PasswordViewModel()
    func authenticateToEmail() {
        
        guard var user = user else { return }
        
        user.email = emailIdViewModel.data.value
        user.password = emailIdViewModel.data.value
        
        self.isLoading.accept(true)
        
        FirebaseAuth.Auth.auth().signIn(withEmail: user.email, password: user.password, completion: { [weak self] authResult, error in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .operationNotAllowed: break
                case .emailAlreadyInUse: break
                case .invalidEmail: break
                case .weakPassword: break
                default: print("Error: \(error.localizedDescription)")
                }
            } else {
                print("User signs up successfully")
                let newUserInfo = Auth.auth().currentUser
                guard let user = self?.user else {
                    return
                }
                
                let email = user.email
            }
            
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email \(user.email)")
                return
            }
            
            let user = result.user
            
            UserDefaults.standard.set(user.email, forKey: "email")
            
            print("Logged In User\(user)")
        })
    }
}
