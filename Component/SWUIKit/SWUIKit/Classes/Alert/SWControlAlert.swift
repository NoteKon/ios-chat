//
//  SWControlAlert.swift
//  Pods
//
//  Created by huang on 2020/4/21.
//

import UIKit
import SWFoundationKit
import SnapKit

/**
 可以控制点击后是否dimiss的弹框
 */

public typealias SWControlAlertHandler = (Int) -> Bool
public enum SWControlAlertStyle {
    /// 默认样式
    case `default`
    /// 升级样式
    case appUpdate
}

public class SWControlAlert {
    @discardableResult
    public static func show(title: String?,
                            message: String?,
                            cancel: String?,
                            others: [String]?,
                            textAlignment: NSTextAlignment = .center,
                            preferredAction: Int = -1,
                            using: UIViewController? = nil,
                            animated: Bool = true,
                            style: SWControlAlertStyle? = .default,
                            handler: SWControlAlertHandler?) -> SWControlAlertController {
        
        let vc = SWControlAlertController(title: title, message: message, style: style)
        vc.textAlignment = textAlignment
        
        if let otherStrs = others {
            for (index, elment) in otherStrs.enumerated() {
                let action = SWControlAlertAction(title: elment, style: .default) { [unowned vc] (act) in
                    let dismiss = handler?(index) ?? true
                    if dismiss {
                        vc.dismiss(animated: animated, completion: nil)
                    }
                }
                action.textColor = UIColor(hex: 0xFFA22D)
                vc.addAction(action)
                if index == preferredAction {
                    vc.preferredAction = action
                }
            }
        }
        if let str = cancel {
            let action = SWControlAlertAction(title: str, style: .cancel) { [unowned vc] (act) in
                let dismiss = handler?(-1) ?? true
                if dismiss {
                    vc.dismiss(animated: animated, completion: nil)
                }
            }
            action.textColor = UIColor(hex: 0x999999)
            vc.addAction(action)
        }
        
        // click on background
        vc.backgroundCallback = { [unowned vc] in
            if vc.clickBackgroundToDismiss {
                let dismiss = handler?(-2) ?? true
                if dismiss {
                    vc.dismiss(animated: animated, completion: nil)
                }
            }
        }
        
        if let fromVC = using {
            fromVC.present(vc, animated: animated, completion: nil)
        } else {
            SWRouter.present(vc, animated: animated, completion: nil)
        }
        
        return vc
    }
    
    @discardableResult
    public class func showMessageAlert(title: String?,
                                       titleColor: UIColor? = UIColor(hex: 0x333333),
                                       titleFont: UIFont? = UIFont.pingFangMedium(size: 18.0),
                                       message: String?,
                                       messageColor: UIColor? = UIColor(hex: 0x333333),
                                       messageFont: UIFont? = UIFont.pingFangRegular(size: 14.0),
                                       confirm: String?,
                                       confirmColor: UIColor? = UIColor(hex: 0xFFA22D),
                                       confirmFont: UIFont? = UIFont.pingFangMedium(size: 16.0),
                                       cancel: String?,
                                       cancelColor: UIColor? = UIColor(hex: 0x666666),
                                       cancelFont: UIFont? = UIFont.pingFangMedium(size: 16.0),
                                       using: UIViewController? = nil,
                                       animated: Bool = true,
                                       handler: ((Bool) -> Void)?) -> SWControlAlertController {
        let vc = SWControlAlertController(title: title, message: message)
        vc.textAlignment = .center
        vc.titleFont = titleFont
        vc.titleColor = titleColor
        vc.messageFont = messageFont
        vc.messageColor = messageColor
        
        if let str = confirm {
            let action = SWControlAlertAction(title: str, style: .default) { [unowned vc] (act) in
                vc.dismiss(animated: animated) {
                    handler?(true)
                }
            }
            if let color = confirmColor {
                action.textColor = color
            }
            if let font = confirmFont {
                action.textFont = font
            }
            vc.addAction(action)
        }
        if let str = cancel {
            let action = SWControlAlertAction(title: str, style: .cancel) { [unowned vc] (act) in
                vc.dismiss(animated: animated, completion: {
                    handler?(false)
                })
            }
            if let color = cancelColor {
                action.textColor = color
            }
            if let font = cancelFont {
                action.textFont = font
            }
            vc.addAction(action)
        }
        
        if let fromVC = using {
            fromVC.present(vc, animated: animated, completion: nil)
        } else {
            SWRouter.present(vc, animated: animated, completion: nil)
        }
        
        return vc
    }
}

extension SWControlAlertAction {
    public enum Style: Int {
        case `default` = 0
        case cancel = 1
        case destructive = 2
    }
}

public class SWControlAlertAction {
    public var title: String?
    
    public var isEnabled: Bool
    
    public var style: Style
    
    public var textColor: UIColor?
    
    public var textFont: UIFont?
    
    var preferred: Bool
    
    var handler: ((SWControlAlertAction) -> Void)?
    
    public init(title: String?, style: Style, handler: ((SWControlAlertAction) -> Void)?) {
        self.title = title
        self.handler = handler
        self.style = style
        self.isEnabled = true
        self.preferred = false
    }
}

public class SWControlAlertController: UIViewController {
        
    public var message: String?
    
    public var preferredAction: SWControlAlertAction?
    
    public var textAlignment: NSTextAlignment = .center
    
    public var clickBackgroundToDismiss = false
    
    // internal callback
    var backgroundCallback: (() -> Void)?
    
    var titleColor: UIColor?
    var titleFont: UIFont?
    
    var messageColor: UIColor?
    var messageFont: UIFont?
    private var showStyle: SWControlAlertStyle = .default
    
    public var actions: [SWControlAlertAction] {
        return _actions ?? []
    }
    
    private var _actions: [SWControlAlertAction]?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    private func commonInit() {
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    convenience public init(title: String?, message: String?, style: SWControlAlertStyle? = .default) {
        self.init()
        self.title = title
        self.message = message
        self.showStyle = style ?? .default
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if shouldDimBackground() {
            self.view.backgroundColor = UIColor(hex: 0, alpha: 0.60)
        }
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickViewAction)))
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initUI()
    }
        
    public func addAction(_ action: SWControlAlertAction) {
        var act = _actions ?? []
        act.append(action)
        _actions = act
    }
    
    private func shouldDimBackground() -> Bool {
        let currentVC = SWRouter.currentViewController()
        if currentVC is UIAlertController {
            return false
        }
        if currentVC is SWControlAlertController {
            return false
        }
        return true
    }
    
    private func initUI() {
        var notEmptyActions = _actions ?? []
        if notEmptyActions.count == 0 {
            notEmptyActions = [SWControlAlertAction(title: "Cancel", style: .cancel, handler: { [unowned self] (act) in
                self.dismiss(animated: true, completion: nil)
            })]
        }
        
        let count = notEmptyActions.count
        let sortedActions = notEmptyActions.sorted { (act1, act2) -> Bool in
            if act1.style == .cancel {
                return count > 2 ? false : true
            }
            return false
        }
        
        let preferred = sortedActions.first { $0 === preferredAction }
        if let preferred = preferred {
            preferred.preferred = true
        } else {
            if count > 2 {
                sortedActions.last?.preferred = true
            } else {
                sortedActions.first?.preferred = true
            }
        }
        
        var showAlert: UIView?
        if showStyle == .default {
            let alert = _SWControlAlertView(title: title, message: message, actions: sortedActions)
            alert.contentLabel.textAlignment = textAlignment
            alert.titleLabel.numberOfLines = 0
            if let color = titleColor {
                alert.titleLabel.textColor = color
            }
            if let font = titleFont {
                alert.titleLabel.font = font
            }
            if let color = messageColor {
                alert.contentLabel.textColor = color
            }
            if let font = messageFont {
                alert.contentLabel.font = font
            }
            self.view.addSubview(alert)
            alert.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(42)
                make.trailing.equalToSuperview().offset(-42)
                make.centerY.equalToSuperview()
            }
            showAlert = alert
        } else if showStyle == .appUpdate {
            let alert = _SWControlAlertAppUpdateView(title: title, message: message, actions: sortedActions)
            alert.contentLabel.textAlignment = textAlignment
            alert.titleLabel.numberOfLines = 0
            if let color = titleColor {
                alert.titleLabel.textColor = color
            }
            if let font = titleFont {
                alert.titleLabel.font = font
            }
            if let color = messageColor {
                alert.contentLabel.textColor = color
            }
            if let font = messageFont {
                alert.contentLabel.font = font
            }
            self.view.addSubview(alert)
            alert.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(42)
                make.trailing.equalToSuperview().offset(-42)
                make.centerY.equalToSuperview()
            }
            showAlert = alert
        }
        showAlert?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            showAlert?.transform = .identity
        }) { (finished) in
            
        }
    }
    
    @objc func clickViewAction() {
        backgroundCallback?()
    }
}

private let kSeparatorColor = UIColor(hex: 0xEEEEEE)

final private class _SWControlAlertAppUpdateView: UIView {
    var titleLabel: UILabel!
    var contentLabel: UILabel!
    var actionView: UIStackView!
    private var _actions = [SWControlAlertAction]()
    
    convenience init(title: String?, message: String?, actions: [SWControlAlertAction], style: SWControlAlertStyle? = .default) {
        self.init()
        customInit(title: title, message: message, actions: actions)
    }
    
    private func customInit(title: String?, message: String?, actions: [SWControlAlertAction]) {

        let cornerRadius: CGFloat = 8
        backgroundColor = UIColor(hex: 0xFFFFFF)
        layer.cornerRadius = cornerRadius
        
        titleLabel = UILabel()
        addSubview(titleLabel)
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = UIColor(hex: 0x333333)
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.pingFangMedium(size: 18)
        titleLabel.text = title
        
        contentLabel = UILabel()
        addSubview(contentLabel)
        contentLabel.backgroundColor = .clear
        contentLabel.textColor = UIColor(hex: 0x333333)
        contentLabel.textAlignment = .left
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.numberOfLines = 0
        contentLabel.text = message
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        let attr = NSMutableAttributedString(string: message ?? "")
        attr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, message?.count ?? 0))
        contentLabel.attributedText = attr
        
        actionView = UIStackView()
        actionView.spacing = 13
        addSubview(actionView)
        if actions.count > 2 {
            actionView.axis = .vertical
            actionView.alignment = .fill
            actionView.distribution = .fillEqually
        } else {
            actionView.axis = .horizontal
            actionView.alignment = .center
            actionView.distribution = .fillEqually
        }

        _actions = actions
        for action in actions {
            let button = UIButton(type: .custom)
            button.setTitle(action.title, for: .normal)
            button.titleLabel?.font = UIFont.pingFangMedium(size: 14)
            button.layer.cornerRadius = 4
            button.setTitleColor(action.textColor, for: .normal)
            if action.style == .cancel {
                button.backgroundColor = .clear
                button.setTitleColor(UIColor(hex: 0x999999), for: .normal)
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor(hex: 0xCCCCCC).cgColor
            } else {
                button.backgroundColor = UIColor(hex: 0xFFA22D)
                button.setTitleColor(.white, for: .normal)
            }
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            actionView.addArrangedSubview(button)
            button.snp.makeConstraints { (maker) in
                maker.height.equalTo(40)
            }
        }
        
        layoutInit()
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        guard let index = _actions.firstIndex(where: { $0.title == sender.titleLabel?.text }) else { return }
        let action = _actions[index]
        action.handler?(action)
    }
    
    private func layoutInit() {
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(32)
        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(19)
            make.right.equalTo(-19)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset((self.titleLabel.text?.count ?? 0 > 0) ? 21 : 0)
        }
        
        actionView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(9)
            make.trailing.equalToSuperview().offset(-9)
            make.bottom.equalToSuperview().offset(-26)
            make.top.equalTo(contentLabel.snp.bottom).offset((self.contentLabel.text?.count ?? 0 > 0) ? 21 : 0)
        }
    }
}

final private class _SWControlAlertView: UIView {
    var titleLabel: UILabel!
    var contentLabel: UILabel!
    var actionView: UIStackView!
    
    private var contentBottomLine: UIView!
    
    convenience init(title: String?, message: String?, actions: [SWControlAlertAction]) {
        self.init()
        customInit(title: title, message: message, actions: actions)
    }
    
    private func customInit(title: String?, message: String?, actions: [SWControlAlertAction]) {
        let cornerRadius: CGFloat = 8
        backgroundColor = UIColor(hex: 0xFFFFFF)
        layer.cornerRadius = cornerRadius
        
        titleLabel = UILabel()
        addSubview(titleLabel)
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = title
        
        contentLabel = UILabel()
        addSubview(contentLabel)
        contentLabel.backgroundColor = .clear
        contentLabel.textColor = .black
        contentLabel.textAlignment = .center
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.numberOfLines = 0
        contentLabel.text = message
        
        contentBottomLine = UIView()
        addSubview(contentBottomLine)
        contentBottomLine.backgroundColor = kSeparatorColor
        
        actionView = UIStackView()
        addSubview(actionView)
        if actions.count > 2 {
            actionView.axis = .vertical
            actionView.alignment = .fill
            actionView.distribution = .fillEqually
        } else {
            actionView.axis = .horizontal
            actionView.alignment = .center
            actionView.distribution = .fillEqually
        }

        for (i, action) in actions.enumerated() {
            let view = _SWControlAlertActionView(action: action)
            actionView.addArrangedSubview(view)
            view.actionBlock = { [unowned action] in
                action.handler?(action)
            }
            view.snp.makeConstraints { (maker) in
                maker.height.equalTo(44.0)
            }
            // dim
//            if actionView.axis == .horizontal {
//                if actions.count > 1 {
//                    if i == 0 {
//                        view.roundDimView(corners: .bottomLeft, radius: cornerRadius)
//                    } else if i == actions.count - 1 {
//                        view.roundDimView(corners: .bottomRight, radius: cornerRadius)
//                    }
//                } else {
//                    view.roundDimView(corners: [.bottomLeft, .bottomRight], radius: cornerRadius)
//                }
//            } else {
//                if i == actions.count - 1 {
//                    view.roundDimView(corners: [.bottomLeft, .bottomRight], radius: cornerRadius)
//                }
//            }
            // separator
            view.updateSeparator(actionView.axis == .horizontal ? 0 : 1, hidden: i == actions.count - 1)
        }
        
        layoutInit()
    }
    
    private func layoutInit() {
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(20)
        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.leading.greaterThanOrEqualToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
        }
        
        contentBottomLine.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(contentLabel.snp.bottom).offset(20)
            make.height.equalTo(0.5)
        }
        
        actionView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(contentBottomLine.snp.bottom)
        }
    }
}

private func UIRectCornersToCACornerMask(_ corners: UIRectCorner) -> CACornerMask {
    var mask = CACornerMask()
    if corners.contains(.bottomLeft) {
        mask.insert(.layerMinXMaxYCorner)
    }
    if corners.contains(.bottomRight) {
        mask.insert(.layerMaxXMaxYCorner)
    }
    if corners.contains(.topLeft) {
        mask.insert(.layerMinXMinYCorner)
    }
    if corners.contains(.topRight) {
        mask.insert(.layerMaxXMinYCorner)
    }
    
    return mask
}

final private class _SWControlAlertActionView: UIView {
    
    var separatorLine: UIView!
    var actionBlock: (() -> Void)?
    var dimView: UIView!
    var textLabel: UILabel!
    
    private var corners: UIRectCorner?
    private var radius: CGFloat?
    
    convenience init(action: SWControlAlertAction) {
        self.init()
        customInit(action: action)
    }
    
    private func customInit(action: SWControlAlertAction) {
        textLabel = UILabel()
        addSubview(textLabel)
        
        let color = action.textColor ?? UIColor.systemBlue
        let defaultFont = action.preferred ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 16)
        let font = action.textFont ?? defaultFont
        
        textLabel.backgroundColor = .clear
        textLabel.text = action.title
        textLabel.textColor = color
        textLabel.textAlignment = .center
        textLabel.font = font
        
        textLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
//            make.top.equalToSuperview().offset(12)
//            make.bottom.equalToSuperview().offset(-12)
        }
        
        dimView = UIView()
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        addSubview(dimView)
        dimView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        dimView.isHidden = true
        
        separatorLine = UIView()
        addSubview(separatorLine)
        separatorLine.backgroundColor = kSeparatorColor
        separatorLine.isHidden = true
        
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction(sender:))))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds.width > 0, bounds.height > 0,
            dimView.layer.mask == nil, let corners = corners, let radius = radius {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            dimView.layer.mask = mask
        }
    }
    
    // 0-horizontal, 1-vertical
    func updateSeparator(_ style: Int, hidden: Bool) {
        if style == 0 {
            separatorLine.snp.makeConstraints { (make) in
                make.width.equalTo(0.5)
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
                make.right.equalToSuperview().offset(-0.5)
            }
        } else {
            separatorLine.snp.makeConstraints { (make) in
                make.height.equalTo(0.5)
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
        separatorLine.isHidden = hidden
    }
    
    func roundDimView(corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            dimView.layer.cornerRadius = radius
            dimView.layer.maskedCorners = UIRectCornersToCACornerMask(corners)
        } else {
            /// Fallback on earlier versions
            /// 需要知道bounds
            self.corners = corners
            self.radius = radius
            setNeedsLayout()
        }
    }
    
    @objc private func tapAction(sender: UITapGestureRecognizer) {
        actionBlock?()
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dimView.isHidden = false
        textLabel.textColor = textLabel.textColor.withAlphaComponent(0.5)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dimView.isHidden = true
        textLabel.textColor = textLabel.textColor.withAlphaComponent(1.0)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        dimView.isHidden = true
        textLabel.textColor = textLabel.textColor.withAlphaComponent(1.0)
    }
}
