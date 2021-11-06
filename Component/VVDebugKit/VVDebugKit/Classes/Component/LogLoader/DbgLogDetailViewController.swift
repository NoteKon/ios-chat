//
//  DbgLogDetailViewController.swift
//  VVDebugKit
//
//  Created by dailiangjin on 2019/11/28.
//

import UIKit
import SnapKit
import SWFoundationKit

class DbgLogDetailViewController: DbgBaseViewController {
    var model: String?
    var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
        loadData()
    }

    private func initUI() {
        self.view.backgroundColor = .white
        
        if let model = model {
            self.title = (model as NSString).lastPathComponent
        } else {
            self.title = "Detail"
        }
        
        textView = UITextView(frame: .zero)
        self.view.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        textView.isEditable = false
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAction))
    }
    
    private func loadData() {
        if let model = model {
            let text = try? String(contentsOfFile: model)
            textView.text = text
        }
    }
    
    @objc private func shareAction() {
        let fileURLs = SWLogger.loggerFilePaths().map { (path) -> URL in
            return URL(fileURLWithPath: path)
        }
        
        let vc = UIActivityViewController(activityItems: fileURLs, applicationActivities: nil)
        self.present(vc, animated: true, completion: nil)
    }
}
