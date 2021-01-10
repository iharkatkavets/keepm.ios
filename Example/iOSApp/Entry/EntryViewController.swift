//
//  EntryViewController.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 12/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import KeePassCore
import RxSwift
import RxCocoa

protocol EntryViewInput {
    func getViewController() -> UIViewController
}

class EntryViewController: UIViewController, EntryViewInput {
    let viewModel: EntryViewModelInput
    var disposeBag = DisposeBag()
    @IBOutlet var stackView: UIStackView!
    var cellNib = UINib(nibName: "EntryCell", bundle: nil)
    let servicesPool: ServicesPoolInput
    @IBOutlet var scrollView: UIScrollView!
    var viewModels = [EntryFieldViewModel]()
    var editedViewModelsTags = [Int]()
    @IBOutlet var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var tapGestureRecognizer: UITapGestureRecognizer!
    let once = DispatchOnce()

    init(viewModel: EntryViewModelInput, servicesPool: ServicesPoolInput) {
        self.viewModel = viewModel
        self.servicesPool = servicesPool
        super.init(nibName: "EntryViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()

        self.servicesPool.keyboardService?.keyboardHeightObservable
        .do(onNext: { [unowned self] in
            var bottom = $0
            if $0 > 0 {
                bottom += self.scrollViewBottomConstraint.constant
            }
            let contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: bottom, right: 0.0)
            self.scrollView.contentInset = contentInset
        })
        .subscribe().disposed(by: disposeBag)
    }

    func addCellWithAnimation(_ cellViewModel: EntryFieldViewModel) {
        var delay: TimeInterval = 0
        if viewModel.customStrings.count == 0 && viewModel.newStrings.count == 1 {
            let nib = UINib(nibName: "EntrySectionHeader", bundle: nil)
            if let headerView = nib.instantiate(withOwner: self, options: nil).first as? EntrySectionHeader {
                headerView.isHidden = true
                headerView.alpha = 0
                let total = self.stackView.arrangedSubviews.count
                self.stackView.insertArrangedSubview(headerView, at: total-1)

                UIView.animate(withDuration: 0.2, delay: delay, options: .curveLinear, animations: {
                    headerView.alpha = 1
                    headerView.isHidden = false
                })
                delay += 0.1
            }
        }

        if let view = self.cellNib.instantiate(withOwner: self, options: nil).first as? EntryCell {
            view.isHidden = true
            view.alpha = 0
            let tag = viewModels.count
            viewModels.append(cellViewModel)
            view.viewModel = cellViewModel
            view.valueTextView.delegate = self
            view.delegate = self
            view.valueTextView.tag = tag
            let total = self.stackView.arrangedSubviews.count
            self.stackView.insertArrangedSubview(view, at: total-1)
            view.panGestureRecognizer.shouldRequireFailure(of: scrollView.panGestureRecognizer)

            UIView.animate(withDuration: 0.2, delay: delay, options: .curveLinear, animations: {
                view.alpha = 1
                view.isHidden = false
            }, completion: { _ in
                view.valueTextView.becomeFirstResponder()
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        once.perform {
            self.displayContentAndStartEditing()
        }
    }

    func configureNavigationBar() {
        var buttons = [UIBarButtonItem]()

        if viewModel.isAddVisible() {
            let addButton = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(saveDidTap(_:)))
            buttons.append(addButton)
        }

        if viewModel.isSaveVisible() {
            let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveDidTap(_:)))
            buttons.append(saveButton)
        }

        self.navigationItem.rightBarButtonItems = buttons
    }

    @objc func saveDidTap(_ sender: UIBarButtonItem) {
        var editedViewModels = [EntryFieldViewModel]()
        for index in editedViewModelsTags {
            editedViewModels.append(viewModels[index])
        }
        viewModel.saveChanges(editedViewModels)
    }

    func displayContentAndStartEditing() {
        viewModels.removeAll()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for model in viewModel.defaultStrings {
            if let view = self.cellNib.instantiate(withOwner: self, options: nil).first as? EntryCell {
                view.isHidden = true
                view.alpha = 0
                let tag = viewModels.count
                viewModels.append(model)
                view.viewModel = model
                view.valueTextView.delegate = self
                view.delegate = self
                view.valueTextView.tag = tag
                self.stackView.addArrangedSubview(view)
            }
        }

        if viewModel.customStrings.count > 0 ||
        viewModel.newStrings.count > 0 {
            let nib = UINib(nibName: "EntrySectionHeader", bundle: nil)
            if let headerView = nib.instantiate(withOwner: self, options: nil).first as? EntrySectionHeader {
                headerView.isHidden = true
                headerView.alpha = 0
                stackView.addArrangedSubview(headerView)
            }
        }

        for model in viewModel.customStrings {
            if let view = self.cellNib.instantiate(withOwner: self, options: nil).first as? EntryCell {
                view.isHidden = true
                view.alpha = 0
                let tag = viewModels.count
                viewModels.append(model)
                view.viewModel = model
                view.valueTextView.delegate = self
                view.delegate = self
                view.valueTextView.tag = tag
                self.stackView.addArrangedSubview(view)
                view.panGestureRecognizer.shouldRequireFailure(of: scrollView.panGestureRecognizer)
            }
        }

        for model in viewModel.newStrings {
            if let view = self.cellNib.instantiate(withOwner: self, options: nil).first as? EntryCell {
                view.isHidden = true
                view.alpha = 0
                let tag = viewModels.count
                viewModels.append(model)
                view.viewModel = model
                view.valueTextView.delegate = self
                view.delegate = self
                view.valueTextView.tag = tag
                self.stackView.addArrangedSubview(view)
                view.panGestureRecognizer.shouldRequireFailure(of: scrollView.panGestureRecognizer)
            }
        }

        let nib = UINib(nibName: "AddCustomFieldButton", bundle: nil)
        if let button = nib.instantiate(withOwner: self, options: nil).first as? AddCustomFieldButton {
            button.alpha = 0
            button.isHidden = true
            button.setTitle("ADD CUSTOM FIELD", for: .normal)
            button.addTarget(self, action: #selector(addField(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }

        var delay: TimeInterval = 0
        stackView.arrangedSubviews.forEach { (view) in
            delay += 0.1
            UIView.animate(withDuration: 0.2, delay: delay, options: .curveEaseIn, animations: {
                view.alpha = 1
                view.isHidden = false
            })
        }
    }

    func getViewController() -> UIViewController {
        return self
    }

    @IBAction func addField(_ button: UIButton) {
        viewModel.addCustomValue {
            self.addCellWithAnimation($0)
        }
    }
}

extension EntryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let tag = textView.tag
        let viewModel = viewModels[tag ]
        viewModel.changedValue = textView.text

        let containsEditedViewModel = editedViewModelsTags.contains { value -> Bool in
            value == tag
        }
        if !containsEditedViewModel {
            editedViewModelsTags.append(tag)
        }
    }

    @IBAction func tapGestureRecognizerAction(_ gesture: UITapGestureRecognizer) {
        gesture.view?.endEditing(true)
    }
}

extension EntryViewController: EntryCellDelegate {
    func didClickCopy(_ cellViewModel: EntryFieldViewModel) {
        viewModel.copyValueToClipboard(cellViewModel)
    }

    func didClickDelete(_ cell: EntryCell) {
        guard let cellViewModel = cell.viewModel else { return }
        UIView.animate(withDuration: 0.3, animations: {
            cell.alpha = 0.0
            cell.isHidden = true
        }) { (_) in
            self.viewModel.deleteStringField(cellViewModel)
            cell.removeFromSuperview()
        }

    }
}

