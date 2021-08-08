//
//  AppSettingsCell.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 3/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class AppSettingsCell: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var switchControl: UISwitch!

    var viewModel: AppSettingsModel? {
        didSet {
            titleLabel.text = viewModel?.title
            switchControl.isHidden = viewModel?.boolValue == nil
            switchControl.isOn = viewModel?.boolValue ?? false
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.switchControl.addTarget(self, action: #selector(userDidChangeSwitchControl(_:)), for: .valueChanged)
    }

    @objc private func userDidChangeSwitchControl(_ value: Bool) {
        viewModel?.boolValueChangedHandler?(value)
    }
    

    override func prepareForReuse() {
        
    }

    
}
