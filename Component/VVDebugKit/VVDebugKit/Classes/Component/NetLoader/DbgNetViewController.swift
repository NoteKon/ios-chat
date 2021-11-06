//
//  DbgLogViewController.swift
//  VVDebugKit
//
//  Created by dailiangjin on 2021/06/21.
//

import UIKit
import SnapKit
import SWFoundationKit
import SWBusinessKit

class DbgNetViewController: DbgBaseViewController {
    var tableView: UITableView!
    var models: [SWRequestResponse]? {
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
        self.title = "监控列表"
        self.view.backgroundColor = .white
        
        tableView = UITableView(frame: .zero, style: .plain)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-SAFEAREA_BOTTOM_HEIGHT)
        }
        
        let nib = UINib(nibName: "DbgNetListCell", bundle: getBundle())
        tableView.register(nib, forCellReuseIdentifier: "DbgNetListCell")
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
        // 最新的监控数据显示最前面
        models = NetMonitorManager.getAllItem()?.reversed()
    }
}

extension DbgNetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DbgNetListCell", for: indexPath)
        if let cell = cell as? DbgNetListCell, let model = models?[indexPath.row] {
            let color: UIColor = model.httpCode == 200 ? .green : .red
            cell.urlLabel.text = model.url
            cell.statusLabel.text = " \(model.httpCode ?? -1) "
            cell.statusLabel.backgroundColor = color
            cell.methodLabel.text = model.method?.uppercased()
            
            var duringStr = "--"
            if let duratinTime = model.netMonitorInfo?.durationTime {
                if duratinTime < 1000 {
                    duringStr =   "\(duratinTime)ms"
                } else {
                    duringStr =  String(format: "%.2f", Float(duratinTime)/1000) + "s"
                }
            }
           
            let dateStr = model.netMonitorInfo?.timeToStr(model.netMonitorInfo?.requestFeatchTime, format: "YY-MM-dd HH:mm:ss:ms") ?? ""
            cell.timeLabel.text = "\(dateStr) 耗时: \(duringStr)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = UIStoryboard.init(name: "DbgNet", bundle: getBundle()).instantiateViewController(withIdentifier: "DbgNetDetailViewController") as? DbgNetDetailViewController
        vc!.model = models?[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
            tableView.beginUpdates()
            self?.models?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        
        return [action]
    }
}
