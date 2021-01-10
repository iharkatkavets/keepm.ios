//
//  EntryCell.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/6/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import os.log

protocol EntryCellDelegate: class {
    func didClickCopy(_ viewModel: EntryFieldViewModel)
    func didClickDelete(_ cell: EntryCell)
}

class EntryCell: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueTextView: UITextView!
    @IBOutlet private var deleteButton: UIButton!
    weak var delegate: EntryCellDelegate?
    var outLog = OSLog(subsystem: APP_LOG_SUBSYSTEM, category: String(describing: self))
    @IBOutlet var deleteLeftConstraint: NSLayoutConstraint!
    private var deleteButtonVisibleInternal: Bool = true
    @IBOutlet var contentTrailingConstraint: NSLayoutConstraint!
    let panGestureRecognizer = PanDirectionGestureRecognizer(direction: .horizontal)

    var viewModel: EntryFieldViewModel? {
        didSet {
            if let changedValue = self.viewModel?.changedValue {
                valueTextView.text = changedValue
            } else {
                valueTextView.text = self.viewModel?.value
            }
            titleLabel.text = self.viewModel?.key
            setAllowDeleteAction(self.viewModel?.isDeletable ?? false)
        }
    }

    func setAllowDeleteAction(_ flag: Bool) {
        deleteButton.isHidden = !flag

    }

    override func awakeFromNib() {
        super.awakeFromNib()
        valueTextView.textContainer.heightTracksTextView = true
        valueTextView.isScrollEnabled = false
        self.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.addTarget(self, action: #selector(panGestureDidRecognized))
        panGestureRecognizer.delegate = self

    }

    @IBAction func didTapCopy(_ button: UIButton) {
        guard let viewModel = self.viewModel else {
            return
        }
        self.delegate?.didClickCopy(viewModel)
    }

    @objc func panGestureDidRecognized(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        gesture.setTranslation(.zero, in: self)
        var targetOffset = min(contentTrailingConstraint.constant-translation.x,
                               self.deleteButton.bounds.size.width+deleteLeftConstraint.constant)
        os_log(.info, log: outLog, "target %s", "\(targetOffset)")
        targetOffset = max(0, targetOffset)
        contentTrailingConstraint.constant = targetOffset

        if gesture.state == .ended {
            endPanGesture()
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        os_log(.info, log: outLog, "scrollviewwillbegindragging")
    }

    func endPanGesture() {
        if contentTrailingConstraint.constant > deleteButton.bounds.size.width/2 &&
            deleteButtonVisibleInternal == false {
            showDeleteButton()
        }
        else if contentTrailingConstraint.constant < deleteButton.bounds.size.width {
            hideDeleteButton()
        }
    }

    fileprivate func showDeleteButton() {
        let right = self.deleteButton.bounds.size.width+deleteLeftConstraint.constant
        self.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.contentTrailingConstraint.constant = right
            self.layoutIfNeeded()
        }) { _ in
            self.deleteButtonVisibleInternal = true
        }
    }

    fileprivate func hideDeleteButton() {
        self.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.contentTrailingConstraint.constant = 0
            self.layoutIfNeeded()
        }) { _ in
            self.deleteButtonVisibleInternal = false
        }
    }

    func cancelDrag() {
        panGestureRecognizer.isEnabled = false
        panGestureRecognizer.isEnabled = true
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if targetContentOffset.pointee.x > deleteButton.bounds.size.width {
            targetContentOffset.pointee.x = deleteButton.bounds.size.width
        }
    }

    @IBAction func deleteDidTap(_ button: UIButton) {
        guard self.viewModel != nil else {
            return
        }
        self.delegate?.didClickDelete(self)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
