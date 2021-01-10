//
//  PasswordViewController.swift
//  iOSApp
//
//  Created by igork on 2/4/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa
import Swinject
import Foundation

protocol PasswordViewInput: class {
    func getViewController() -> PasswordViewController
}

class PasswordViewController: UIViewController, PasswordViewInput, PopupPresentable {
    weak var popupViewController: PopupViewController?
    let resolver: Swinject.Resolver
    let viewModel: PasswordViewModel
    let disposeBag = DisposeBag()
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var openButton: UIButton!
    @IBOutlet private var processingView: SpinnerView!
    @IBOutlet private var processingContainerView: UIView!
    @IBOutlet private var buttonsStackView: UIStackView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var touchIDSwitch: UISwitch!
    @IBOutlet private var touchIDControlStackView: UIStackView!

    init(withViewModel model: PasswordViewModel,
         resolver: Resolver) {
        self.viewModel = model
        self.resolver = resolver
        super.init(nibName: "PasswordViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.isOpenButtonEnabled.bind(to: openButton.rx.isEnabled).disposed(by: disposeBag)
        passwordTextField.rx.text.bind(to: viewModel.passwordVariable).disposed(by: disposeBag)
        viewModel.processingHidden.debug().bind(to: processingContainerView.rx.isHidden).disposed(by: disposeBag)
        viewModel.processingVisible.bind(to: processingView.rx.isAnimating).disposed(by: disposeBag)
        viewModel.processingVisible.bind(to: passwordTextField.rx.isHidden).disposed(by: disposeBag)
        viewModel.processingVisible.bind(to: buttonsStackView.rx.isHidden).disposed(by: disposeBag)
        viewModel.processingVisible.bind(to: titleLabel.rx.isHidden).disposed(by: disposeBag)

        viewModel.touchIdControlHidden.bind(to: touchIDControlStackView.rx.isHidden).disposed(by: disposeBag)
        viewModel.touchIDOnSubject.bind(to: touchIDSwitch.rx.isOn).disposed(by: disposeBag)

        touchIDSwitch.rx.isOn.bind(to: viewModel.touchIDOnSubject).disposed(by: disposeBag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        passwordTextField.becomeFirstResponder()
    }

    func getViewController() -> PasswordViewController {
        return self
    }

    @IBAction func openDidTap(_ button: UIButton) {
        viewModel.open()
    }

    @IBAction func cancelDidTap(_ button: UIButton) {
        viewModel.cancelOpen()
    }
}
