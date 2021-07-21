//
//  ExtString-IsValidEmail.swift
//  MVVM-register
//
//  Created by talgat on 6/15/21.
//


import Foundation

extension String {
    var isValidEmail: Bool {
        // https://stackoverflow.com/a/25471164
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}
