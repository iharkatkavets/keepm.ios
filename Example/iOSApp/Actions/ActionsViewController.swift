//
//  ActionsViewController.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/22/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa
import Swinject
import Foundation

enum TreeAction: Int {
    case addGroup = 0x01
    case addEntry
}

protocol ActionsViewInput: class {
    func getViewController() -> UIViewController
}

class ActionsViewController: UIViewController, ActionsViewInput {
    let resolver: Swinject.Resolver
    let viewModel: ActionsViewModel
    let disposeBag = DisposeBag()
    let actions: [TreeAction]
    @IBOutlet private var stackView: UIStackView!
    let completion: (TreeAction) -> Void

    init(withViewModel model: ActionsViewModel,
         resolver: Resolver, actions:[TreeAction], completion: @escaping (TreeAction) -> Void) {
        self.viewModel = model
        self.resolver = resolver
        self.actions = actions
        self.completion = completion
        super.init(nibName: "ActionsViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addActions()
    }

    func addActions() {
        actions.forEach { (action) in
            var buttonNib: UINib?
            if case .addGroup = action {
                buttonNib = UINib(nibName: "AddGroupButton", bundle: nil)
            }
            else if case .addEntry = action {
                buttonNib = UINib(nibName: "AddEntryButton", bundle: nil)
            }

            if let button = buttonNib?.instantiate(withOwner: self, options: nil).first as? UIButton {
                button.heightAnchor.constraint(equalToConstant: treeActionButtonHeight).isActive = true
                button.tag = action.rawValue
                button.addTarget(self, action: #selector(actionDidTap(_:)), for: .touchUpInside)
                stackView.addArrangedSubview(button)
            }
        }
    }

    @objc func actionDidTap(_ sender: UIButton) {
        guard let action = TreeAction(rawValue: sender.tag) else {
            dismiss(animated: true)
            return
        }

        dismiss(animated: true) {
            self.completion(action)
        }
    }

    func getViewController() -> UIViewController {
        return self
    }

    func titleForAction(_ action: TreeAction) -> String {
        switch action {
        case .addEntry:
            return "Add Entry"
        case .addGroup:
            return "Add Group"
        default:
            return "Unknown"
        }
    }
}
