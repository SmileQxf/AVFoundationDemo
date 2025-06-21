//
//  HomeBaseViewController.swift
//  AVFoundationDemo
//
//  Created by Coding on 2025/6/21.
//  Copyright © 2025 smile. All rights reserved.
//

import UIKit

class HomeBaseViewController: UIViewController {

    let tableView = UITableView(frame: .zero, style: .grouped)
    
    var dataSource = [HomeListGroupModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadDataSource()
        
        setBaseViewUI()
    }
    
    func loadDataSource() {
        
        var audioGroup = HomeListGroupModel(mType: .audio)
        audioGroup.groupTitle = "音频"
        
        var assetModel = HomeListCellModel(mType: .mAVAsset)
        assetModel.rowTitle = "AVAsset元数据"
        assetModel.classType = AVAssetDemoViewController.self
        
        var audioPlayModel = HomeListCellModel(mType: .mAudioPlay)
        audioPlayModel.rowTitle = "AVAudioPlayer播放音频"
        audioPlayModel.classType = AVAudioPlayerDemoViewController.self
        
        var audioEngineModel = HomeListCellModel(mType: .mAudioEngine)
        audioEngineModel.rowTitle = "AVAudioEngine播放音频+可视化音频信号"
        audioEngineModel.classType = AVAudioEngineDemoViewController.self
        
        
        
        audioGroup.data.append(assetModel)
        audioGroup.data.append(audioPlayModel)
        audioGroup.data.append(audioEngineModel)
        
        
        self.dataSource = [
            audioGroup
        ]
    }

    func setBaseViewUI() {
        
        self.view.backgroundColor = .white
        
        
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(UINib(nibName: kHomeListCell_ID, bundle: nil), forCellReuseIdentifier: kHomeListCell_ID)
        self.tableView.dataSource = self
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.topMargin)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
    }
    
    

}


extension HomeBaseViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: kHomeListCell_ID) as? HomeListCell else {
            return UITableViewCell()
        }
        cell.setInfoAvatar(dataSource[indexPath.section].data[indexPath.row])
        
        return cell
    }
    
    
}
