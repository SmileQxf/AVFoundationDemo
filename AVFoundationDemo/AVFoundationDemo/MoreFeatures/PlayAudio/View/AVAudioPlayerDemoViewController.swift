//
//  AVAudioPlayerDemoViewController.swift
//  AVFoundationDemo
//
//  Created by Coding on 2025/6/21.
//  Copyright © 2025 smile. All rights reserved.
//

import UIKit
import AVFAudio

class AVAudioPlayerDemoViewController: AVBaseDemoViewController {
    
    /// 播放/暂停按钮
    @IBOutlet weak var playOrPauseButton: UIButton!
    /// 上一曲按钮
    @IBOutlet weak var previousPlayerButton: UIButton!
    /// 下一曲按钮
    @IBOutlet weak var nextPlayerButton: UIButton!

    

    var player: AVAudioPlayer?
    var isPlaying = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupAudio()
    }
    

    // MARK: - Private
    private func setupAudio() {
        
        guard let fileURL = Bundle.main.url(forResource: "chun_tian_li.mp3", withExtension: nil) else {
            debugPrint("播放失败, 资源找不到")
            return
        }
        
        debugPrint("当前路径fileURL:\(fileURL)")
        
        
        do {
            self.player = try AVAudioPlayer(contentsOf: fileURL)
            self.player?.delegate = self
        } catch {
            print("创建播放器失败error:\(error.localizedDescription)")
        }
        
        self.playOrPauseButton.setTitle("", for: .normal)
        self.playOrPauseButton.setImage(UIImage.play, for: .normal)
    }
    
    
    @IBAction func playOrPauseBtnClick(_ sender: UIButton) {
        
        guard let player = player else { return }
        
        isPlaying.toggle()
        
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
        
        sender.setImage(isPlaying ? UIImage.pause : UIImage.play, for: .normal)
        
    }
    
}


extension AVAudioPlayerDemoViewController: AVAudioPlayerDelegate {
    
    /// 音频播放器已完成播放
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("音频播放器已完成播放player:\(player) flag:\(flag)")
        self.playOrPauseButton.setImage(UIImage.play, for: .normal)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: (any Error)?) {
        print("音频播放器解码错误发生error:\(String(describing: error))")
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        print("音频播放器开始中断player:\(player)")
    }
    
    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        print("音频播放器结束中断player:\(player)  flags:\(flags)")
    }
}
