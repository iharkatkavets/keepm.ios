//
//  KdbEntryTableViewCell.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 12/1/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class KdbEntryTableViewCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var iconImageView: UIImageView!

    var viewModel: EntryCellViewModel? {
        didSet {
            label.text = self.viewModel?.title
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
