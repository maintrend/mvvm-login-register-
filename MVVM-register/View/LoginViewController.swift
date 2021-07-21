//
//  LoginViewController.swift
//  MVVM-register
//
//  Created by talgat on 6/16/21.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
//MARK: - Outlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginTapButton: UIButton!
    @IBOutlet weak var registerTapButton: UIButton!
//MARK: - Properties
    let segueId = "success"
    let disposeBag = DisposeBag()
    let loginViewModel = LoginViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        registerTapButton.addTarget(self, action: #selector(self.goToRegisterScreen), for: .touchUpInside)
        let output = loginViewModel.transform(LoginViewModel.Input(
                    emailText: emailField.rx.text.orEmpty.asObservable(),
                    passwordText: passwordField.rx.text.orEmpty.asObservable(),
                    loginButton: loginTapButton.rx.tap.asObservable(),
                    registerButton: registerTapButton.rx.tap.asObservable()))
        
        output.loginButtonIsEnabled.drive(loginTapButton.rx.isEnabled).disposed(by: disposeBag)
        output.messageIsHidden.drive(messageLabel.rx.isHidden).disposed(by: disposeBag)
        output.messageText.drive(messageLabel.rx.text).disposed(by: disposeBag)
        output.loginSuccessful.drive(onNext: goToMainScreen).disposed(by: disposeBag)
    }
//MARK: - Helpers
    private func goToMainScreen() {
        let vc = (storyboard?.instantiateViewController(withIdentifier: "MainViewController"))!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func goToRegisterScreen(sender: UIButton) {
        performSegue(withIdentifier: "toRegister", sender: self)
    }
   

}
