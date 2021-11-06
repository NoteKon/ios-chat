//
//  CellType.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/11/24.
//

public protocol SWScrollObserverCellType {
    /// 开始滚动/拖动
    func willBeginScrolling()
    
    /// 滚动/拖动已结束
    func didEndScrolling()
}
