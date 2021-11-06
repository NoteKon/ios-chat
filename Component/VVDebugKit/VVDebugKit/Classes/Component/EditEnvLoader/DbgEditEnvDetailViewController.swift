//
//  DbgEditEnvDetailViewController.swift
//  VVDebugKit
//
//  Created by dailiangjin on 2020/4/10.
//

import UIKit
import SWFoundationKit
import SWBusinessKit
import RxSwift
import RxCocoa

class DbgEditEnvCellModel {
    var key: EnvironmentManager.Keys?
    var text: BehaviorRelay<String>?
}

class DbgEditEnvDetailViewController: DbgBaseViewController {
    private var tableView: UITableView!
    private let disposeBag = DisposeBag()
    
    var model: DbgEditEnvModel?
    
    private var models: [DbgEditEnvCellModel]? {
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
        self.title = "\(model?.env.description ?? "unknown")"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
                
        tableView = UITableView(frame: .zero, style: .grouped)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tableView.register(DbgEditEnvCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func loadData() {
        var cellModels: [DbgEditEnvCellModel] = []
        for key in EnvironmentManager.Keys.allCases {
            let cellModel = DbgEditEnvCellModel()
            cellModel.key = key
            let text = EnvironmentManager.default.get(key, env: model?.env)
            cellModel.text = BehaviorRelay(value: text)
            cellModels.append(cellModel)
        }
        models = cellModels
        
        if let rightItem = self.navigationItem.rightBarButtonItem {
            let observables = cellModels.map { (model) in
                return model.text!.asObservable()
            }
            let enable = Observable.combineLatest(observables) { (values) in
                return values.first { $0.isEmpty } == nil
            }
            enable.bind(to: rightItem.rx.isEnabled).disposed(by: disposeBag)
        }
    }
    
    @objc private func doneAction() {
        defer {
            self.navigationController?.popViewController(animated: true)
        }
        
        guard let models = models, let env = model?.env else { return }
        for model in models {
            let value = model.text?.value
            let key = model.key
            EnvironmentManager.default.set(value, for: key, env: env)
        }
    }
}

extension DbgEditEnvDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return models?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DbgEditEnvCell
        
        let model = models?[indexPath.section]
        cell.model = model
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return models?[section].key?.description
    }
}

class DbgEditEnvCell: UITableViewCell {
    var disposeBag = DisposeBag()
    var textField: UITextField!
    
    var model: DbgEditEnvCellModel? {
        didSet {
            updateWithModel()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        textField = UITextField()
        textField.clearButtonMode = .whileEditing
        contentView.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    private func updateWithModel() {
        textField.text = model?.text?.value
        if let text = model?.text {
            textField.rx.text.orEmpty.bind(to: text).disposed(by: disposeBag)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
