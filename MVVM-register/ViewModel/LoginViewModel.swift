//
//  LoginViewModel.swift
//  MVVM-register
//
//  Created by talgat on 6/16/21.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel {
    //MARK: - Properties
    let disposeBag = DisposeBag()
    private lazy var networking = Networking.shared
    private let messageSubject = BehaviorSubject<String>(value: "")
    private let registerEventSubject = PublishSubject<Void>()
    //MARK: - Binding
    struct Input {
        let emailText: Observable<String>
        let passwordText: Observable<String>
        let loginButton: Observable<Void>
        let registerButton: Observable<Void>
    }
    
    struct Output {
        let messageText: Driver<String>
        let messageIsHidden: Driver<Bool>
        let loginButtonIsEnabled: Driver<Bool>
        let loginSuccessful: Driver<Void>
//        let registerSuccessful: Driver<Void>
    }
    
    func transform(_ input: Input) -> Output {
        handleValidInputMessage(input)
        handleLoginButtonTap(input)
        return Output(messageText: messageText,
                      messageIsHidden: messageIsEmpty,
                      loginButtonIsEnabled: inputIsValid(input),
                      loginSuccessful: loginSuccessful
                      )
    }
}

//MARK: - Helpers
private extension LoginViewModel {
    
    var messageText: Driver<String> {
        messageSubject.asDriver(onErrorJustReturn: "")
    }
    
    var messageIsEmpty: Driver<Bool> {
        messageText.map { $0.isEmpty }
    }
    
    var loginSuccessful: Driver<Void> {
        registerEventSubject.asDriver(onErrorDriveWith: Driver.never())
    }
    
    var registerSuccessful: Driver<Void> {
        registerEventSubject.asDriver(onErrorDriveWith: Driver.never())
    }
    
    func inputIsValid(_ input: Input) -> Driver<Bool> {
        Observable
            .combineLatest(input.emailText, input.passwordText)
            .map { email, pass  in
                !email.isEmpty && !pass.isEmpty && email.isValidEmail
            }.asDriver(onErrorJustReturn: false)
    }
    
    func handleValidInputMessage(_ input: Input) {
        Observable
            .combineLatest(input.emailText, input.passwordText)
            .map { email, pass in
                if email.isEmpty {
                    return "Please provide an e-mail."
                } else if !email.isValidEmail {
                    return "E-mail address is not valid."
                } else if pass.isEmpty {
                    return "Please provide an password."
                } else {
                    return ""
                }
            }.subscribe(messageSubject)
            .disposed(by: disposeBag)
    }
    
    func handleLoginButtonTap(_ input: Input) {
        let result = input.loginButton
            .withLatestFrom(Observable.combineLatest(input.emailText, input.passwordText))
            .flatMapLatest { email, pass in
                self.networking
                    .loginUser(email: email, pass: pass)
                    .catch({ error in
                        let errorMessage = (error as? Networking.APIError)?.localizedDescription
                                            ?? error.localizedDescription
                        self.messageSubject.onNext(errorMessage)
                        return .empty()
                    })
            }.share()
        result.map { _ in "" }.subscribe(messageSubject).disposed(by: disposeBag)
        result.map { _ in }.subscribe(registerEventSubject).disposed(by: disposeBag)
    }
}
