//
//  LoginViewModel.swift
//  Messanger
//
//  Created by Peter on 25.04.2022.
//

import Foundation
import Firebase
import RxRelay
import RxSwift
import GoogleSignIn
import FBSDKLoginKit
import FirebaseAuth
import FBSDKCoreKit

class LoginViewModel {
    
    private let user: LoginModel = LoginModel()
    let isSuccess: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let isLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let errorMsg: BehaviorRelay<String> = BehaviorRelay(value: "")
    let emailIdViewModel = EmailIdViewModel()
    let passwordViewModel = PasswordViewModel()
    var fbUserDetails: PublishSubject<UserModel> = PublishSubject()
    
    
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
    
    func fbLogin(viewController: UIViewController) {
          LoginManager().logIn(permissions: ["public_profile", "email"], from: viewController) { [weak self] (result, error) in
              guard let strongSelf = self else {return}
              if let error = error {
                  strongSelf.fbUserDetails.onError(error)
              } else if result?.isCancelled ?? false {
                  // User Cancelled
              } else {
                  if let _ = AccessToken.current {
                      strongSelf.getProfileFromFB()
                  }
              }
          }
      }
    
    private func getProfileFromFB() {
        FBRequest.shared.facebookRequest().start { [weak self] (connection, result, error) in
            guard let strong = self else {return}
                    if let error = error {
                        strong.fbUserDetails.onError(error)
                    } else {
                        guard let user = result as? [String: Any] else { return }
                        let name = (user["name"] as? String) ?? ""
                        let email = (user["email"] as? String) ?? ""
                        let userId = (user["id"] as? String) ?? ""
                        var imageURL: String = ""
                        if let profilePictureObj = user["picture"] as? [String: Any],
                            let data = profilePictureObj["data"] as? [String: Any],
                            let pictureUrlString  = data["url"] as? String,
                            let pictureUrl = NSURL(string: pictureUrlString) {
                            imageURL = pictureUrl.absoluteString ?? ""
                        }
                        let userSocial = UserModel.init(userId: userId, type: .facebook, name: name, email: email, profilePic: imageURL)
                        strong.fbUserDetails.onNext(userSocial)
                    }
               }
        }
}
