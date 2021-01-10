//
//  EntryViewModelInput.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/25/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol EntryViewModelInput {
    var defaultStrings: [EntryFieldViewModel] { get }
    var customStrings: [EntryFieldViewModel] { get }
    var newStrings: [EntryFieldViewModel] { get }
    func addCustomValue(_ completion: @escaping (EntryFieldViewModel) -> Void)
    func copyValueToClipboard(_ viewModel: EntryFieldViewModel)
    func isAddVisible() -> Bool
    func isSaveVisible() -> Bool
    func saveChanges(_ list: [EntryFieldViewModel])
    func deleteStringField(_ viewModel: EntryFieldViewModel)
}
