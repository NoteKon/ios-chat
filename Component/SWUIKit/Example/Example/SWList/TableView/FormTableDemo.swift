//
//  FormTableDemo.swift
//  GZCList_Example
//
//  Created by Guo ZhongCheng on 2020/9/7.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SWUIKit

class DemoHeaderView: UIView {
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    let titleLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class FormTableDemo: SWFormTableViewController {
    
    var isHide: Bool = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        
        form +++ DemoXibRow("测试一下")
        
        /// 系统样式Header、Footer
        addSystemSection()
        
        /// 自定义样式Header、Footer
        addCustomSection()

        /// 可编辑的Section
        addMultivalusedSection()
        

        form +++ SWTableSection("显示隐藏")
            <<< LabelRow(title: "点击隐藏下面一行").onCellSelection({[weak self] (cell, row) in
                guard let hideRow = self?.form.rowBy(tag: "HIDDENROW") else {
                    return
                }
                hideRow.isHidden = !hideRow.isHidden
                row.title = hideRow.isHidden ? "点击显示下面一行" : "点击隐藏下面一行"
                row.updateCell()
            })
            <<< LabelRow("这一行", tag: "HIDDENROW")

        form +++ SWTableSection("InlineRow")
            <<< InlineRootRow(title: "点我打开")
            .onExpandInlineRow({ (cell, rootRow, openRow) in
                print("打开了")
            })
            .onCollapseInlineRow({ (cell, rootRow, openRow) in
                print("收起了")
            })

        form +++ SWTableSection("已有Row样式举例")
        +++ SWTableSection("SwitchRow")
            <<< SwitchRow(title: "设为默认", value: true).onChange({ (row) in
                guard let labelRow = row.form?.rowBy(tag: "DEFAULT_LABEL") as? LabelRow else {
                    return
                }
                if row.value ?? false {
                    labelRow.titlePosition = .width(200)
                    labelRow.value = "已设为默认"
                } else {
                    labelRow.titlePosition = .left
                    labelRow.title = "value清空了，可以改成自动宽度，整行都能显示title的值"
                    labelRow.value = ""
                }
                labelRow.updateCell()
            })
            <<< SwitchRow("自定义样式") { row in
                row.switchTintColor = .red
                row.switchOnTintColor = .blue
                row.switchSliderColor = .yellow
                row.switchSliderText = "关"
                row.switchOnSliderText = "开"
                row.switchSliderTextColor = .darkGray
                row.cellHeight = 60
            }
        +++ SWTableSection("LabelRow")
            <<< LabelRow("标题样式") { row in
                row.verticalAlignment = .top

                row.titlePosition = .left
                row.titleFont = UIFont.boldSystemFont(ofSize: 15)
                row.titleColor = .darkText
                row.titleAlignment = .center

                row.valueColor = .blue
                row.valueAlignment = .left
                row.value = "value样式,然后这是一串比较长的字符串，我们看看能不能换行\n加个回车试试看"
            }
            <<< LabelRow("只有一串比较长的标题，试试看能不能正常的显示到充满，然后看看能不能自动换行, 四周的边距已设置为0") { row in
                row.verticalAlignment = .top
                row.contentInsets = .zero
                /// 也可单独设置
//                row.contentInsets.left = 0
//                row.contentInsets.right = 0
//                row.contentInsets.top = 0
//                row.contentInsets.bottom = 0
            }
            <<< LabelRow("这也是一串比较长的标题，把上下间距设为零，设置固定宽度",tag: "DEFAULT_LABEL") { row in
                row.value = "标题与value都很长的时候，标题会挤压value的空间，因此需要给标题设置最大宽度，达到比较好的展示效果"
                row.titlePosition = .width(120)
            }
        
        form +++ SWTableSection("ButtomRow")
            <<< ButtonRow("点击跳转(show)") { row in
                row.value = "传值1"
                /// 自动选择push和present
                row.presentationMode = .show(controllerProvider: .callback(builder: { [weak row] () -> UIViewController in
                    let vc = PresentViewController<ButtonRow>()
                    vc.modalPresentationStyle = .fullScreen
                    vc.row = row
                    return vc
                }), onDismiss: { (vc) in
                    vc.dismiss(animated: true)
                })
            }
            <<< ButtonRow("点击跳转(present)") { row in
                row.value = "传值2"
                /// 指定present
                row.presentationMode = .presentModally(controllerProvider: .callback(builder: { [weak row] () -> UIViewController in
                    let vc = PresentViewController<ButtonRow>()
                    vc.row = row
                    return vc
                }), onDismiss: { (vc) in
                    vc.dismiss(animated: true)
                })
            }
            <<< ButtonRow("点击跳转(popover)") { [weak self] row in
                row.value = "传值3"
                /// 指定popover
                row.presentationMode = .popover(controllerProvider: .callback(builder: { [weak row] () -> UIViewController in
                    let vc = PresentViewController<ButtonRow>()
                    vc.preferredContentSize = CGSize(width: 150, height: 150)
                    vc.modalPresentationStyle = .popover
                    // 必须实现delegate中的adaptivePresentationStyle方法***这里的self一定要用weak修饰，否则会造成循环引用***
                    if let weakSelf = self {
                        vc.popoverPresentationController?.delegate = weakSelf
                    }
                    vc.popoverPresentationController?.sourceView = row?.cell
                    vc.popoverPresentationController?.permittedArrowDirections = .any
                    vc.popoverPresentationController?.backgroundColor = .green
                    vc.row = row
                    return vc
                }), onDismiss: { (vc) in
                    vc.dismiss(animated: true)
                })
            }
            <<< ButtonRow("自定义前面图标和右侧箭头") { row in
                row.arrowType = .custom(UIImage(named: "arrow")!, size: CGSize(width: 10, height: 10))
                row.iconImage = UIImage(named: "icon")
                row.iconSize = CGSize(width: 20, height: 20)
                row.spaceBetweenIconAndTitle = 5
                row.colorOfTitle = .red
                row.fontOfTitle = UIFont.systemFont(ofSize: 15)
            }.onCellSelection({ (cell, row) in
                print("点击了 自定义前面图标和右侧箭头")
            })
            <<< ButtonRow("在标题和箭头间添加自定义的view") { row in
                row.iconImage = UIImage(named: "icon")
                row.iconSize = CGSize(width: 20, height: 20)
                row.spaceBetweenIconAndTitle = 5
                row.colorOfTitle = .red
                row.fontOfTitle = UIFont.systemFont(ofSize: 15)
                row.rightView = UIImageView(image: UIImage(named: "user_photo"))
                row.rightViewSize = CGSize(width: 30, height: 30)
                row.cellHeight = 50
            }.onCellSelection({ (cell, row) in
                print("点击了 在标题和箭头间添加自定义的view")
            })
        
        let foldSection = SWTableSection("FoldRow(可折叠的Row)")
        for _ in 0 ..< 10 {
            foldSection <<< getDemoFoldRow()
        }
        form +++ foldSection
        
        form +++ SWTableSection("FoldTextRow(可折叠的文字)")
            <<< FoldTextRow("FoldTextRow是可折叠的文字展示Row，当长度超过指定的foldHeight时，会自动显示展开按钮，展开后可以收起，然后下面是回车\n看下是不是可以") { row in
                row.foldHeight = 20
            }
            <<< FoldTextRow() { row in
                row.foldHeight = 20
                let attr = NSMutableAttributedString(string: "这行来测试一下富文本内容的展示，这是红色的字,\n以及左侧自定义View的使用\n这行来测试一下富文本内容的展示,\n以及左侧自定义View的使用")
                attr.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: 16, length: 6))
                row.attributeText = attr
                
                let photoImage = UIImageView()
                photoImage.layer.cornerRadius = 15
                photoImage.clipsToBounds = true
                photoImage.kf.setImage(with: URL(string: ImageUrlsHelper.getRandomImage()))
                row.leftView = photoImage
                row.leftViewSize = CGSize(width: 30, height: 30)
            }
            <<< FoldTextRow("这行来测试一下自定义的展开收起Row\n这行来测试一下自定义的展开收起Row\n这行来测试一下自定义的展开收起Row\n这行来测试一下自定义的展开收起Row\n这行来测试一下自定义的展开收起Row\n这行来测试一下自定义的展开收起Row\n这行来测试一下自定义的展开收起Row\n这行来测试一下自定义的展开收起Row") { row in
                row.foldHeight = 40
                row.foldOpenView = DemoFoldButton()
                row.openViewPosition = .cover
            }
            <<< FoldTextRow("这行来测试一下自定义的展开不能收起\n这行来测试一下自定义的展开不能收起\n这行来测试一下自定义的展开不能收起\n这行来测试一下自定义的展开不能收起\n这行来测试一下自定义的展开不能收起\n这行来测试一下自定义的展开不能收起\n这行来测试一下自定义的展开不能收起\n这行来测试一下自定义的展开不能收起") { row in
                row.foldHeight = 40
                let foldView = DemoFoldButton()
                foldView.showCloseWhenOpend = false
                row.foldOpenView = DemoFoldButton()
                row.openViewPosition = .cover
            }
        
        // 头尾加圆角
        let imagesSection = SWTableSection("ImageRow(图片展示)")
            <<< ImageRow() { row in
                row.imageUrl = ImageUrlsHelper.getRandomImage()
                row.corners = [.leftTop(10),.rightTop(30)]
                row.contentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
                row.estimatedSize = CGSize(width: 30, height: 40)
            }
        for _ in 0...3 {
            imagesSection <<< ImageRow() { row in
                row.imageUrl = ImageUrlsHelper.getRandomImage()
                row.contentInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
                row.estimatedSize = CGSize(width: 30, height: 40)
            }
        }
        imagesSection <<< ImageRow() { row in
            row.imageUrl = ImageUrlsHelper.getRandomImage()
            row.corners = [.leftBottom(10),.rightBottom(10)]
            row.contentInsets = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
            row.estimatedSize = CGSize(width: 30, height: 40)
        }
        form +++ imagesSection
            

        form +++ SWTableSection("LineRow")
            <<< LabelRow("LineRow是定义好的分割线Row，可自定义分割线宽度(lineWidth)、圆角、内容边距、线的颜色，默认高度为0.5，可以作为普通的分割线，如：")
            <<< LineRow() { row in
                row.contentInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
                row.lineWidth = 30
                row.lineRadius = 15
            }
            <<< LabelRow("也可以将lineColor和backgroundColor设置为透明达到分块的效果，如：")
            <<< LineRow() { row in
                row.lineColor = .clear
                row.backgroundColor = .clear
                row.lineWidth = 15
            }
            <<< LabelRow("这个Row的使用比较简单")

        form +++ SWTableSection("TextFieldRow")
            <<< TextFieldRow("输入框:") { row in
                row.placeHolder = "提示信息"
                row.placeHolderColor = .red
                row.cellHeight = 50
            }
            <<< TextFieldRow("带边框的输入框:") { row in
                row.boxInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
                row.inputAlignment = .left
                row.placeHolder = "提示信息"
                row.boxBorderWidth = 1.0
                row.boxBorderColor = .green
                row.boxHighlightBorderColor = .blue
                row.boxBackgroundColor = .white
                row.boxCornerRadius = 5
                row.cellHeight = 50
            }
            <<< TextFieldRow("正则限制输入:") { row in
                row.placeHolder = "限制输入两位小数"
                row.inputPredicateFormat = PredicateFormat.decimal2.rawValue
            }
            <<< TextFieldRow("回调限制输入:") { row in
                row.placeHolder = "只能输入a(删除都不行)"
                row.onTextShouldChange({ (row, textField, range, string) -> Bool in
                    return string == "a"
                })
            }
            <<< TextFieldRow("限制输入长度") { row in
                row.placeHolder = "最多能输入10个字"
                row.limitWords = 10
            }
            <<< TextFieldRow("textField的各种回调") { row in
                row.onTextDidChanged { (r, textField) in
                    print("输入值改变:\(textField.text ?? "")")
                }
                row.onTextFieldShouldReturn { (r, t) -> Bool in
                    /// 是否可以return
                    r.cell?.endEditing(true)
                    return true
                }
                row.onTextFieldShouldClear { (r, t) -> Bool in
                    /// 是否可以清空
                    return true
                }
                row.onTextFieldDidEndEditing { (r, t) in
                    print("编辑完成")
                }
                row.onTextFieldDidBeginEditing { (r, t) in
                    print("开始编辑")
                }
            }

        form +++ SWTableSection("TextViewRow")
            <<< TextViewRow("多行文本输入:\n(自动高度)") { row in
                row.placeholder = "最多100个最多100个最多100个最多100个最多100个"
                row.showLimit = true
                row.limitWords = 100
                row.inputBorderColor = .red
                row.inputBorderWidth = 1
                row.inputCornerRadius = 3
                row.boxBorderColor = .blue
                row.boxBorderWidth = 1
                row.boxCornerRadius = 5
                row.boxEditingBorderColor = .green
                row.boxPadding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                row.inputContentPadding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                row.minHeight = 100
                row.inputCursorColor = .orange
//                row.isDisabled = true
            }
            <<< TextViewRow("多行文本输入:\n(固定高度)") { row in
                row.placeholder = "不限制输入个数"
                row.showLimit = false
                row.inputBorderColor = .gray
                row.inputBorderWidth = 2
                row.inputCornerRadius = 3
                row.inputContentPadding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                row.minHeight = 100
                row.autoHeight = false
            }
            <<< TextViewRow() { row in
                row.placeholder = "不带标题的自动高度输入框，不限制输入字数"
                row.showLimit = false
                row.inputBorderColor = .gray
                row.inputBorderWidth = 2
                row.inputCornerRadius = 3
                row.inputContentPadding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                row.minHeight = 50
            }

        form +++ SWTableSection("HtmlInfoRow")
            <<< HtmlInfoRow() { row in
                row.value = "HtmlInfoRow是用于展示Html代码字符串的Row，设置value为Html代码，即可展示\n展示出来后会自动调整高度，设置estimatedSize表示预估的size，会根据size的比例预先设置大小\n设置contentInsets可调整内容的四边间距"
                row.contentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//                row.estimatedSize = CGSize(width: 100, height: 30)
            }
            <<< getHtmlImageRow(0,isFirst: true)
            <<< getHtmlImageRow(1)
            <<< getHtmlImageRow(2)
            <<< getHtmlImageRow(3)
            <<< getHtmlImageRow(4,isLast: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /// 获取网络数据后的数据 添加，使用 <<<!和+++!，
//        for j in 0...100 {
//            var section = TableSection(header: "\(j)开始", footer: "\(j)结束")
//            if j % 2 == 0 {
//                section = TableSection() { sec in
//                    // 自定义header
//                    let headerProvider = HeaderFooterProvider<DemoHeaderView>.callback { () -> DemoHeaderView in
//                        let view = DemoHeaderView()
//                        view.title = "\(j)开始"
//                        view.backgroundColor = .red
//                        return view
//                    }
//                    sec.header = TableHeaderFooterView(headerProvider)
//                    sec.header?.height = { 40 }
//                    // 自定义footer
//                    let footerProvider = HeaderFooterProvider<DemoHeaderView>.callback { () -> DemoHeaderView in
//                        let view = DemoHeaderView()
//                        view.title = "\(j)结束"
//                        view.backgroundColor = .blue
//                        return view
//                    }
//                    sec.footer = TableHeaderFooterView(footerProvider)
//                    sec.footer?.height = { 35 }
//                }
//            }
//            for i in 1 ... 4 {
//                section <<< LabelRow("\(i)") { row in
//                    row.cellHeight = CGFloat(arc4random() % 100 + 44)
//                }
//            }
//            form +++! section
//        }
        // 替换元素，使用 >>>
//        let section = TableSection() <<< LabelRow(title: "替换了") { row in
//            row.onCellSelection { (c, r) in
//                r.section as! TableSection >>> (0 ..< 1, [LabelRow(title: "又替换了1"),LabelRow(title: "替换了2"),LabelRow(title: "替换了3")])
//            }
//        }
//        form >>> (0 ..< 1,[section])
//        form >>> [section]
        
        // 移除所有元素，使用 --- ，如：
//        form---
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: 系统样式
    // 系统自带样式header、footer
    let systemSection: SWTableSection = SWTableSection(header: "系统样式", footer: "系统样式 结束")
    func addSystemSection() {
        systemSection <<< LabelRow("点我替换所有Row") { row in
            row.cellHeight = CGFloat(arc4random() % 100 + 44)
        }.onCellSelection { [weak self] (c, r) in
            /// 需要注意避免循环引用（这里不能直接引用systemSection）
            self?.replaceSystemSectionRows()
        }
        form +++ systemSection
    }
    
    /// 替换systemSection的所有row
    func replaceSystemSectionRows() {
        systemSection >>> (0 ..< 1, [LabelRow(title: "替换了").onCellSelection {[weak self] (c, r) in
            guard let section = self?.systemSection else {
                return
            }
            section >>> (0 ..< 1, [
                LabelRow(title: "又替换了1"),
                LabelRow(title: "替换了2"),
                LabelRow(title: "替换整个Section").onCellSelection {[weak self] (c, r) in
                    self?.replaceSystemSection()
                }
            ])
        }])
    }
    
    /// 替换systemSection
    func replaceSystemSection() {
        /// [weak self] 要从最外层写，否则还是会循环引用
        let section = SWTableSection()
            <<< LabelRow(title: "替换回刚才的Section").onCellSelection {[weak self] (c, r) in
                self?.replaceBackSystemSection()
            }
        form >>> (0 ..< 1,[section])
    }
    
    /// 替换回systemSection
    func replaceBackSystemSection() {
        form >>> (0 ..< 1,[systemSection])
    }
    
    // MARK: - 自定义样式Section
    func addCustomSection() {
        let customSection = SWTableSection() { sec in
            // 自定义header（view方式）
            var headerProvider = TableHeaderFooterView<DemoHeaderView>(.callback {
                let view = DemoHeaderView()
                view.title = "滑动操作"
                view.backgroundColor = .cyan
                return view
            })
            /// 指定header的高度（Provider方式）
            headerProvider.height = { 40 }
            sec.header = headerProvider

            // 自定义footer
            let footerProvider = HeaderFooterProvider<UIView>.callback {
                let view = UIView()
                view.backgroundColor = .lightGray
                return view
            }
            /// 指定footer的高度
            sec.footer = TableHeaderFooterView(footerProvider)
            sec.footer?.height = { 35 }
        }
        form +++ customSection
            <<< LabelRow("左滑事件（点击隐藏/显示上一个section）") { row in
                row.cellHeight = CGFloat(arc4random() % 100 + 44)
                // 添加左滑事件
                let delete = SWSwipeAction(style: .destructive, title: "删除") { (action, r, handler) in
                    handler?(true)
                }
                delete.image = UIImage(named: "delete")
                let other1 = SWSwipeAction(style: .normal, title: "点击1") { (action, r, handler) in
                    r.title = "点击了1"
                    r.updateCell()
                    handler?(true)
                }
                other1.actionBackgroundColor = .blue
                let other2 = SWSwipeAction(style: .normal, title: "点击2") { (action, r, handler) in
                    r.title = "点击了2"
                    r.updateCell()
                    handler?(true)
                }
                other2.actionBackgroundColor = .yellow
                row.trailingSwipe.actions = [delete,other1,other2]
            }.onCellSelection({[weak self] (cell, row) in
                guard let section = self?.systemSection else {
                    return
                }
                if self?.isHide == true {
                    self?.form.show(section)
                } else {
                    self?.form.hide(section)
                }
                self?.isHide = !(self?.isHide ?? false)
            })
            <<< LabelRow("右滑事件（点击删除上一个section）") { row in
                row.cellHeight = CGFloat(arc4random() % 100 + 44)
                if #available(iOS 11, *) {
                    // 添加右滑事件
                    let delete = SWSwipeAction(style: .destructive, title: "删除") { (action, r, handler) in
                        handler?(true)
                    }
                    delete.image = UIImage(named: "delete")
                    let other1 = SWSwipeAction(style: .normal, title: "点击1") { (action, r, handler) in
                        r.title = "点击了1"
                        r.updateCell()
                        handler?(true)
                    }
                    other1.actionBackgroundColor = .blue
                    let other2 = SWSwipeAction(style: .normal, title: "点击2") { (action, r, handler) in
                        r.title = "点击了2"
                        r.updateCell()
                        handler?(true)
                    }
                    other2.actionBackgroundColor = .yellow
                    row.leadingSwipe.actions = [delete,other1,other2]
                }
            }.onCellSelection({[weak self] (cell, row) in
                guard let section = self?.systemSection else {
                    return
                }
                self?.form.remove(section)
            })
    }
    
    // MARK: - 可编辑的section
    func addMultivalusedSection() {
        form +++ SWTableSection("可编辑Section")
            <<< LabelRow("开始编辑").onCellSelection {[weak self] (c, r) in
                guard let tb = self?.tableView else {
                    return
                }
                tb.isEditing = !tb.isEditing
                r.title = tb.isEditing ? "结束编辑" : "开始编辑"
                r.updateCell()
            }
        form +++ TableMultivalusedSection(multivaluedOptions: [.Reorder, .Insert, .Delete], header: "可移动的行", footer: "结束", { s in
            /// 添加一行
            s.addButtonProvider = {_ in
                return LabelRow(title: "添加一行")
            }
            s.multivaluedRowToInsertAt = { index in
                /// 生成新的一行，如果不设置左滑事件，会自动加上系统的左滑事件。
                return LabelRow("\(index)") { row in
                    // 添加左滑事件
                    let delete = SWSwipeAction(style: .destructive, title: "删除") { (action, r, handler) in
                        handler?(true)
                    }
                    delete.image = UIImage(named: "delete")
                    row.trailingSwipe.actions = [delete]
                    // 随机高度
                    row.cellHeight = CGFloat(arc4random() % 40 + 44)
                    row.canMoveRow = true
                    row.editingStyle = .delete
                }
            }
            s.moveFinishClosure = { (row, fromIndex, toIndex) in
                guard let r = row as? LabelRow else {
                    return
                }
                print("移动行 \(r.title!), 从\(fromIndex.row) 到\(toIndex.row)")
            }
            s
                <<< LabelRow("1") { row in
                    row.canMoveRow = true
                    row.editingStyle = .insert
                }
                <<< LabelRow("2") { row in
                    row.canMoveRow = true
                }
                <<< LabelRow("3") { row in
                    row.canMoveRow = true
                }
                <<< LabelRow("4") { row in
                    row.canMoveRow = true
                }
                <<< LabelRow("5") { row in
                    row.canMoveRow = true
                }
            /// 如果没有addButtonProvider，可以添加一个空的row，让最后一行也可以被上面的直接拖动
//                <<< EmptyRow(height: 1)
        })
    }
    
    // MARK: - 创建Row的快捷方法
    /// 随机图片数量的折叠row
    func getDemoFoldRow() -> DemoFoldRow {
        let count:Int = Int(arc4random() % 9)
        var imgUrls = [String]()
        for i in 0 ..< count {
            imgUrls.append(ImageUrlsHelper.getNumberImage(i))
        }
        return DemoFoldRow() { row in
            row.text = "FoldRow是可折叠的展示Row，当长度超过指定的foldHeight时，会自动显示展开按钮，展开后可以收起，这个row是一个自定义的DemoRow，支持文字+图片的折叠展示"
            row.images = imgUrls
            row.foldHeight = 120
            if count > 5 {
                row.userImageUrl = ImageUrlsHelper.getRandomImage()
            }
        }
    }
    
    /// 获取html图片Row
    func getHtmlImageRow(_ index: Int, isFirst: Bool = false, isLast: Bool = false) -> HtmlInfoRow {
        return HtmlInfoRow() { row in
            row.value = ImageUrlsHelper.htmlImages[index]
            row.estimatedSize = CGSize(width: 750, height: 730)
            row.contentInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            if isFirst {
                row.contentInsets.top = 10
            }
            if isLast {
                row.contentInsets.bottom = 10
            }
        }
    }
}

extension FormTableDemo: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
