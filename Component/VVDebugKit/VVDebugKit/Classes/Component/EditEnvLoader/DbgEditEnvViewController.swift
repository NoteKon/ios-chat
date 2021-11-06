//
//  DbgEditEnvViewController.swift
//  VVDebugKit
//
//  Created by dailiangjin on 2020/4/10.
//

import UIKit
import SWFoundationKit
import SWBusinessKit

class DbgEditEnvModel {
    var env: Environment
    
    init(env: Environment) {
        self.env = env
    }
}

class DbgEditEnvViewController: DbgBaseViewController {
    var tableView: UITableView!
    var models: [DbgEditEnvModel]? {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
        loadData()
    }
    
    private func initUI() {
        self.view.backgroundColor = .white
        self.title = "Edit Env"
        
        tableView = UITableView(frame: .zero, style: .grouped)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func loadData() {
        models = Environment.allCases.map { (env) in
            let model = DbgEditEnvModel(env: env)
            //TODO: More...
            return model
        }
    }
}

extension DbgEditEnvViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let model = models?[indexPath.row]
        cell.textLabel?.text = model?.env.description
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = DbgEditEnvDetailViewController()
        vc.model = models?[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "It's highly recommended to restart the application after env changed."
    }
}
