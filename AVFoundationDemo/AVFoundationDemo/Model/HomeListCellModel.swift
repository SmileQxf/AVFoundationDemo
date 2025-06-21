//
//  HomeListCellModel.swift
//  AVFoundationDemo
//
//  Created by Coding on 2025/6/21.
//  Copyright © 2025 smile. All rights reserved.
//

import UIKit

/// 首页, TableView 分组类型
enum HomeListGroupType {
    case audio
    case video
}


/// 首页, TableView 分组模型
struct HomeListGroupModel {
    
    let mType: HomeListGroupType
    var groupTitle = ""
    var data = [HomeListCellModel]()
}


/// 首页, TableView 每一个cell的模型
struct HomeListCellModel {
    let mType: HomeListCellModelType
    /// cell标题显示的值
    var rowTitle = ""
    var rowValue = ""
    
    var classType: AVBaseDemoViewController.Type?
}

/// 首页, TableView 每一个cell的类型
enum HomeListCellModelType {
    case mAVAsset
    case mAudioPlay
    case deviceMac
    case serialNumber
    case storageSpace
}



