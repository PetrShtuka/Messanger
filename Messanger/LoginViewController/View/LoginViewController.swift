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
    let disposeBag = DisposeBag()
    
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
        signInButton.addTarget(self, action: #selector(createViewModelBinding), for: .allEvents)
        
        createViewModelBinding();
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
    }
    
    @objc func createViewModelBinding() {
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
