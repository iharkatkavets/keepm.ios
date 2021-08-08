//
//  AppSettingsViewController.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/29/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Swinject
import Foundation

protocol AppSettingsViewInput: AnyObject {
    func getViewController() -> UIViewController
    func displaySettingsList(_: [AppSettingsModel])
}

class AppSettingsViewController: UIViewController, AppSettingsViewInput, UITableViewDataSource, UITableViewDelegate {
    let resolver: Swinject.Resolver
    let presenter: AppSettingsPresenter
    var models = [AppSettingsModel]()
    @IBOutlet private var tableView: UITableView!

    init(withViewModel model: AppSettingsPresenter,
         resolver: Resolver) {
        self.presenter = model
        self.resolver = resolver
        super.init(nibName: "AppSettingsViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "AppSettingsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AppSettingsCell")
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.didTriggerViewWillAppear()
    }

    func getViewController() -> UIViewController {
        return self
    }
    
    func displaySettingsList(_ list: [AppSettingsModel]) {
        self.models = list
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppSettingsCell", for: indexPath) as! AppSettingsCell
        cell.viewModel = models[indexPath.row]
        return cell
    }
}
