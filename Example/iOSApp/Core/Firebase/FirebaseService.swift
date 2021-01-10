//
//  FirebaseService.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/16/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseServiceInput {

}

class FirebaseService: FirebaseServiceInput {
    func start() {
        FirebaseApp.configure()
    }
}
