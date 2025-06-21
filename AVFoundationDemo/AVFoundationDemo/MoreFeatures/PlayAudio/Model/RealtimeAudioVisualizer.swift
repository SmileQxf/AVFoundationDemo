//
//  RealtimeAudioVisualizer.swift
//  AVFoundationDemo
//
//  Created by Coding on 2025/6/21.
//  Copyright © 2025 smile. All rights reserved.
//

import AVFoundation

class RealtimeAudioVisualizer {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    
    func setup(with audioURL: URL) {
        guard let audioFile = try? AVAudioFile(forReading: audioURL) else { return }
        
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: audioFile.processingFormat)
        
        // 安装 Tap 获取实时音频数据
        engine.mainMixerNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: engine.mainMixerNode.outputFormat(forBus: 0)
        ) { [weak self] (buffer, _) in
            self?.processBuffer(buffer)
        }
        
        try? engine.start()
        playerNode.scheduleFile(audioFile, at: nil)
        playerNode.play()
    }
    
    private func processBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let floatData = buffer.floatChannelData else { return }
        let samples = Array(UnsafeBufferPointer(start: floatData[0], count: Int(buffer.frameLength)))
        debugPrint("当前数据samples:\(samples)")
        DispatchQueue.main.async {
            // 更新 UI（如绘制波形）
        }
    }
}
