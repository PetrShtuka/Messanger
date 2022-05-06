//
//  LoginViewController.swift
//  Messanger
//
//  Created by Peter on 25.04.2022.
//

import SnapKit
import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    private let viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()
    private var passwordVisible = false
    
    lazy var backgroundGradient: UIImageView = {
        var image = UIImageView()
        image = UIImageView(image: UIImage(named: "background"))
        image.alpha = 0.7
        return image
    }()
    
    lazy var signUpWith: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.layer.cornerRadius = 6
        label.text = "- Sign Up With -"
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.textAlignment = .center
        return label
    }()
    
    lazy var notMember: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.layer.cornerRadius = 6
        label.text = "Not a member?"
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.textAlignment = .center
        return label
    }()
    
    lazy var registerNowButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register Now", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        return button
    }()
    
    lazy var helloText: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.layer.cornerRadius = 6
        label.text = "Hello Again"
        label.font = UIFont.systemFont(ofSize: 30.0)
        label.textAlignment = .center
        return label
    }()
    
    lazy var descriptionText: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.layer.cornerRadius = 6
        label.text = "Wellcome back you've been missed"
        label.font = UIFont.systemFont(ofSize: 20.0)
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()
    
    lazy var emailTextField: UITextField = {
        let textfield = UITextField()
        textfield.backgroundColor = .white
        textfield.layer.cornerRadius = 10
        textfield.placeholder = "Email"
        textfield.font?.withSize(15)
        textfield.setLeftPaddingPoints(10)
        textfield.delegate = self
        return textfield
    }()
    
    lazy var passwordTextField: UITextField = {
        let textfield = UITextField()
        textfield.backgroundColor = .white
        textfield.layer.cornerRadius = 10
        textfield.placeholder = "Password"
        textfield.setLeftPaddingPoints(10)
        textfield.font?.withSize(15)
        textfield.delegate = self
        return textfield
    }()
    
    
    lazy var recoveryPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Recovery Password", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.setTitleColor(UIColor.init(hexString: "#858997"), for: .normal)
        return button
    }()
    
    lazy var hidePasswordButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(systemName: "eye.slash"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.tintColor = .black
        return button
    }()
    
    lazy var googleSignInButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "google"), for: .normal)
        return button
    }()
    
    lazy var facebookSignInButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "facebook"), for: .normal)
        button.backgroundColor = .clear
        
        return button
    }()
    
    lazy var appleSignInButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "apple"), for: .normal)
        button.backgroundColor = .clear
        return button
    }()
    
    lazy var viewGoogle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var viewApple: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var viewFacebook: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var signInButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.init(hexString: "#f46968")
        button.setTitle("Sign In", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(notMember)
        view.addSubview(registerNowButton)
        view.addSubview(backgroundGradient)
        view.addSubview(signUpWith)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
        view.addSubview(recoveryPasswordButton)
        view.addSubview(viewGoogle)
        view.addSubview(viewFacebook)
        view.addSubview(viewApple)
        view.addSubview(helloText)
        view.addSubview(descriptionText)
        passwordTextField.isSecureTextEntry = false
        passwordTextField.addSubview(hidePasswordButton)
        passwordTextField.isSecureTextEntry.toggle()
        viewGoogle.addSubview(googleSignInButton)
        viewFacebook.addSubview(facebookSignInButton)
        viewApple.addSubview(appleSignInButton)
        signInButton.addTarget(self, action: #selector(emailSingInTapped), for: .touchDown)
        facebookSignInButton.addTarget(self, action: #selector(fbSignInTapped), for: .touchDown)
        googleSignInButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchDown)
        hidePasswordButton.addTarget(self, action: #selector(showHideTapped), for: .touchDown)
        appleSignInButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchDown)
        emailSingInTapped()
        passwordTextField.alpha = 0
        createCallbacks()
        animationHidenPassword()
    }
    
    override func viewDidLayoutSubviews() {
        updateSubviewConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSubviewConstraints () {
        self.emailTextField.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(50)
            make.center.equalToSuperview()
        }
        
        self.passwordTextField.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(50)
            make.top.equalTo(self.emailTextField.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        self.signInButton.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(50)
            make.top.equalTo(self.recoveryPasswordButton.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        
        self.viewApple.snp.makeConstraints { (make) in
            make.size.width.equalTo(80)
            make.height.equalTo(55)
            make.top.equalTo(self.signInButton.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
        }
        
        self.viewFacebook.snp.makeConstraints { (make) in
            make.size.width.equalTo(80)
            make.height.equalTo(45)
            make.leading.equalToSuperview().offset(40)
            make.centerY.equalTo(self.viewApple.snp.centerY)
        }
        
        self.viewGoogle.snp.makeConstraints { (make) in
            make.size.width.equalTo(80)
            make.height.equalTo(45)
            make.centerY.equalTo(self.viewApple.snp.centerY)
            make.trailing.equalToSuperview().offset(-40)
        }
        
        self.signUpWith.snp.makeConstraints { (make) in
            make.size.width.equalTo(100)
            make.height.equalTo(30)
            make.top.equalTo(self.signInButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        self.facebookSignInButton.snp.makeConstraints { (make) in
            make.size.width.equalTo(40)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        self.googleSignInButton.snp.makeConstraints { (make) in
            make.size.width.equalTo(35)
            make.height.equalTo(35)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        self.appleSignInButton.snp.makeConstraints { (make) in
            make.size.width.equalTo(32)
            make.height.equalTo(32)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        self.helloText.snp.makeConstraints { (make) in
            make.height.equalTo(37)
            make.top.equalTo(self.descriptionText.snp.bottom).offset(-120)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
        }
        
        self.descriptionText.snp.makeConstraints { (make) in
            make.height.equalTo(70)
            make.top.equalTo(self.emailTextField.snp.top).offset(-100)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
        }
        
        self.hidePasswordButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        
        self.backgroundGradient.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    @objc func emailSingInTapped() {
        emailTextField.rx.text.orEmpty
            .bind(to: viewModel.emailIdViewModel.data)
            .disposed(by: disposeBag)
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.passwordViewModel.data)
            .disposed(by: disposeBag)
        signInButton.rx.tap.do(onNext:  { [unowned self] in
            self.emailTextField.resignFirstResponder()
            self.passwordTextField.resignFirstResponder()
        }).subscribe(onNext: { [unowned self] in
            if self.viewModel.validateCredentials() {
                self.viewModel.authenticateToEmail(self)
            } else {
                presentAlert(withTitle: "Warning", message: "Plz check email address or password")
            }
        }).disposed(by: disposeBag)
    }
    
    @objc func fbSignInTapped() {
        facebookSignInButton.rx.tap.bind{ [weak self] _ in
            guard let strong = self else {return}
            self?.viewModel.fbLogin(viewController: strong)
        }.disposed(by: disposeBag)
    }
    
    @objc func appleSignInTapped() {
        appleSignInButton.rx.tap.bind{ [weak self] _ in
            self?.viewModel.startSignInWithAppleFlow()
        }.disposed(by: disposeBag)
    }
    
    @objc func googleSignInTapped() {
        googleSignInButton.rx.tap.bind{ [weak self] _ in
            guard let view = self else {return}
            self?.viewModel.googleSignIn(view)
        }.disposed(by: disposeBag)
    }
    
    func animationHidenPassword() {
        let isEmptyEmailTextField = emailTextField.text?.isEmpty ?? true
        if  isEmptyEmailTextField {
                self.passwordTextField.alpha = 0
                self.recoveryPasswordButton.snp.makeConstraints { (make) in
                    make.width.equalToSuperview().multipliedBy(1.45)
                    make.height.equalTo(14)
                    make.top.equalTo(self.emailTextField.snp.bottom).offset(20)
            }
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                self.passwordTextField.alpha = 1
                self.recoveryPasswordButton.snp.updateConstraints { (make) in
                    make.width.equalToSuperview().multipliedBy(1.45)
                    make.height.equalTo(14)
                    make.top.equalTo(self.emailTextField.snp.bottom).offset(80)
                }
            })
        }
    }
    
    @objc func showHideTapped() {
        if passwordVisible {
            passwordTextField.isSecureTextEntry = false
            hidePasswordButton.setImage(UIImage.init(systemName: "eye.slash"), for: .normal)
            passwordVisible = false
        } else {
            passwordTextField.isSecureTextEntry = true
            hidePasswordButton.setImage(UIImage.init(systemName: "eye"), for: .normal)
            passwordVisible = true
        }
    }
    
    func createCallbacks (){
        viewModel.isSuccess.asObservable()
            .bind{ value in
                NSLog("Successfull")
            }.disposed(by: disposeBag)
        
        viewModel.errorMsg.asObservable()
            .bind { errorMessage in
                // Show error
                NSLog("Failure")
            }.disposed(by: disposeBag)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if !(emailTextField.text?.isEmpty ?? false) {
            animationHidenPassword()
        }
        return true
    }
}

extension LoginViewController {
    func showAlert(with error: String) {
        let okAlertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        let alertViewController = UIAlertController(title: "Something went wrong", message: error, preferredStyle: .alert)
        alertViewController.addAction(okAlertAction)
        present(alertViewController, animated: true, completion: nil)
    }
}
