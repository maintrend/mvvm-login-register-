//
//  Member.swift
//  MVVM-register
//
//  Created by talgat on 6/19/21.
//

import Foundation

struct Member: Decodable {
    var id: Int
    var name: String
    var avatar: String
    var job: String
    var age: Int
}
