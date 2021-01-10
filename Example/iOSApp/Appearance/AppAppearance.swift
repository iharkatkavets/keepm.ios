//
//  AppAppearance.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/6/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class AppApperance {
    func apply() {
        applyMain()
        applyFilesListAppearance()
        applyPopoverAppearance()
        applyGoogleDriveSettings()
        applyKdbGroupAppearance()
        applyTreeActionsPopup()
        applyPasswordView()
        applyEntriesAppearance()
        applyPrivacyPolicyAppearance()
        applyPopupAppearance()
        applyAppLabelApperance()
    }

    func applyAppLabelApperance() {
        AppLabel.appearance().textColor = AppColors[.label]
    }

    func applyMain() {
        let tabBarAppearance = UITabBar.appearance(whenContainedInInstancesOf: [AppTabBarController.self])
        tabBarAppearance.barTintColor = AppColors[.secondary]

        let tabBarItemAppearance = UITabBarItem.appearance(whenContainedInInstancesOf: [AppTabBarController.self])
        tabBarItemAppearance.setTitleTextAttributes(
            [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15),
             NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)], for: .normal)
        tabBarItemAppearance.setTitleTextAttributes(
            [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 15),
             NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)

    }

    func applyFilesListAppearance() {
        let barAppearance =
        UINavigationBar.appearance(whenContainedInInstancesOf: [AppNavigationController.self])
//        barAppearance.barTintColor = UIColor.white


    }

    func applyGoogleDriveSettings() {
        UISwitch.appearance(whenContainedInInstancesOf: [GoogleDriveSettingsViewController.self]).onTintColor = AppColors[.selected]
    }

    func applyPopoverAppearance() {

    }

    func applyKdbGroupAppearance() {
        let barItemAppearance =
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [AppNavigationController.self])
        barItemAppearance.tintColor = AppColors[.secondary]
    }

    func applyTreeActionsPopup() {
        TreeActionButton.appearance().tintColor = AppColors[.secondary]
    }

    func applyPasswordView() {
        SpinnerView.appearance().lineColor = AppColors[.secondary]
    }

    func applyEntriesAppearance() {
        EntrySectionHeader.appearance().backgroundColor = AppColors[.secondary]
        UILabel.appearance(whenContainedInInstancesOf: [EntrySectionHeader.self]).textColor = UIColor.white

        let image = ImageBuilder.addCustomFieldButton(CGSize(width: 50, height: 50))
            AddCustomFieldButton.appearance().setBackgroundImage(image, for: .normal)

        let deleteImg = ImageBuilder.deleteButton(CGSize(width: 50, height: 50))
        DeleteButton.appearance().setBackgroundImage(deleteImg, for: .normal)
    }

    func applyPrivacyPolicyAppearance() {
        let deleteImg = ImageBuilder.addCustomFieldButton(CGSize(width: 50, height: 50))
        PrivacyPolicyButton.appearance().setBackgroundImage(deleteImg, for: .normal)
    }

    func applyPopupAppearance() {
        PopupCancelButton.appearance().color = AppColors[.secondary]
        PopupOKButton.appearance().color = AppColors[.secondary]
        ErrorButton.appearance().color = AppColors[.error]
    }
}
