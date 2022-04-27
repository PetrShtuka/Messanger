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
    
    private let user: LoginModel = LoginModel()
    let isSuccess: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let isLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let errorMsg: BehaviorRelay<String> = BehaviorRelay(value: "")
    let emailIdViewModel = EmailIdViewModel()
    let passwordViewModel = PasswordViewModel()
    
    func validateCredentials() -> Bool {
        return emailIdViewModel.validateCredentials() && passwordViewModel.validateCredentials();
    }
    
    
    func authenticateToEmail() {
        
        user.email = emailIdViewModel.data.value
        user.password = passwordViewModel.data.value
        
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
                print(newUserInfo)
                let email = self?.user.email
                print(email)
            }
            
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email \(self?.user.email)")
                return
            }
            
            let user = result.user
            
            UserDefaults.standard.set(user.email, forKey: "email")
            
            print("Logged In User\(user)")
        })
    }
}
