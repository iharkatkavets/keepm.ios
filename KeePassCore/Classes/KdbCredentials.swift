//
//  KeePassword.swift
//  Pods
//
//  Created by Igor Kotkovets on 8/6/17.
//
//

import Foundation

public enum KdbCredentials {
    case password(String)
    case passwordAndKeyFile(String, FileInputStream)
}
