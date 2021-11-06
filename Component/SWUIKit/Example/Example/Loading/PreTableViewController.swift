//
//  PreTableViewController.swift
//  SWUIKit_Example
//
//  Created by ice on 2019/11/4.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class PreTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: SWPreTableView!
    
    var cells: Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.tableView.delegate = self
        self.tableView.swDataSource = self
        self.tableView.register(TestTableViewCell.self, forCellReuseIdentifier: "TestTableViewCell")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadData()
        }
    }
    
    func loadData() {
        self.cells = ["我是1","我是2","我是3"] + ["我是1","我是2","我是3"] + ["我是1","我是2","我是3"]
        self.tableView.reloadData()
    }
}

extension PreTableViewController: SWTableViewDataSource, UITableViewDelegate {
    func swPreviewTableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cells.count
    }
    
    func swPreviewTableView(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell: TestTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TestTableViewCell", for: indexPath) as! TestTableViewCell
       // cell.upLoadCell(text: self.cells[indexPath.row])
        cell.textLabel?.text = self.cells[indexPath.row]
        return cell
    }
    
    func registerCell() -> UITableViewCell {
        return TestTableViewCell.init(style: .default, reuseIdentifier: "TestTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}
