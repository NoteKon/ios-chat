//
//  DbgMainViewController.swift
//  Pods-VVDebugKit_Example
//
//  Created by dailiangjin on 2019/9/2.
//

import UIKit
import SnapKit

class DbgMainViewController: DbgBaseViewController, UITableViewDelegate, UITableViewDataSource {
    private static let kCellReuseIdentifier = "CellReuseIdentifier"
    private var tableView: UITableView?
    private var groups: [[DbgLoader]] = [[DbgLoader]]()
    static let reloadDataNote = NSNotification.Name("needReloadDataNote")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Debug"
        self.view.backgroundColor = .white
        let leftItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
        self.navigationItem.leftBarButtonItem = leftItem
        
        self.tableView = UITableView(frame: CGRect.zero, style: .grouped)
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.register(DbgTableViewCell.self, forCellReuseIdentifier: DbgMainViewController.kCellReuseIdentifier)
        self.view.addSubview(self.tableView!)
        self.tableView?.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.view).inset(UIEdgeInsets.zero)
        })
        
        #if DEBUG
        #else
        self.initTableHeader()
        #endif
        setModels(VVDebugKit.default.loaders)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView?.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: DbgMainViewController.reloadDataNote, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initTableHeader() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        self.tableView?.tableHeaderView = view
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        label.backgroundColor = .red
        label.textColor = .white
        label.textAlignment = .center
        label.text = "⚠️ 本页面应只在Debug包中显示 ⚠️"
        view.addSubview(label)
    }
    
    @objc func reloadTableView() {
        self.tableView?.reloadData()
    }
    
    @objc func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setModels(_ models: [DbgLoader]?) {
        self.groups.removeAll()
        var others: [DbgLoader] = []
        models?.forEach({ (loader) in
            if let group = loader.debug_group() {
                var found = false
                for (index, var cur) in self.groups.enumerated() {
                    let sample = cur.first!
                    if let group2 = sample.debug_group(), group == group2 {
                        found = true
                        cur.append(loader)
                        self.groups[index] = cur
                    }
                }
                
                if !found {
                    self.groups.append([loader])
                }
            } else {
                others.append(loader)
            }
        })
        if others.count > 0 {
            self.groups.append(others)
        }
        reloadTableView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.groups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DbgMainViewController.kCellReuseIdentifier, for: indexPath) as! DbgTableViewCell
        let model = self.groups[indexPath.section][indexPath.row]
        cell.model = model
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = self.groups[indexPath.section][indexPath.row]
        if let m = model as? DbgDetailLoader, let clazz = m.debug_vc() {
            let vc = clazz.init()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            model.debug_action()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var text = ""
        for model in self.groups[section] {
            if let comment = model.debug_comment() {
                text += comment + "\n"
            }
        }
        if section == tableView.numberOfSections - 1 {
            text += "\n" + getAppInfo() + "\n"
        }
        return text
    }
    
    private func getAppInfo() -> String {
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] ?? ""
        #if DEBUG
        let compile = "Debug"
        #else
        let compile = "Release"
        #endif
        
        return "v\(version) (\(build)) - \(compile)" + "\n" + "\(bundleId)"
    }
}
