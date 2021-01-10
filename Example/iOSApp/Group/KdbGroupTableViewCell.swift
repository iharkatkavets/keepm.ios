//
//  KdbGroupTableViewCell.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 11/25/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class KdbGroupTableViewCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var iconImageView: UIImageView!

    var viewModel: GroupCellViewModel? {
        didSet {
            label.text = self.viewModel?.name
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
