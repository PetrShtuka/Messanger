//
//  LoginViewModel.swift
//  Messanger
//
//  Created by Peter on 25.04.2022.
//

import UIKit
import Firebase
import RxRelay
import RxSwift
import GoogleSignIn
import FBSDKLoginKit
import FirebaseAuth
import FBSDKCoreKit
import CryptoKit
import AuthenticationServices

class LoginViewModel: NSObject {
    
    private let user: LoginModel = LoginModel()
    fileprivate var currentNonce: String?
    let isSuccess: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let isLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let errorMsg: BehaviorRelay<String> = BehaviorRelay(value: "")
    let emailIdViewModel = EmailIdViewModel()
    let passwordViewModel = PasswordViewModel()
    var fbUserDetails: PublishSubject<UserModel> = PublishSubject()
    var googleUserDetails: PublishSubject<UserModel> = PublishSubject()
    
    
    func validateCredentials() -> Bool {
        return emailIdViewModel.validateCredentials() && passwordViewModel.validateCredentials();
    }
    
    func authenticateToEmail(_ viewController: LoginViewController) {
        user.email = emailIdViewModel.data.value
        user.password = passwordViewModel.data.value
        
        self.isLoading.accept(true)
        
        FirebaseAuth.Auth.auth().signIn(withEmail: user.email, password: user.password, completion: { [weak self] authResult, error in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .operationNotAllowed:
                    viewController.showAlert(with: "The administrator disabled sign in with the specified identity provider.")
                case .emailAlreadyInUse:
                    viewController.showAlert(with: "The email used to attempt a sign up is already in use.")
                case .invalidEmail:
                    viewController.showAlert(with: "The email is invalid.")
                default:  viewController.showAlert(with: error.localizedDescription)
                }
            } else {
                print("User signs up successfully")
                let newUserInfo = Auth.auth().currentUser
                let email = self?.user.email
            }
            
            guard let result = authResult, error == nil else {
//                self?.showAlert(with:"Failed to log in user with email \(self?.user.email))
                return
            }
            
            let user = result.user
            
            UserDefaults.standard.set(user.email, forKey: "email")
            
            print("Logged In User\(user)")
        })
    }
    
    func googleSignIn(_ viewController: LoginViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { user, error in
            guard error == nil else { return }
            guard let user = user else { return }
            
            if let profileData = user.profile {
                var avatar : String = ""
                if let imgurl = user.profile?.imageURL(withDimension: 100) {
                    avatar = imgurl.absoluteString
                }
                let user = UserModel(userId: user.userID ?? "",
                                     type: .google,
                                     name: profileData.givenName ?? "",
                                     email: profileData.email,
                                     profilePic: avatar)
            }
        }
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
                let userSocial = UserModel.init(userId: userId,
                                                type: .facebook,
                                                name: name,
                                                email: email,
                                                profilePic: imageURL)
                strong.fbUserDetails.onNext(userSocial)
            }
        }
    }
}

extension LoginViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIWindow.init()
    }
    
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }
    
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
          guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
          }
          guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
          }
          guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
          }
          // Initialize a Firebase credential.
          let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                    idToken: idTokenString,
                                                    rawNonce: nonce)
          // Sign in with Firebase.
          Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
              // Error. If error.code == .MissingOrInvalidNonce, make sure
              // you're sending the SHA256-hashed nonce as a hex string with
              // your request to Apple.
              print(error.localizedDescription)
              return
            }
          }
        }
      }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
}

