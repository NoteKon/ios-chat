//
//  FoldDefine.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/10/26.
//
//  展开/折叠相关定义

// MARK:- 展开/折叠 row协议
public protocol SWFoldRowType: SWBaseRow {
    var isOpen: Bool { get set }
}

// MARK:- 展开/折叠 内容基类
open class SWFoldContentView: UIView {
    /// 更新高度
    func updateHeight(_ height: CGFloat) {
        self.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
    }
    
    /// 根据给定的宽度计算并返回展开的最大高度
    open func height(with width: CGFloat) -> CGFloat { return self.frame.height }
    
    /// 根据给定的高度计算并返回展开的最大宽度（横向排列时）
    open func width(with height: CGFloat) -> CGFloat { return self.frame.height }
}

// MARK:- 展开/收起 控件相关
/// 位置
public enum SWFoldOpenPosition {
    /// 在折叠内容下
    case bottom
    /// 覆盖（通常表示在盖住底部多余的内容）
    case cover
}
public protocol SWFoldOpenViewType {
    /// 是否已经打开
    var isOpen: Bool { get set }
    
    /// 返回高度（可根据是否打开动态返回）
    func height() -> CGFloat
}

/// 展开/收起 按钮样式基类，仅作为样式展示，已禁用交互
open class SWBaseFoldOpenView: UIView, SWFoldOpenViewType {
    
    open var isOpen: Bool = false
    
    open func height() -> CGFloat {
        /// 如果要展开后就隐藏按钮 则像下面这样返回高度
//        return isOpen ? 0 : 20
        /// 不隐藏
        return 20
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        isUserInteractionEnabled = false
    }
}

// MARK:- 默认的展开按钮
/// 默认展开按钮设置
public struct SWFoldDefaultOpenButtonSetting {
    public var text: String = "展开"
    public var openedText: String = "收起"
    public var font: UIFont = UIFont.systemFont(ofSize: 13)
    public var color: UIColor = .blue
    public var textAlignment: NSTextAlignment = .left
}
public class FoldDefaultOpenButton: SWBaseFoldOpenView {
    // SWFoldOpenViewType 协议实现
    public override var isOpen: Bool {
        didSet {
            updateText()
        }
    }
    
    /// 更新展示数据
    func updateText() {
        textLabel.text = isOpen ? textForOpened : text
        textLabel.textColor = textColor
        textLabel.font = font
    }
    
    /// 文字展示label
    let textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()
    /// 文字样式
    var text: String? = "展开" {
        didSet {
            updateText()
        }
    }
    var textForOpened: String? = "收起" {
        didSet {
            updateText()
        }
    }
    var textColor: UIColor = .blue {
        didSet {
            updateText()
        }
    }
    var font: UIFont = .systemFont(ofSize: 13){
        didSet {
            updateText()
        }
    }
    
    
    // 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpText()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpText()
    }
    
    func setUpText() {
        clipsToBounds = true
        addSubview(textLabel)
        updateText()
        
        textLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

// MARK:- SWFoldTextView
open class SWFoldTextView: SWFoldContentView {
    /// 文本内容
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    open override func height(with width: CGFloat) -> CGFloat {
        return titleLabel.sizeThatFits(CGSize(width: width, height: CGFloat(MAXFLOAT))).height
    }
    
    open override func width(with height: CGFloat) -> CGFloat {
        /// 暂时按高度返回
        return titleLabel.sizeThatFits(CGSize(width: height, height: CGFloat(MAXFLOAT))).height
    }
}
