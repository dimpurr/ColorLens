//
//  ContentView.swift
//  ColorLens
//
//  Created by Cheny Dimpurr on 2023/8/31.
//

import SwiftUI
import UIKit
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Binding var cameraViewController: CameraViewController
    
    class Coordinator: NSObject, UINavigationControllerDelegate {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIViewController(context: Context) -> CameraViewController {
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        
    }
}


class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var currentCamera: AVCaptureDevice!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 请求相机权限
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
            if granted {
                print("相机权限已授权")
                self.setupCamera()
            } else {
                print("相机权限被拒绝")
                // TODO: 显示提示给用户
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    
    func setupCamera() {
        // 创建捕获会话
        captureSession = AVCaptureSession()
        
        // 设置会话的分辨率
        captureSession.sessionPreset = .hd1920x1080
        
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified).devices
          
          guard !devices.isEmpty else {
              print("没有可用的摄像头")
              // TODO: 显示提示给用户
              return
          }
        
        // 选择第一个可用的摄像头
        currentCamera = devices.first!
        
        do {
            let input = try AVCaptureDeviceInput(device: currentCamera)
            guard captureSession.canAddInput(input) else {
                print("无法添加输入")
                // TODO: 显示提示给用户
                return
            }
            captureSession.addInput(input)
            
            let output = AVCapturePhotoOutput()
            guard captureSession.canAddOutput(output) else {
                print("无法添加输出")
                // TODO: 显示提示给用户
                return
            }
            captureSession.addOutput(output)
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            
            view.layer.addSublayer(previewLayer)
            
            captureSession.startRunning()
        } catch {
            print("设置相机时发生错误: \(error)")
            // TODO: 显示提示给用户
        }
    }
    
    func switchCamera() {
        // 检查captureSession是否存在
        guard let captureSession = captureSession else {
            print("捕获会话不存在")
            // TODO: 显示提示给用户
            return
        }

        // 获取当前输入
        guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else {
            print("无法获取当前输入")
            // TODO: 显示提示给用户
            return
        }
        
        // 获取当前输入
        guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else {
            return
        }
        
        // 获取可用的摄像头
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified).devices
        
        // 检查是否有可用的摄像头
        if devices.isEmpty {
            print("没有可用的摄像头")
            // TODO: 显示提示给用户
            return
        }
        
        // 查找不是当前摄像头的摄像头
        guard let newCamera = devices.first(where: { $0 != currentInput.device }) else {
            return
        }
        
        // 创建新的输入
        var newInput: AVCaptureDeviceInput!
        do {
            newInput = try AVCaptureDeviceInput(device: newCamera)
        } catch let error {
            print("创建输入时发生错误: \(error.localizedDescription)")
            // TODO: 显示提示给用户
            return
        }
        
        // 更新会话
        captureSession.beginConfiguration()
        captureSession.removeInput(currentInput)
        if captureSession.canAddInput(newInput) {
            captureSession.addInput(newInput)
        } else {
            print("无法添加输入")
            // TODO: 显示提示给用户
            captureSession.addInput(currentInput)
        }
        captureSession.commitConfiguration()
    }
}

struct ContentView: View {
    @State private var cameraViewController = CameraViewController()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            CameraView(cameraViewController: $cameraViewController)
            Button(action: {
                self.cameraViewController.switchCamera()
            }) {
                Text("切换摄像头")
            }
        }
        .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
