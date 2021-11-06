//
//  ReuseIdentifying.swift
//  VVLife
//
//  Created by 吴迪玮 on 2020/6/16.
//  Copyright © 2020 vv. All rights reserved.
//

import Foundation

public protocol ReuseIdentifying {
    static var kVLReuseIdentifier: String { get }
}

extension ReuseIdentifying {
    public static var kVLReuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UICollectionViewCell: ReuseIdentifying {}

extension UITableViewCell: ReuseIdentifying {}

extension UITableViewHeaderFooterView: ReuseIdentifying {}

extension UICollectionReusableView: ReuseIdentifying {}
