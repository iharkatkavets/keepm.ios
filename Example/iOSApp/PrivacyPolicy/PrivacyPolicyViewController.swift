//
//  PrivacyPolicyViewController.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/16/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa
import Swinject
import Foundation
import WebKit

protocol PrivacyPolicyViewInput: class {
    func getViewController() -> UIViewController
}

class PrivacyPolicyViewController: UIViewController, PrivacyPolicyViewInput {
    let resolver: Swinject.Resolver
    let disposeBag = DisposeBag()
    let url = URL(string: "https://katkavets.space/crypt/privacy-policy.html")
    @IBOutlet private var webView: WKWebView!

    init(resolver: Resolver) {
        self.resolver = resolver
        super.init(nibName: "PrivacyPolicyViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = url {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
    }

    func getViewController() -> UIViewController {
        return self
    }

    @IBAction func didTapAgreePrivacyPolicy(_ button: UIButton) {
        guard let servicesPool = resolver.resolve(ServicesPoolInput.self),
        let appSettings = servicesPool.appSettingsService else { return }

        appSettings.set(true, forKey: .privacyPolicyAccepted)
        dismiss(animated: true)
    }
}
