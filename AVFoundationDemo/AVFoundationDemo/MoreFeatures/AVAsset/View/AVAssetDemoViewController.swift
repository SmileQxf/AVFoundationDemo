//
//  AVAssetDemoViewController.swift
//  AVFoundationDemo
//
//  Created by Coding on 2025/6/21.
//  Copyright © 2025 smile. All rights reserved.
//

import UIKit
import AVFoundation

class AVAssetDemoViewController: AVBaseDemoViewController {
    
    
    @IBOutlet weak var mTitleLabel: UILabel!
    @IBOutlet weak var mArtistLabel: UILabel!
    @IBOutlet weak var mAlbumNameLabel: UILabel!
    
    /// 总时长
    @IBOutlet weak var mDurationLabel: UILabel!
    /// 秒值
    @IBOutlet weak var mDurationSecondsLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let url = Bundle.main.url(forResource: "chun_tian_li.mp3", withExtension: nil) else {
            return
        }
        self.getAudioMetadata(from: url)
    }
    
    func getAudioMetadata(from url: URL) {
        let asset = AVAsset(url: url)
        
        // 异步加载元数据
        asset.loadValuesAsynchronously(forKeys: ["metadata", "duration"]) {
            var error: NSError? = nil
            let metadataStatus = asset.statusOfValue(forKey: "metadata", error: &error)
            
            DispatchQueue.main.async {
                if metadataStatus == .loaded {
                    // 获取所有元数据
                    //for item in asset.metadata {
                    //    guard let key = item.commonKey?.rawValue,
                    //          let value = item.value else { continue }
                    //
                    //    debugPrint("\(key): \(value)")
                    //}
                    
                    // 获取特定元数据
                    let title = AVMetadataItem.metadataItems(
                        from: asset.metadata,
                        withKey: AVMetadataKey.commonKeyTitle,
                        keySpace: AVMetadataKeySpace.common
                    ).first?.stringValue ?? "未知标题"
                    
                    let artist = AVMetadataItem.metadataItems(
                        from: asset.metadata,
                        withKey: AVMetadataKey.commonKeyArtist,
                        keySpace: AVMetadataKeySpace.common
                    ).first?.stringValue ?? "未知艺术家"
                    
                    let albumName = AVMetadataItem.metadataItems(
                        from: asset.metadata,
                        withKey: AVMetadataKey.commonKeyAlbumName,
                        keySpace: AVMetadataKeySpace.common
                    ).first?.stringValue ?? "未知专辑名称"
                    
                    //debugPrint("标题: \(title)")
                    //debugPrint("艺术家: \(artist)")
                    //debugPrint("专辑名称: \(albumName)")
                    
                        self.mTitleLabel.text = "标题: \(title)"
                    self.mArtistLabel.text = "艺术家: \(artist)"
                    self.mAlbumNameLabel.text = "专辑名称: \(albumName)"
                    
                    
                    
                    // 正确获取时长（秒）
                    let durationInSeconds = CMTimeGetSeconds(asset.duration)
                    let minutes = Int(durationInSeconds / 60)
                    let seconds = Int(durationInSeconds.truncatingRemainder(dividingBy: 60))
                    
                    //debugPrint("总时长: \(minutes)分\(seconds)秒")
                    //debugPrint("精确秒数: \(durationInSeconds)秒")
                    // 总时长
                    self.mDurationLabel.text = "总时长: \(minutes)分\(seconds)秒"
                    // 秒值
                    self.mDurationSecondsLabel.text = "精确秒数: \(durationInSeconds)"
                } else {
                    debugPrint("加载元数据失败: \(error?.localizedDescription ?? "未知错误")")
                }
            }
        }
    }
    
    
    deinit {
        debugPrint("正常销毁费")
    }
}
