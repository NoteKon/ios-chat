//
//  DbgNetDetailViewController.swift
//  VVDebugKit
//
//  Created by dailiangjin on 2021/06/24.
//

import UIKit
import SnapKit
import SWFoundationKit
import SWBusinessKit
import SWUIKit

class DbgNetDetailViewController: DbgBaseViewController {
    @IBOutlet weak var segmentView: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var model: SWRequestResponse?
    var dataArr: [Any]? = [Any]()
    
    @IBAction func selectAction(_ sender: Any) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        loadData()
    }
    
    private func initUI() {
        self.view.backgroundColor = .white
        
        self.title = "网络详情"
        
        let nib = UINib(nibName: "DbgNetDetailCell", bundle: getBundle())
        tableView.register(nib, forCellReuseIdentifier: "NetDetailCell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAction))
    }
    
    private func loadData() {
        if let model = model {
            
            // 响应时间
            let requestFeatchTime = model.netMonitorInfo?.timeToStr(model.netMonitorInfo?.requestFeatchTime)
            let requestStartTime = model.netMonitorInfo?.timeToStr(model.netMonitorInfo?.requestStartTime)
            let requestEndTime = model.netMonitorInfo?.timeToStr(model.netMonitorInfo?.requestStartEndTime)
            let responseStartTime = model.netMonitorInfo?.timeToStr(model.netMonitorInfo?.responseStartTime)
            let responseEndTime = model.netMonitorInfo?.timeToStr(model.netMonitorInfo?.responseEndTime)
            
            var duringStr = ""
            if let duratinTime = model.netMonitorInfo?.durationTime {
                if duratinTime < 1000 {
                    duringStr =   "\(duratinTime)ms"
                } else {
                    duringStr =  String(format: "%.2f", Float(duratinTime)/1000) + "s"
                }
            }
            
            // 请求
            let requestArr: [(String, [Any])] = [("请求地址",[model.url ?? ""]), ("请求方法", [model.method?.uppercased() ?? ""]), ("请求参数", [model.requestParams ?? [:]]),("请求头", [model.requestHeader ?? [:]]),("Request Featch Time", [requestFeatchTime ?? ""]),("Request Start Time", [requestStartTime ?? ""]), ("Request End Time", [requestEndTime ?? ""])]
            // 响应
            let responseArr: [(String, [Any])] = [("状态码", [model.httpCode ?? -1]),("请求结果", [model.result ?? ""]),("响应头", [model.responseHeader ?? [:]]), ("Response Start Time", [responseStartTime ?? ""]), ("response End Time", [responseEndTime ?? ""])]
            
            // 详情
            let detailArr: [(String, [Any])] = [("概览", [model.description ?? ""])]
            
            dataArr?.append(requestArr)
            dataArr?.append(responseArr)
            dataArr?.append(detailArr)
        }
    }
    
    @objc private func shareAction() {
        let fileURLs = SWLogger.loggerFilePaths().map { (path) -> URL in
            return URL(fileURLWithPath: path)
        }
        
        if let model = model {
            let vc = UIActivityViewController(activityItems: [model.description ?? ""], applicationActivities: nil)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func getTableDataArr() ->  [(String, [Any])]? {
        let index = segmentView.selectedSegmentIndex

        let arr = dataArr?[index] as? [(String, [Any])]
        return arr
    }
}

extension DbgNetDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.backgroundColor = UIColor.init(hex: 0xDCDCDC)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        let arr = getTableDataArr()
        let str = arr?[section].0
        label.text = "  \(str ?? "")"
        return label
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let arr = getTableDataArr()
        return arr?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let arr = getTableDataArr()
        let rowArr = arr?[section].1
        return rowArr?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetDetailCell", for: indexPath)
        if let cell = cell as? DbgNetDetailCell {
            let arr = getTableDataArr()
            let rowArr = arr?[indexPath.section].1 as? [Any]
            cell.netDetailLabel?.text = "\(rowArr?[indexPath.row] ?? "")"
        }
        return cell
    }
}
