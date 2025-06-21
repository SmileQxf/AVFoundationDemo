//
//  ViewController.swift
//  AVFoundationDemo
//
//  Created by Smile on 2017/11/26.
//  Copyright © 2017年 com.jimi.smile. All rights reserved.
//

import UIKit
import Photos

class CameraTestViewController: UIViewController {
    
    let cameraController = CameraController()
    ///拍摄按钮
    @IBOutlet fileprivate var captureButton:UIButton!
    
    ///用于显示摄像机捕获到的图像视图
    @IBOutlet fileprivate var capturePreviewView: UIView!
    /// 切换到拍照
    @IBOutlet weak var photoModeButton: UIButton!
    /// 切换到录像
    @IBOutlet weak var videoModeButton: UIButton!
    /// 切换涉嫌头按钮
    @IBOutlet weak var toggleCameraButton: UIButton!
    /// 开关闪光灯
    @IBOutlet weak var toggleFlashButton: UIButton!


}

extension CameraTestViewController {
    override func viewDidLoad() {
        func configureCameraController() {
            cameraController.prepare {(error) in
                if let error = error {
                    print(error)
                }
                
                try? self.cameraController.displayPreview(on: self.capturePreviewView)
            }
        }
        
        func styleCaptureButton() {
            captureButton.layer.borderColor = UIColor.black.cgColor
            captureButton.layer.borderWidth = 2
            
            captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
        }
        
        styleCaptureButton()
        configureCameraController()
    }
}

extension CameraTestViewController {
    @IBAction func toggleFlash(_ sender: UIButton) {
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash_Off"), for: .normal)
        }
            
        else {
            cameraController.flashMode = .on
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash_On"), for: .normal)
        }
    }
    
    @IBAction func switchCameras(_ sender: UIButton) {
        do {
            try cameraController.switchCameras()
        }
            
        catch {
            print(error)
        }
        
        switch cameraController.currentCameraPosition {
        case .some(.front):
            toggleCameraButton.setImage(#imageLiteral(resourceName: "Camera_Front"), for: .normal)
            
        case .some(.rear):
            toggleCameraButton.setImage(#imageLiteral(resourceName: "Camera_Rear"), for: .normal)
            
        case .none:
            return
        }
    }
    
    @IBAction func captureImage(_ sender: UIButton) {
        cameraController.captureImame {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
    
}
