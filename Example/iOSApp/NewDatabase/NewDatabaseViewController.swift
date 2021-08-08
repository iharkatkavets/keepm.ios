//
//  NewDatabaseViewController.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/27/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Swinject
import Foundation

protocol NewDatabaseViewInput: AnyObject {
    func getViewController() -> NewDatabaseViewController
    func showEnteringPasswordsError(text: String)
    func clearEnteringPasswordsError()
    func setCreateButtonEnabled(enabled: Bool)
}

class NewDatabaseViewController: UIViewController, NewDatabaseViewInput, PopupPresentable {
    weak var popupViewController: PopupViewController?
    let resolver: Swinject.Resolver
    var presenter: NewDatabasePresenter!
    @IBOutlet private var filenameTextField: UITextField!
    @IBOutlet private var password1TextField: UITextField!
    @IBOutlet private var password2TextField: UITextField!
    @IBOutlet private var createButton: UIButton!
    @IBOutlet private var cancelButton: UIButton!
    @IBOutlet private var passwordsErrorLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var touchIDSwitch: UISwitch!
    @IBOutlet private var touchIDControlStackView: UIStackView!
    weak var passwordChangeObserver: NSObjectProtocol?
    weak var passwordConfirmChangeObserver: NSObjectProtocol?
    weak var filenameChangeObserver: NSObjectProtocol?


    init(withResolver: Resolver) {
        self.resolver = withResolver
        super.init(nibName: "NewDatabaseViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if let token = filenameChangeObserver {
            NotificationCenter.default.removeObserver(token)
        }

        if let token = passwordChangeObserver {
            NotificationCenter.default.removeObserver(token)
        }

        if let token = passwordConfirmChangeObserver {
            NotificationCenter.default.removeObserver(token)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.passwordChangeObserver = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: password1TextField, queue: nil) { [weak self] (notification) in
            self?.presenter.acceptPassword1(value: self?.password1TextField.text ?? "")
        }

        self.passwordConfirmChangeObserver = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: password2TextField, queue: nil) { [weak self] (notification) in
            self?.presenter.acceptPassword2(value: self?.password2TextField.text ?? "")
        }

        self.filenameChangeObserver = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: filenameTextField, queue: nil) { [weak self] (notification) in
            self?.presenter.acceptFilename(value: self?.filenameTextField.text ?? "")
        }

        presenter.loadInitialState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
 
    func getViewController() -> NewDatabaseViewController {
        return self
    }

    func showEnteringPasswordsError(text: String) {
        passwordsErrorLabel.text = text
    }

    func clearEnteringPasswordsError() {
        passwordsErrorLabel.text = nil
    }

    func setCreateButtonEnabled(enabled: Bool) {
        createButton.isEnabled = enabled
    }

    @IBAction func createDidTap(_ button: UIButton) {
        presenter.create()
    }

    @IBAction func cancelDidTap(_ button: UIButton) {
        presenter.cancel()
    }
}
