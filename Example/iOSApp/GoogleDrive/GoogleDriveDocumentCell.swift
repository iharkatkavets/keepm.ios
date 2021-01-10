//
//  GoogleDriveDocumentCell.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/3/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class GoogleDriveDocumentCell: UITableViewCell, Decoratable {
    @IBOutlet var nameLabel: UILabel!
    var viewModel: GoogleDriveItem? {
        didSet {
            self.nameLabel.text = self.viewModel?.name
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

class FileDecorator: ViewDecorator {
    func decorate(view: GoogleDriveDocumentCell) {
        view.nameLabel.font = UIFont.preferredFont(forTextStyle: .body)
        view.accessoryType = .none
    }
}

class FolderDecorator: ViewDecorator {
    func decorate(view: GoogleDriveDocumentCell) {
        view.nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        view.accessoryType = .disclosureIndicator
    }
}
