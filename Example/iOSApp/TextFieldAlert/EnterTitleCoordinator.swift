//
//  EnterTitleCoordinator.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/23/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

protocol EnterTitleCoordinatorInput {
    func startWith(presentingViewController : UIViewController, title: String?, completion: @escaping (String?) -> Void)
}

class EnterTitleCoordinator: EnterTitleCoordinatorInput {
    func startWith(presentingViewController : UIViewController, title: String?, completion: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
        }
        let saveAction =  UIAlertAction(title: "Save", style: .default) { _ in
            completion(alertController.textFields?.first?.text)
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(saveAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)

        presentingViewController.present(alertController, animated: true)
    }
}

