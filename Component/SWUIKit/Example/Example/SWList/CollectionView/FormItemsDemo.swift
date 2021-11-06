//
//  FormItemsDemo.swift
//  GZCList_Example
//
//  Created by Guo ZhongCheng on 2020/9/23.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SWUIKit

class FormItemsDemo: SWFormCollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrangement = .blend

        form +++ SWCollectionSection("自动换行") { section in
            section.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            section.lineSpace = 10
            section.itemSpace = 10
            section.lineHeight = 30
            section.arrangement = .aline
        }
            <<< DemoXibItemRow("xib创建")
            <<< ButtonItem("点击跳转(show)") {[weak self] row in
                row.value = "传值1"
                /// 设置圆角为高度的一半
                row.cornerScale = 0.5
                /// 设置边框宽度
                row.borderWidth = 1
                /// 设置正常颜色
                row.titleColor = .black
                row.contentBgColor = UIColor(white: 0.9, alpha: 1.0)
                row.borderColor = UIColor(white: 0.5, alpha: 1.0)
                /// 设置高亮颜色
                row.titleHighlightColor = .white
                row.highlightContentBgColor = UIColor(red: 59/255.0, green: 138/255.0, blue: 250/255.0, alpha: 1)
                row.highlightBorderColor = UIColor(red: 59/255.0, green: 138/255.0, blue: 250/255.0, alpha: 1)
                /// 自动选择push和present
                row.presentationMode = .show(controllerProvider: .callback(builder: { [weak row] () -> UIViewController in
                    let vc = ItemPresentViewController<ButtonItem>()
                    vc.modalPresentationStyle = .fullScreen
                    vc.row = row
                    return vc
                }), onDismiss: { (vc) in
                    if vc.navigationController != nil {
                        vc.navigationController?.popViewController(animated: true)
                    } else {
                        vc.dismiss(animated: true)
                    }
                })
                if self?.scrollDirection == .horizontal {
                    row.contentInsets = UIEdgeInsets(top: 10, left: 7, bottom: 10, right: 5)
                }
            }
            <<< ButtonItem("点击跳转(present)") {[weak self] row in
                row.value = "传值2"
                /// 指定present
                row.presentationMode = .presentModally(controllerProvider: .callback(builder: { [weak row] () -> UIViewController in
                    let vc = ItemPresentViewController<ButtonItem>()
                    vc.row = row
                    return vc
                }), onDismiss: { (vc) in
                    vc.dismiss(animated: true)
                })
                if self?.scrollDirection == .horizontal {
                    row.contentInsets = UIEdgeInsets(top: 10, left: 7, bottom: 10, right: 5)
                }
            }
            <<< ButtonItem("点击跳转(popover)") {[weak self] row in
                row.value = "传值3"
                /// 指定popover
                row.presentationMode = .popover(controllerProvider: .callback(builder: { [weak row] () -> UIViewController in
                    let vc = ItemPresentViewController<ButtonItem>()
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
                if self?.scrollDirection == .horizontal {
                    row.contentInsets = UIEdgeInsets(top: 10, left: 7, bottom: 10, right: 5)
                }
            }
            <<< newLabelItem("标签")
            <<< newLabelItem("标签标签")
            <<< newLabelItem("标签")
            <<< newLabelItem("标签标签标签")
        
        +++ SWCollectionSection("LineItem(分割线)") { section in
            section.lineSpace = 0
            section.column = 1
        }
            <<< LineItem() { row in
                row.contentInsets = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15)
                row.lineWidth = 30
                row.lineRadius = 15
            }
            <<< LineItem() { row in
                row.contentInsets = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 0)
                row.lineWidth = 3
                row.lineRadius = 1.5
            }
            <<< LineItem() { row in
                row.contentInsets = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15)
                row.lineColor = .red
            }
            <<< LineItem() { row in
                row.contentInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
            }
        
        if scrollDirection == .vertical {
            /// 不推荐在水平排列中使用
            form +++ SWCollectionSection("固定一列") { section in
                section.lineSpace = 0
                section.column = 1
            }
            +++ SWCollectionSection("ButtonItem") { section in
                section.lineSpace = 0
                section.column = 1
            }
                <<< ButtonItem("固定宽高比") { row in
                    row.arrowType = .custom(UIImage(named: "arrow")!, size: CGSize(width: 10, height: 10))
                    row.iconImage = UIImage(named: "icon")
                    row.iconSize = CGSize(width: 20, height: 20)
                    row.spaceBetweenIconAndTitle = 5
                    row.spaceBetweenRightViewAndArrow = 5
                    row.spaceBetweenTitleAndRightView = 15
                    row.titleColor = .red
                    row.titleFont = UIFont.systemFont(ofSize: 15)
                    row.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
                    if scrollDirection == .vertical {
                        row.aspectRatio = CGSize(width: 375, height: 44)
                    } else {
                        row.aspectRatio = CGSize(width: 1, height: 5)
                    }
                }
                <<< ButtonItem("在标题和箭头间添加自定义的view") { row in
                    row.arrowType = .custom(UIImage(named: "arrow")!, size: CGSize(width: 10, height: 10))
                    row.iconImage = UIImage(named: "icon")
                    row.iconSize = CGSize(width: 20, height: 20)
                    row.spaceBetweenIconAndTitle = 5
                    row.spaceBetweenRightViewAndArrow = 5
                    row.spaceBetweenTitleAndRightView = 15
                    row.titleColor = .red
                    row.titleFont = UIFont.systemFont(ofSize: 15)
                    row.rightView = UIImageView(image: UIImage(named: "user_photo"))
                    row.rightViewSize = CGSize(width: 30, height: 30)
                    row.highlightContentBgColor = UIColor(red: 59/255.0, green: 138/255.0, blue: 250/255.0, alpha: 1)
                }
            
            +++ SWCollectionSection("LabelItem") { section in
                section.lineSpace = 0
                section.column = 1
            }
                <<< LabelItem("title加上value"){ row in
                    row.verticalAlignment = .top
                    row.spaceBetweenTitleAndValue = 8
                    row.valueAlignment = .left
                    row.value = "这是value这是value这是value这是value这是value这是value这是value这是value这是value这是value这是value这是value这是value这是value这是value"
                    if scrollDirection == .horizontal {
                        row.aspectRatio = CGSize(width: 0.5, height: 1)
                    }
                }
                <<< LabelItem("标题样式") { row in
                    row.verticalAlignment = .top

                    row.titlePosition = .left
                    row.titleFont = UIFont.boldSystemFont(ofSize: 15)
                    row.titleColor = .darkText
                    row.titleAlignment = .center

                    row.valueColor = .blue
                    row.valueAlignment = .left
                    row.value = "value样式,然后这是一串比较长的字符串，我们看看能不能换行\n加个回车试试看"
                }
            <<< LabelItem("只有一串比较长的标题，试试看能不能正常的显示到充满，然后看看能不能自动换行, 四周的边距已设置为0") { row in
                row.verticalAlignment = .top
                row.contentInsets = .zero
                /// 也可单独设置
//                row.contentInsets.left = 0
//                row.contentInsets.right = 0
//                row.contentInsets.top = 0
//                row.contentInsets.bottom = 0
            }
            <<< LabelItem("这也是一串比较长的标题，把上下间距设为零，设置固定宽度",tag: "DEFAULT_LABEL") { row in
                row.value = "标题与value都很长的时候，标题会挤压value的空间，因此需要给标题设置最大宽度，达到比较好的展示效果"
                row.titlePosition = .width(120)
            }
        
        +++ SWCollectionSection("SwitchItem") { section in
            section.lineSpace = 0
            section.column = 1
        }
            <<< SwitchItem("设为默认") { row in
                row.value = true
            }.onChange({ (row) in
                /// 值改变的回调
                guard let labelItem = row.form?.rowBy(tag: "DEFAULT_LABEL") as? LabelItem else {
                    return
                }
                if row.value ?? false {
                    labelItem.titlePosition = .width(200)
                    labelItem.value = "已设为默认"
                } else {
                    labelItem.titlePosition = .left
                    labelItem.title = "value清空了，可以改成自动宽度，整行都能显示title的值"
                    labelItem.value = ""
                }
                labelItem.updateCell()
            })
                <<< SwitchItem("自定义样式") { row in
                    row.switchTintColor = .red
                    row.switchOnTintColor = .blue
                    row.switchSliderColor = .yellow
                    row.switchSliderText = "关"
                    row.switchOnSliderText = "开"
                    row.switchSliderTextColor = .darkGray
                    row.aspectHeight = 60
                }
            
            let foldSection = SWCollectionSection("FoldItem(可折叠的内容)") { section in
                section.lineSpace = 0
                section.column = 1
            }
            for _ in 0 ..< 10 {
                foldSection <<< getDemoFoldItem()
            }
            
            form +++ foldSection
            
            form +++ SWCollectionSection("FoldTextItem(可折叠的文字)") { section in
                section.lineSpace = 0
                section.column = 1
            }
                <<< FoldTextItem("FoldTextRow是可折叠的文字展示Row，当长度超过指定的foldHeight时，会自动显示展开按钮，展开后可以收起，然后下面是回车\n看下是不是可以") { row in
                    row.foldHeight = 20
                }
                <<< FoldTextItem() { row in
                    row.foldHeight = 20
                    let attr = NSMutableAttributedString(string: "这行来测试一下富文本内容的展示，这是红色的字,\n这行来测试一下富文本内容的展示\n这行来测试一下富文本内容的展示")
                    attr.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: 16, length: 6))
                    row.attributeText = attr
                }
            
            form +++ SWCollectionSection("TextFieldItem(输入框)") { section in
                section.lineSpace = 0
                section.column = 1
            }
                <<< TextFieldItem("输入框:") { row in
                    row.placeHolder = "提示信息"
                    row.placeHolderColor = .red
                    row.aspectRatio = CGSize(width: 375, height: 50)
                }
                <<< TextFieldItem("带边框的输入框:") { row in
                    row.boxInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
                    row.inputAlignment = .left
                    row.placeHolder = "提示信息"
                    row.boxBorderWidth = 1.0
                    row.boxBorderColor = .green
                    row.boxHighlightBorderColor = .blue
                    row.boxBackgroundColor = .white
                    row.boxCornerRadius = 5
                    row.aspectRatio = CGSize(width: 375, height: 50)
                }
                <<< TextFieldItem("正则限制输入:") { row in
                    row.placeHolder = "限制输入两位小数"
                    row.inputPredicateFormat = PredicateFormat.decimal2.rawValue
                }
                <<< TextFieldItem("回调限制输入:") { row in
                    row.placeHolder = "只能输入a(删除都不行)"
                    row.onTextShouldChange({ (row, textField, range, string) -> Bool in
                        return string == "a"
                    })
                }
                <<< TextFieldItem("限制输入长度") { row in
                    row.placeHolder = "最多能输入10个字"
                    row.limitWords = 10
                }
                <<< TextFieldItem("textField的各种回调") { row in
                    row.onTextDidChanged { (r, textField) in
                        print("输入值改变:\(textField.text ?? "")")
                    }
                    row.onTextFieldShouldReturn { (r, t) -> Bool in
                        /// 是否可以return
                        r.cell?.endEditing(true)
                        return true
                    }
                    row.onTextFieldShouldClearBlock { (r, t) -> Bool in
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
            +++ SWCollectionSection("TextViewItem(多行输入框)") { section in
                section.lineSpace = 0
                section.column = 1
            }
            <<< TextViewItem("多行文本输入:\n(自动高度)") { row in
                row.placeholder = "最多100个"
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
            }
            <<< TextViewItem("多行文本输入:\n(固定高度)") { row in
                row.placeholder = "不限制输入个数"
                row.showLimit = false
                row.inputBorderColor = .gray
                row.inputBorderWidth = 2
                row.inputCornerRadius = 3
                row.inputContentPadding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                row.minHeight = 100
                row.autoHeight = false
            }
            <<< TextViewItem() { row in
                row.placeholder = "不带标题的输入框，不限制输入字数"
                row.showLimit = false
                row.inputBorderColor = .gray
                row.inputBorderWidth = 2
                row.inputCornerRadius = 3
                row.inputContentPadding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                row.minHeight = 50
            }
            
            +++ SWCollectionSection("HtmlInfoItem") { section in
                section.lineSpace = 0
                section.column = 1
            }
                <<< HtmlInfoItem() { row in
                    row.value = "HtmlInfoItem是用于展示Html代码字符串的Item，设置value为Html代码，即可展示\n展示出来后会自动调整高度，设置estimatedSize表示预估的size，会根据size的比例预先设置大小\n设置contentInsets可调整内容的四边间距"
                    row.contentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                    /// 设置预估高度可以减少跳动
                    row.estimatedSize = CGSize(width: 100, height: 30)
                }
                <<< getHtmlImageItem(0,isFirst: true)
                <<< getHtmlImageItem(1)
                <<< getHtmlImageItem(2)
                <<< getHtmlImageItem(3)
                <<< getHtmlImageItem(4,isLast: true)
        }
        
        form +++ SWCollectionSection("ImageItem") { section in
            section.lineSpace = 0
            section.column = 1
        }
        let towColumSection = SWCollectionSection("固定大小两列图片") { section in
            section.column = 2
            section.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            section.lineSpace = 10
            section.itemSpace = 10
        }
        for i in 0 ... 30 {
            towColumSection <<< newImageItem(ImageUrlsHelper.getNumberImage(i))
        }
        for _ in 0...30 {
            towColumSection <<< newImageItem(ImageUrlsHelper.getRandomGif())
        }
        form +++ towColumSection

        let threeColumSection = SWCollectionSection("自动大小三列图片") { section in
            section.column = 3
            section.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            section.lineSpace = 5
            section.itemSpace = 5
        }
        for _ in 0 ... 30 {
            threeColumSection <<< newImageItem(ImageUrlsHelper.getRandomImage(), true)
        }
        form +++ threeColumSection
        
    }
    
    func newLabelItem(_ title: String) -> LabelItem {
        return LabelItem(title) {[weak self] row in
//            row.value = "x"
//            row.valueColor = .red
//            row.spaceBetweenTitleAndValue = 15
            row.cornerScale = 0.5
            /// 设置正常颜色
            row.contentBgColor = UIColor(white: 0.9, alpha: 1.0)
            row.borderColor = UIColor(white: 0.5, alpha: 1.0)
            /// 设置高亮颜色
            row.highlightContentBgColor = UIColor(red: 59/255.0, green: 138/255.0, blue: 250/255.0, alpha: 1)
            row.highlightBorderColor = UIColor(red: 59/255.0, green: 138/255.0, blue: 250/255.0, alpha: 1)
            row.titleHighlightColor = .white
            if self?.scrollDirection == .horizontal {
                row.contentInsets = UIEdgeInsets(top: 10, left: 7, bottom: 10, right: 5)
            }
        }
    }
    
    func newImageItem(_ url: String,_ autoSize: Bool = false) -> ImageItem {
        return ImageItem() { row in
            row.imageUrl = url
            row.corners = [.leftTop(10),.rightBottom(15)] // CornerType.all(5)
            row.autoSize = autoSize
            row.aspectRatio = CGSize(width: 1, height: 1)
            row.loadFaildImage = UIImage(named: "load_faild")
        }
    }
    
    /// 获取html图片Row
    func getHtmlImageItem(_ index: Int, isFirst: Bool = false, isLast: Bool = false) -> HtmlInfoItem {
        return HtmlInfoItem() { row in
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
    
    /// 随机图片数量的折叠row
    func getDemoFoldItem() -> FoldItem {
        let count:Int = Int(arc4random() % 9)
        var imgUrls = [String]()
        for i in 0 ..< count {
            imgUrls.append(ImageUrlsHelper.getNumberImage(i))
        }
        return FoldItem() { row in
            let foldContent = DemoFoldView()
            foldContent.text = "FoldItem是可折叠的展示Item，当长度超过指定的foldHeight时，会自动显示展开按钮，展开后可以收起，这个item是一个FoldItem，指定了foldContentView，展示文字+图片, 也可以自己继承相关的cell和item，优化性能"
            foldContent.images = imgUrls
            row.foldContentView = foldContent
            row.foldHeight = 120
            row.foldOpenView = DemoFoldButton()
            row.openViewPosition = .cover
            if count > 5 {
                let imageView = UIImageView()
                imageView.layer.cornerRadius = 15
                row.leftViewSize = CGSize(width: 30, height: 30)
                imageView.kf.setImage(with: URL(string: imgUrls.last!))
                row.leftView = imageView
            }
        }
    }
}

extension FormItemsDemo: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
