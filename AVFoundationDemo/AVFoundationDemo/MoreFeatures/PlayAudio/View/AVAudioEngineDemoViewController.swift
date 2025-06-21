//
//  AVAudioEngineDemoViewController.swift
//  AVFoundationDemo
//
//  Created by Coding on 2025/6/21.
//  Copyright © 2025 smile. All rights reserved.
//

import UIKit
import AVFAudio

class AVAudioEngineDemoViewController: AVBaseDemoViewController {
    
    /// 播放/暂停按钮
    @IBOutlet weak var playOrPauseButton: UIButton!
    /// 快进 10秒按钮
    @IBOutlet weak var forwardButton: UIButton!
    /// 快退 10秒按钮
    @IBOutlet weak var backwardButton: UIButton!
    
    
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!

    
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()

    var isPlaying = false
    var progressTimer: Timer?
    private var meterLevel = 0
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        engine.stop()
        player.stop()
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
        
        // 播放音频文件
        guard let audioFile = try? AVAudioFile(forReading: fileURL) else {
            debugPrint("播放失败, 创建AVAudioFile对象失败")
            return
        }
        let format = audioFile.processingFormat
        
        let audioLengthSamples = audioFile.length
        let audioSampleRate = format.sampleRate
        let audioLengthSeconds = Double(audioLengthSamples) / audioSampleRate
        
        debugPrint("format:\(format)")
        debugPrint("audioLengthSamples:\(audioLengthSamples)")
        debugPrint("audioSampleRate:\(audioSampleRate)")
        
        debugPrint("audioLengthSeconds:\(audioLengthSeconds)")
        debugPrint("audioLengthSeconds:\(Int(audioLengthSeconds)/60)分\(Int(audioLengthSeconds)%60)秒")
        
        durationLabel.text = "\(Int(audioLengthSeconds)/60):\(Int(audioLengthSeconds)%60)"
        // 初始化音频引擎
        configureEngine(with: format, audioFile: audioFile)
    }
    
    
    // 初始化音频引擎
    private func configureEngine(with format: AVAudioFormat, audioFile: AVAudioFile) {
        
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        do {
            try engine.start()
        } catch {
            print("出现错误error:\(error)")
        }
        player.scheduleFile(audioFile, at: nil, completionHandler: nil)
        
        //let format = engine.mainMixerNode.outputFormat(forBus: 0)
        //
        //engine.mainMixerNode.installTap(
        //    onBus: 0,
        //    bufferSize: 1024,  // 每次回调的采样数
        //    format: format
        //) { [weak self] (buffer, _) in
        //    debugPrint("测试数据:\(buffer)")
        //    self?.connectVolumeTap(buffer) // 在这里处理实时音频数据
        //}
    }

    
    private func connectVolumeTap(_ buffer: AVAudioPCMBuffer) {
        //let format = engine.mainMixerNode.outputFormat(forBus: 0)
        //
        //engine.mainMixerNode.installTap(
        //    onBus: 0,
        //    bufferSize: 1024,
        //    format: format
        //) { buffer, _ in
            guard let channelData = buffer.floatChannelData else {
                return
            }
            
            let channelDataValue = channelData.pointee
            let channelDataValueArray = stride(
                from: 0,
                to: Int(buffer.frameLength),
                by: buffer.stride)
                .map { channelDataValue[$0] }
            
            let rms = sqrt(channelDataValueArray.map {
                return $0 * $0
            }
                .reduce(0, +) / Float(buffer.frameLength))
            
            let avgPower = 20 * log10(rms)
            let meterLevel = self.scaledPower(power: avgPower)
            debugPrint("---音量meterLevel:\(meterLevel)")
            DispatchQueue.main.async {
                //self.meterLevel = self.isPlaying ? meterLevel : 0
            }
        //}
    }
    
    private func scaledPower(power: Float) -> Float {
        guard power.isFinite else {
            return 0.0
        }
        
        let minDb: Float = -80
        
        if power < minDb {
            return 0.0
        } else if power >= 1.0 {
            return 1.0
        } else {
            return (abs(minDb) - abs(power)) / abs(minDb)
        }
    }
    
    
    private func connectVolumeTap() {
        
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        
        engine.mainMixerNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: format
        ) { [weak self] buffer, _ in
            debugPrint("测试数据:\(buffer)")
            self?.connectVolumeTap(buffer) // 在这里处理实时音频数据
        }
        
        
        
    }
    
    
    private func disconnectVolumeTap() {
        engine.mainMixerNode.removeTap(onBus: 0)
        meterLevel = 0
    }
    
    
    
    // MARK: - Button Actions
    @IBAction func playOrPauseBtnClick(_ sender: UIButton) {
        
        isPlaying.toggle()
        
        if player.isPlaying {
            player.pause()
            
            disconnectVolumeTap()
            //stopProgressTimer()
        } else {
            
            connectVolumeTap()
            player.play()
            //startProgressTimer()
        }
        
        sender.setImage(isPlaying ? UIImage.pause : UIImage.play, for: .normal)
    }
    
    
    /// 快进 10秒按钮
    @IBAction func forwardBtnClick(_ sender: UIButton) {
        
//        // 快进10秒（不超过总时长）
//        let newTime = min(player.currentTime + 10, player.duration)
//        player.currentTime = newTime
//        
//        // 更新UI
//        progressSlider.value = Float(newTime / player.duration)
//        updateTimeLabels()
//        
//        // 如果原本是暂停状态，快进后保持暂停
//        if !isPlaying { return }
//        
//        // 如果原本在播放，继续播放
//        player.play()
    }
    
    /// 快退 10秒按钮
    @IBAction func backwardBtnClick(_ sender: UIButton) {
        
//        // 快退10秒（不小于0）
//        let newTime = max(player.currentTime - 10, 0)
//        player.currentTime = newTime
//        
//        // 更新UI
//        progressSlider.value = Float(newTime / player.duration)
//        updateTimeLabels()
//        
//        // 如果原本是暂停状态，快退后保持暂停
//        if !isPlaying { return }
//        
//        // 如果原本在播放，继续播放
//        player.play()
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
        
        if player.isPlaying {
            player.pause()
            
            self.playOrPauseButton.setImage(UIImage.play, for: .normal)
            stopProgressTimer()
        }
    }
    @objc private func sliderValueChanged(_ slider: UISlider) {
        
//        let newTime = Double(slider.value) * player.duration
//        currentTimeLabel.text = formatTime(newTime)
    }
    
    @objc private func sliderTouchUp(_ slider: UISlider) {
        
//        let newTime = Double(slider.value) * player.duration
//        player.currentTime = newTime
//        
//        if isPlaying {  // 如果原本是播放状态，松开后继续播放
//            player.play()
//            startProgressTimer()
//            
//            // self.isPlaying = true
//            self.playOrPauseButton.setImage(UIImage.pause, for: .normal)
//        }
//        
//        updateTimeLabels()
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
        
//        progressSlider.value = Float(player.currentTime / player.duration)
//        updateTimeLabels()
    }
    
    private func updateTimeLabels() {
        
//        currentTimeLabel.text = formatTime(player.currentTime)
//        durationLabel.text = formatTime(player.duration)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func setupUI() {
        
        currentTimeLabel.text = "00:00"
        currentTimeLabel.numberOfLines = 1
        currentTimeLabel.adjustsFontSizeToFitWidth = true
        
        durationLabel.text = "00:00"
        durationLabel.numberOfLines = 1
        durationLabel.adjustsFontSizeToFitWidth = true
        
        self.playOrPauseButton.setTitle("", for: .normal)
        self.playOrPauseButton.setImage(UIImage.play, for: .normal)
        
        // 快进 10秒按钮
        forwardButton.setTitle("", for: .normal)
        forwardButton.setImage(UIImage.forward, for: .normal)
        // 快退 10秒按钮
        backwardButton.setTitle("", for: .normal)
        backwardButton.setImage(UIImage.backward, for: .normal)
    }
    
    deinit {
        debugPrint("AVAudioPlayerDemoViewController 正常销毁")
    }
}


extension AVAudioEngineDemoViewController: AVAudioPlayerDelegate {
    
    /// 音频播放器已完成播放
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("音频播放器已完成播放player:\(player) flag:\(flag)")
        self.isPlaying = false
        self.playOrPauseButton.setImage(UIImage.play, for: .normal)
        engine.pause()
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
