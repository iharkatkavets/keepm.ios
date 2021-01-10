//
//  TitleViewController.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/24/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa
import Swinject
import Foundation

protocol TitleViewInput: class {
    func getViewController() -> TitleViewController
}

class TitleViewController: UIViewController, TitleViewInput, PopupPresentable {
    weak var popupViewController: PopupViewController?
    let resolver: Swinject.Resolver
    let viewModel: TitleViewModel
    let disposeBag = DisposeBag()
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var createButton: UIButton!
    @IBOutlet var buttonsStackView: UIStackView!
    @IBOutlet var titleLabel: UILabel!

    init(withViewModel model: TitleViewModel,
         resolver: Resolver) {
        self.viewModel = model
        self.resolver = resolver
        super.init(nibName: "TitleViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.isCreateButtonEnabled.bind(to: createButton.rx.isEnabled).disposed(by: disposeBag)
        titleTextField.rx.text.bind(to: viewModel.titleSubject).disposed(by: disposeBag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleTextField.becomeFirstResponder()
    }

    func getViewController() -> TitleViewController {
        return self
    }

    @IBAction func createDidTap(_ button: UIButton) {
        viewModel.createWithTitle(titleTextField.text)
    }

    @IBAction func cancelDidTap(_ button: UIButton) {
        viewModel.cancelOpen()
    }
}
