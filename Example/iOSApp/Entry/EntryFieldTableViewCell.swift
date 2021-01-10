//
//  EntryFieldTableViewCell.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 12/29/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class EntryFieldTableViewCell: UITableViewCell {
    @IBOutlet private var keyLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!

    var viewModel: EntryFieldViewModel? {
        didSet {
            keyLabel.text = self.viewModel?.key
            valueLabel.text = self.viewModel?.value
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
    
}
