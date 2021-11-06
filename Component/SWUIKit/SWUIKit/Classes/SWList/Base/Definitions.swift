//
//  Enums.swift
//  Definitions
//
//  Created by Guo ZhongCheng on 2020/6/2.
//

/// 模块导入
@_exported import UIKit
@_exported import SnapKit
@_exported import WebKit

// 常用的正则表达式
/// 可以用于shouldChange的正则表达式
public enum PredicateFormat: String {
    /// 纯数字
    case number = "^[0-9]*$"
    /// 1开头的手机号
    case phone = "^1\\d{0,10}$"
    /// 一位小数
    case decimal1 = "^[0-9]*\\.?\\d{0,1}$"
    /// 两位小数
    case decimal2 = "^[0-9]*\\.?\\d{0,2}$"
    /// 三位小数
    case decimal3 = "^[0-9]*\\.?\\d{0,3}$"
    /// 邮箱
    case email = "^\\w+([-+.]\\w+)*?@?\\w*([-.]\\w+)*?\\.?\\w*([-.]\\w+)*?$"
}

// row的左侧标题样式
public enum TitlePosition: Equatable {
    /// 居左，自动宽度
    case left
    /// 居左，固定宽度
    case width(_ width: CGFloat)
}

/**
 定义单选/多选的枚举
 - MultipleSelection: 多选
 - SingleSelection:   单选（指定是否启用取消选择）
 */
public enum SelectionType {
    /// 多选
    case multipleSelection
    /// 单选（指定是否启用取消选择）
    case singleSelection(enableDeselection: Bool)
}

/**
 * 表示Section的header或footer
 */
public enum HeaderFooterType {
    case header, footer
}


/**
 用于生成header和footer的view的枚举
 
 - Class:              将要生成的view的类型
 - Callback->ViewType: 当view创建完成时的回调block
 - NibFile:            用于从xib文件生成view的xib文件名
 */
public enum HeaderFooterProvider<ViewType: UIView> {
    case `class`
    case callback(()->ViewType)
    case nibFile(name: String, bundle: Bundle?)

    internal func createView() -> ViewType {
        switch self {
        case .class:
            return ViewType()
        case .callback(let builder):
            return builder()
        case .nibFile(let nibName, let bundle):
            return (bundle ?? Bundle(for: ViewType.self)).loadNibNamed(nibName, owner: nil, options: nil)![0] as! ViewType
        }
    }
}

/**
 用于判断指定行是否需要隐藏/禁用的判断条件
 - Function:  根据传入的函数判断
 - Predicate: 根据传入的谓词方法判断
 */
public enum Condition {
    /**
     *  计算函数
     *
     *  @param           计算数组
     *  @param SWForm->Bool 块的返回值
     *
     *  @return 是否满足条件
     */
    case function([String], (SWBaseForm)->Bool)

    /**
     *  计算谓词
     *
     *  @param 谓词
     *
     *  @return 是否满足条件
     */
    case predicate(NSPredicate)
}

/**
 *  弹出的键盘return键样式的配置
 */
public struct KeyboardReturnTypeConfiguration {
    /// 下一行可用时会使用此配置
    public var nextKeyboardType = UIReturnKeyType.next

    /// 下一行不可用时会使用此配置
    public var defaultKeyboardType = UIReturnKeyType.default

    /// 初始化
    public init() {}
    public init(nextKeyboardType: UIReturnKeyType, defaultKeyboardType: UIReturnKeyType) {
        self.nextKeyboardType = nextKeyboardType
        self.defaultKeyboardType = defaultKeyboardType
    }
}


/**
 *  可编辑的section允许的操作选项,可以有多个值，如：
 *      let xxxOptions = MultivaluedOptions.Insert.union(.Delete)
 *   判断时使用`contains`方法判断，如：
 *      xxxOptions.contains(.Reorder)
 */
public struct MultivaluedOptions: OptionSet {

    private enum Options: Int {
        case none = 0, insert = 1, delete = 2, reorder = 4
    }
    public let rawValue: Int
    public  init(rawValue: Int) { self.rawValue = rawValue}
    private init(_ options: Options) { self.rawValue = options.rawValue }

    /// 没有多值
    public static let None = MultivaluedOptions(.none)

    /// 允许插入行
    public static let Insert = MultivaluedOptions(.insert)

    /// 允许移除行
    public static let Delete = MultivaluedOptions(.delete)

    /// 允许重新排序
    public static let Reorder = MultivaluedOptions(.reorder)
}



public enum Direction { case up, down }

/// 验证错误信息
public struct ValidationError: Equatable {

    public let msg: String

    public init(msg: String) {
        self.msg = msg
    }
}

public protocol BaseRuleType {
    var id: String? { get set }
    var validationError: ValidationError { get set }
}

public protocol RuleType: BaseRuleType {
    associatedtype SWRowValueType

    func isValid(value: SWRowValueType?) -> ValidationError?
}

public protocol NoValueDisplayTextConformance: class {
    var noValueDisplayText: String? { get set }
}

