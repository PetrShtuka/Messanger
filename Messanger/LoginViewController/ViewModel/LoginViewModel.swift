//
//  LoginViewModel.swift
//  Messanger
//
//  Created by Peter on 25.04.2022.
//

import Foundation
import Firebase
import RxRelay
import GoogleSignIn
import FBSDKLoginKit
import FirebaseAuth

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
    
    func loginButton(didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
          guard let token = result?.token?.tokenString else {
              print("User failed to log in with facebook")
              return
          }
          
          // Request email and email (retrunt User)
          
    
        FBRequest.shared.facebookRequest().start(completion: {_, result, error in
                guard let result = result as? [String: Any],
                      error == nil else {
                    print("Failed to make facebook request")
                    return
                }
              
            var users: UserModel = UserModel(firstName: result["first_name"] as? String ?? "",
                                           lastName: result["last_name"] as? String ?? "",
                                           email: result["email"] as? String ?? "")
            
            guard !users.email.isEmpty else {
                print("fail facebook")
                return }
              
            UserDefaults.standard.set(users.email, forKey: "email")
              
              // test database email.
              
              DatabaseManager.shared.userExist(with: users.email, completion: { exists in
                  if !exists {
                      let chatUser = ChatAppUser(firstName: firstName,
                                                 lastName: lastName,
                                                 emailAddress: email)
                      DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                          if success {
                              
                              guard let url = URL(string: pictureURL) else {
                                  return
                              }
                              
                              print("Downloading data from facebook image")
                              
                              URLSession.shared.dataTask(with: url, completionHandler: { data, _,_ in
                                  guard let data = data else {
                                      print("Failed to get data from facebook")
                                      return
                                  }
                                  
                                  print("got data from FB, uploading...")
                                  
                                  // upload image
                                  
                                  let filename = chatUser.profilePictureFileName
                                  StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                                      switch result {
                                      case .success(let downloadURL):
                                          UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                          print(downloadURL)
                                      case .failure(let error):
                                          print("Storage manager error: \(error)")
                                      }
                                  })
                              }).resume()
                          }
                      })
                  }
              })
              // Get uesr data firebase. Use firebase date.
              
              let credential = FacebookAuthProvider.credential(withAccessToken: token)
              
              FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                  
                  guard let strongSelf = self else {
                      return
                  }
                  
                  guard authResult != nil , error == nil else {
                      if let error = error {
                          print("Facebook credential login failed, MFA may be needed - \(error)")
                      }
                      return
                  }
                  print("Successfully logged user in ")
                  strongSelf.navigationController?.dismiss(animated: true, completion: nil)
              })
          })
      }
}
