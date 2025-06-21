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
    
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!

    

    var player: AVAudioPlayer?
    var isPlaying = false
    var progressTimer: Timer?
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.player?.pause()
        self.player?.delegate = nil
        self.player = nil
        
        stopProgressTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupAudio()
        setupProgressSlider()
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
    
    // MARK: - Button Actions
    @IBAction func playOrPauseBtnClick(_ sender: UIButton) {
        
        guard let player = player else { return }
        
        isPlaying.toggle()
        
        if player.isPlaying {
            player.pause()
            stopProgressTimer()
        } else {
            player.play()
            startProgressTimer()
        }
        
        sender.setImage(isPlaying ? UIImage.pause : UIImage.play, for: .normal)
    }
    
    
    private func setupProgressSlider() {
        progressSlider.value = 0
        // 按下时暂停播放
        progressSlider.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        // 拖动时更新预览时间
        progressSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        // 松开时恢复播放
        progressSlider.addTarget(self, action: #selector(sliderTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
    }
    
    // MARK: - Slider Actions
    @objc private func sliderTouchDown(_ slider: UISlider) {
        guard let player = player else { return }
        
        if player.isPlaying {
            player.pause()
            
            // isPlaying = false
            self.playOrPauseButton.setImage(UIImage.play, for: .normal)
            stopProgressTimer()
        }
    }
    @objc private func sliderValueChanged(_ slider: UISlider) {
        guard let player = player else { return }
        
        let newTime = Double(slider.value) * player.duration
        currentTimeLabel.text = formatTime(newTime)
    }
    
    @objc private func sliderTouchUp(_ slider: UISlider) {
        guard let player = player else { return }
        
        let newTime = Double(slider.value) * player.duration
        player.currentTime = newTime
        
        if isPlaying {  // 如果原本是播放状态，松开后继续播放
            player.play()
            startProgressTimer()
            
            // self.isPlaying = true
            self.playOrPauseButton.setImage(UIImage.pause, for: .normal)
        }
        
        updateTimeLabels()
    }
    
    
    // MARK: - Progress Tracking
    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(updateProgress),
            userInfo: nil,
            repeats: true
        )
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    @objc private func updateProgress() {
        guard let player = player else { return }
        
        progressSlider.value = Float(player.currentTime / player.duration)
        updateTimeLabels()
    }
    
    private func updateTimeLabels() {
        guard let player = player else { return }
        
        currentTimeLabel.text = formatTime(player.currentTime)
        durationLabel.text = formatTime(player.duration)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func setupUI() {
        
        currentTimeLabel.text = ""
        currentTimeLabel.numberOfLines = 1
        currentTimeLabel.adjustsFontSizeToFitWidth = true
        
        durationLabel.text = ""
        durationLabel.numberOfLines = 1
        durationLabel.adjustsFontSizeToFitWidth = true
    }
    
    deinit {
        debugPrint("AVAudioPlayerDemoViewController 正常销毁")
    }
}


extension AVAudioPlayerDemoViewController: AVAudioPlayerDelegate {
    
    /// 音频播放器已完成播放
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("音频播放器已完成播放player:\(player) flag:\(flag)")
        self.isPlaying = false
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
