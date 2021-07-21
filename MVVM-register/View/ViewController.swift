//
//  ViewController.swift
//  MVVM-register
//
//  Created by talgat on 6/15/21.
//

import UIKit
import RxCocoa
import RxSwift
class ViewController: UIViewController {
    
//MARK: - Outlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordRepeatedField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var returnButton: UIButton!
    //MARK: - Properties
    let viewModel = ViewModel()
    let disposeBag = DisposeBag()
    let segueId = "success"
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationController?.isNavigationBarHidden = true
        returnButton.addTarget(self, action: #selector(self.returnToLoginScreen), for: .touchUpInside)
       let output = viewModel.transform(ViewModel.Input(
                                emailText: emailField.rx.text.orEmpty.asObservable(),
                                passwordText: passwordField.rx.text.orEmpty.asObservable(),
                                password2Text: passwordRepeatedField.rx.text.orEmpty.asObservable(),
                                buttonTap: registerButton.rx.tap.asObservable()))
        
        output.buttonIsEnabled.drive(registerButton.rx.isEnabled).disposed(by: disposeBag)
        output.messageIsHidden.drive(messageLabel.rx.isHidden).disposed(by: disposeBag)
        output.messageText.drive(messageLabel.rx.text).disposed(by: disposeBag)
        output.registerSuccessful.drive(onNext: goToSuccessScreen).disposed(by: disposeBag)
    }
//MARK: - Helpers
    private func goToSuccessScreen() {
        performSegue(withIdentifier: segueId, sender: self)
    }
    @objc private func returnToLoginScreen(sender: UIButton) {
        //dismiss dont work
        let vc = (storyboard?.instantiateViewController(withIdentifier: "loginSB"))!
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

}

