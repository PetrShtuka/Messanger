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
import FacebookLogin
import GoogleSignIn


class LoginViewController: UIViewController {
    
    private let googleSignIn = GIDSignIn.sharedInstance
    private let viewModel = LoginViewModel()
    let disposeBag = DisposeBag()
    
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
        return textfield
    }()
    
    lazy var passwordTextField: UITextField = {
        let textfield = UITextField()
        textfield.backgroundColor = .white
        textfield.layer.cornerRadius = 10
        textfield.placeholder = "Password"
        textfield.setLeftPaddingPoints(10)
        textfield.font?.withSize(15)
        return textfield
    }()
    
    
    lazy var recoveryPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Recovery Password", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.setTitleColor(UIColor.init(hexString: "#858997"), for: .normal)
        return button
    }()
    
    lazy var googleSignInButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "google"), for: .normal)
        button.backgroundColor = .clear
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
        view.backgroundColor = .white
        return view
    }()
    
    lazy var viewApple: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .white
        return view
    }()
    
    lazy var viewFacebook: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .white
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
        self.view.addSubview(emailTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(signInButton)
        self.view.addSubview(recoveryPasswordButton)
        self.view.addSubview(viewGoogle)
        self.view.addSubview(viewFacebook)
        self.view.addSubview(viewApple)
        self.view.addSubview(helloText)
        self.view.addSubview(descriptionText)
        self.viewGoogle.addSubview(googleSignInButton)
        self.viewFacebook.addSubview(facebookSignInButton)
        self.viewApple.addSubview(appleSignInButton)
        signInButton.addTarget(self, action: #selector(emailSingInTapped), for: .touchDown)
        facebookSignInButton.addTarget(self, action: #selector(fbSignInTapped), for: .touchDown)
        googleSignInButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchDown)
        emailSingInTapped();
        createCallbacks()
    }
    
    override func viewDidLayoutSubviews() {
        self.updateSubviewConstraints()
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
        
        self.recoveryPasswordButton.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(1.45)
            make.height.equalTo(14)
            make.top.equalTo(self.passwordTextField.snp.bottom).offset(30)
        }
        
        self.signInButton.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(50)
            make.top.equalTo(self.recoveryPasswordButton.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        
        self.viewGoogle.snp.makeConstraints { (make) in
            make.size.width.equalTo(65)
            make.height.equalTo(65)
            make.top.equalTo(self.signInButton.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        
        self.viewFacebook.snp.makeConstraints { (make) in
            make.size.width.equalTo(65)
            make.height.equalTo(65)
            make.top.equalTo(self.signInButton.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(40)
        }
        
        self.viewApple.snp.makeConstraints { (make) in
            make.size.width.equalTo(65)
            make.height.equalTo(65)
            make.top.equalTo(self.signInButton.snp.bottom).offset(30)
            make.trailing.equalToSuperview().offset(-40)
        }
        
        self.facebookSignInButton.snp.makeConstraints { (make) in
            make.size.width.equalTo(46)
            make.height.equalTo(46)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        self.googleSignInButton.snp.makeConstraints { (make) in
            make.size.width.equalTo(40)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        self.appleSignInButton.snp.makeConstraints { (make) in
            make.size.width.equalTo(37)
            make.height.equalTo(37)
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
                self.viewModel.authenticateToEmail()
            }
        }).disposed(by: disposeBag)
    }
    
    @objc func fbSignInTapped() {
        facebookSignInButton.rx.tap.bind{ [weak self] _ in
            guard let strong = self else {return}
            self?.viewModel.fbLogin(viewController: strong)
        }.disposed(by: disposeBag)
    }
    
    @objc func googleSignInTapped() {
        googleSignInButton.rx.tap.bind{ [weak self] _ in
            guard let view = self else {return}
            self?.viewModel.googleSignIn(view)
        }.disposed(by: disposeBag)
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
