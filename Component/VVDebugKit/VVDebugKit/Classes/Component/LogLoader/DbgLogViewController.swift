//
//  DbgLogViewController.swift
//  VVDebugKit
//
//  Created by dailiangjin on 2019/11/28.
//

import UIKit
import SnapKit
import SWFoundationKit

class DbgLogViewController: DbgBaseViewController {
    var tableView: UITableView!
    var models: [String]? {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        loadData()
    }
    
    private func initUI() {
        self.title = "Logs"
        self.view.backgroundColor = .white
        
        tableView = UITableView(frame: .zero, style: .plain)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-SAFEAREA_BOTTOM_HEIGHT)
        }
        tableView.register(DbgLogCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefreshAction), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func pullToRefreshAction() {
        loadData()
        tableView.refreshControl?.endRefreshing()
    }
    
    private func loadData() {
        models = SWLogger.loggerFilePaths()
    }
}

extension DbgLogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let model = models?[indexPath.row]
        
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = (model as NSString?)?.lastPathComponent
        cell.detailTextLabel?.text = "0"
        if let path = model {
            let attr = try? FileManager.default.attributesOfItem(atPath: path)
            if let size = attr?[.size] {
                cell.detailTextLabel?.text = "\(size)"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = DbgLogDetailViewController()
        vc.model = models?[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
            if let model = self?.models?[indexPath.row] {
                try? FileManager.default.removeItem(atPath: model)
            }
            
            tableView.beginUpdates()
            self?.models?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        
        return [action]
    }
}

class DbgLogCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
