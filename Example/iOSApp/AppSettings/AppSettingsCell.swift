//
//  AppSettingsCell.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 3/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class AppSettingsCell: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var switchControl: UISwitch!
    var disposeBag = DisposeBag()

    var viewModel: AppSettingsCellViewModel? {
        didSet {
            titleLabel.text = viewModel?.title
            switchControl.isHidden = viewModel?.switchIsHidden ?? true
            switchControl.isOn = viewModel?.switchIsOn ?? false
            viewModel?.bindSwitchToggleObservable(switchControl.rx.value.asObservable(),
                                                  disposeBag: disposeBag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }

    
}
