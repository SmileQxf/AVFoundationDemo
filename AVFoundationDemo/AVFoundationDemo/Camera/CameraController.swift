//
//  CameraController.swift
//  AV Foundation
//
//  Created by Smile on 2017/11/25.
//  Copyright © 2017年 Pranjal Satija. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: NSObject {
    
    var captureSession:AVCaptureSession?
    var frontCamera:AVCaptureDevice?
    var rearCamera:AVCaptureDevice?
    
    var currentCameraPosition:CameraPosition?
    var frontCameraInput:AVCaptureDeviceInput?
    var rearCameraInput:AVCaptureDeviceInput?
    
    var photoOutput:AVCapturePhotoOutput?
    
    var previdwLayer:AVCaptureVideoPreviewLayer?
    
    var flashMode = AVCaptureDevice.FlashMode.off
    
    var photoCaptureCompletionBlock:((UIImage?,Error?) -> Void)?
}


extension CameraController {
    //我们解耦init 并创建一个函数prepare准备捕获回话以供使用,并在完成时候调用完成处理程序
    func prepare(completionHandler: @escaping(Error?) -> Void) {
        
        //在这个函数将处理捕获回话的创建和配置. 请记住, 设置捕获回话4个步骤组成:
        //1.创建一个捕获回话
        func createCaptureSessiong(){
            self.captureSession = AVCaptureSession()
        }
        
        //2.获取和配置必要的捕获设备
        func configureCaptureDevices() throws {
            
            //1.查找当前设备上可用的所有相机,并将其转换为非可选AVCaptureDevice对象数组. 如果没有可用相机会抛出一个错误
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
           // guard  !cameras.isEmpty else { throw CameraControllerError.noCamerasAvailable }
            let cameras = (session.devices.flatMap { $0 })
            //2.该循环通过上面查找到的可用摄像头进行查看, 并确定那个是前置摄像头,那个是后置摄像头.它还将后置摄像头配置为自动对焦,并抛出沿途遇到的任何错误
            for camera in cameras {
                if camera.position == .front {
                    self.frontCamera = camera
                }
                
                if camera.position == .back {
                    self.rearCamera = camera
                    
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
        }
        
        //3.使用捕获设备创建输入
        func configureDeviceInputs() throws {
            
            guard let captureSession = self.captureSession else{
                throw CameraControllerError.captureSessionIsMissing
            }
            
            if let rearCamera = self.rearCamera{
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!){ captureSession.addInput(self.rearCameraInput!) }
                
                self.currentCameraPosition = .rear
            }else if let frontCamera = self.frontCamera{
                
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!)}
                
                self.currentCameraPosition = .front
            }
        }
        
        //4.配置照片输出对象以处理拍摄的图像
        func configurePhotoOut() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecJPEG])], completionHandler: nil)
            
            if captureSession .canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!)}
            captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepare").async {
            do{
                createCaptureSessiong()
                
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOut()
            }catch{
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    //显示预览视图
    func displayPreview(on view:UIView) throws {
        
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previdwLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previdwLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previdwLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previdwLayer!, at: 0)
        self.previdwLayer?.frame = view.frame
    }
    
    //切换摄像头
    func switchCameras() throws {
        
        guard let currenCameraPoisition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else {
            throw CameraControllerError.captureSessionIsMissing
        }
        
        captureSession.beginConfiguration()
        
        func switchToFrontCamera() throws{
            guard let inputs = captureSession.inputs as? [AVCaptureInput], let rearCameraInput = self.rearCameraInput, inputs.contains(rearCameraInput), let frontCamera = self.frontCamera else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(self.frontCameraInput!) {
                captureSession.addInput(self.frontCameraInput!)
                self.currentCameraPosition = .front
            }else{ throw CameraControllerError.invalidOperation }
        }
        func switchToRearCamera() throws{
            guard let inputs = captureSession.inputs as? [AVCaptureInput], let frontCameraInput = self.frontCameraInput, inputs.contains(frontCameraInput), let rearCamera = self.rearCamera else { throw CameraControllerError.captureSessionIsMissing }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            captureSession.removeInput(frontCameraInput)
            if captureSession.canAddInput(self.rearCameraInput!) {
                captureSession.addInput(self.rearCameraInput!)
                self.currentCameraPosition = .rear
            }else{ throw CameraControllerError.invalidOperation }
        }
        
        switch currenCameraPoisition {
        case .front:
            try switchToRearCamera()
        case .rear:
            try switchToFrontCamera()
        }
        
        captureSession.commitConfiguration()
        
    }
    
    //相机拍摄图片
    func captureImame(completion:@escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else{ completion(nil, CameraControllerError.captureSessionIsMissing); return}
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
}


extension CameraController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print("error___:\(error)")
            self.photoCaptureCompletionBlock!(nil, error)
        }else if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil){
            
            let image = UIImage(data: data)
            self.photoCaptureCompletionBlock!(image, nil)
        }else{
            self.photoCaptureCompletionBlock!(nil, CameraControllerError.unknown)
        }
    }
}



extension CameraController {
    enum CameraControllerError: Swift.Error{
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
}
























