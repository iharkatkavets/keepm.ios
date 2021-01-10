//
//  TitleViewModel.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/24/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa
import Swinject
import Foundation

class TitleViewModel {
    private let resolver: Resolver
    var router: TitleViewRouter!
    let titleSubject = BehaviorSubject<String?>(value: nil)
    var isCreateButtonEnabled: Observable<Bool> {
        return titleSubject.map {
            guard let value = $0 else {
                return false
            }
            return value.lengthOfBytes(using: .utf8) > 0
        }
    }
    let completion: (String) -> Void

    init(withResolver resolver: Swinject.Resolver,
         completion: @escaping (String) -> Void) {
        self.resolver = resolver
        self.completion = completion
    }

    func createWithTitle(_ title: String?) {
        if let title = title {
            self.completion(title)
            router.close()
        }
    }

    func cancelOpen() {
        router.close()
    }
}
