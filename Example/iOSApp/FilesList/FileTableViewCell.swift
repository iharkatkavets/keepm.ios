//
//  FileTableViewCell.swift
//  IKKeePassCore
//
//  Created by Igor Kotkovets on 7/8/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import os.log

protocol FileTableViewCellDelegate: AnyObject {
    func didTapShowInfo(_ info: String)
}

final class FileTableViewCell: UITableViewCell {
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet private var modificationDateLabel: UILabel!
    var fileModel: StorageDisplayItem? {
        didSet {
            layoutCell()
        }
    }
    weak var viewController: UIViewController?
    weak var delegate: FileTableViewCellDelegate?
    weak var transferringContextManager: TransferringContextManagerInput?
    var redrawTimer: CADisplayLink?
    let outLog = OSLog(subsystem: APP_LOG_SUBSYSTEM, category: String(describing: self))

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(model: StorageDisplayItem,
               transferringContextManager: TransferringContextManagerInput,
               viewController: UIViewController?,
               delegate: FileTableViewCellDelegate) {
        self.fileModel = model
        self.transferringContextManager = transferringContextManager
        self.delegate = delegate
        self.viewController = viewController
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func layoutCell() {
        titleLabel.text = fileModel?.document.name
        modificationDateLabel.text = fileModel?.dateString

        if fileModel?.metadata?.type == .googleDrive {
            rightButton.isHidden = false
            rightButton.setImage(AppImage.sync, for: .normal)
        }
        else if fileModel?.metadata?.type == .local,
            fileModel?.metadata?.info != nil {
            rightButton.isHidden = false
            rightButton.setImage(AppImage.info, for: .normal)
        }
        else {
            rightButton.isHidden = true
        }

        if let name = fileModel?.document.name, MetadataManager.nameHasKdbSuffics(name) == true {
            iconImageView.image = AppImage.kdbfile.image
        }
        else {
            iconImageView.image = AppImage.question.image
        }
    }

    @IBAction func syncDidTap(_ button: UIButton) {
        guard let metadata = self.fileModel?.metadata else { return }

        if metadata.type == .googleDrive {
            syncFileWithGoogleDrive()
        }
        else if metadata.type == .local,
            let info = metadata.info {
            delegate?.didTapShowInfo(info)
        }
    }

    func checkForTrasferringAndStartRedrawTimer() {
        guard redrawTimer == nil else {
            return
        }

        redrawTimer = CADisplayLink(target: self, selector: #selector(redrawTransferringProgress(_:)))
        redrawTimer?.preferredFramesPerSecond = 1
        redrawTimer?.add(to: RunLoop.current, forMode: .default)
    }

    @objc func redrawTransferringProgress(_ timer: CADisplayLink) {
        if let url = fileModel?.document.url, (transferringContextManager?.fetchContextFor(url)) == nil {
            rightButton.stopRotation()
            timer.invalidate()
            stopRedrawTimer()
            os_log(.debug, log: self.outLog, "stopRotation stopRedrawTimer");
        }
        else if !rightButton.isRotating {
            os_log(.debug, log: self.outLog, "startRotation");
            rightButton.startRotation()
        }
    }

    func stopRedrawTimer() {
        redrawTimer?.invalidate()
        redrawTimer = nil
    }

    func syncFileWithGoogleDrive() {
        guard let viewModel = self.fileModel,
            let servicesPool = self.fileModel?.servicesPool,
            let googleDriveService = servicesPool.googleDriveService,
            let vc = self.viewController else { return }


        googleDriveService.synchronizeFile(viewModel.document, vc: vc)
        checkForTrasferringAndStartRedrawTimer()
    }

    override func prepareForReuse() {
        stopRedrawTimer()
        super.prepareForReuse()
    }
}
