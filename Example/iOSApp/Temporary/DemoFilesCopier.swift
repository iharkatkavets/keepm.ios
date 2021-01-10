//
//  DevFilesCopier.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 11/21/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

struct DemoFilesCopier {
    let userDefaults = UserDefaults.standard
//    let outLog = OSLog(subsystem: , category: String(describing: self))

    var isCopied: Bool {
        return userDefaults.bool(forKey: "isCopied")
    }

    func setIsCopied(_ value: Bool) {
        userDefaults.set(value, forKey: "isCopied")
    }


    func createDevFilesIfNeeded() {
        if isCopied == false {
            let files = ["Demo-secrets.kdbx", "Demo-secrets.kdbx.meta.json"]
            let fileManager = FileManager.default
            if let documentsDirUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                files.forEach { (file) in
                    if let testKdbxURL = Bundle.main.url(forResource: file, withExtension: nil) {
                        let targetPath = documentsDirUrl.appendingPathComponent(file)
                        do {
                            try fileManager.copyItem(at: testKdbxURL, to: targetPath)
                        } catch  {
                            print("not copied \(error)")
                        }
                    }
                }

                setIsCopied(true)

            }
        }
    }
}
