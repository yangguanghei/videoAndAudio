//
//  ViewController.swift
//  0.音视频的采集
//
//  Created by 梁森 on 2020/5/28.
//  Copyright © 2020 梁森. All rights reserved.
//

import UIKit

import AVFoundation

class ViewController: UIViewController {

    let session:AVCaptureSession = AVCaptureSession()
    fileprivate var videoOutput:AVCaptureVideoDataOutput?
    fileprivate var audioOutput:AVCaptureAudioDataOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        initVideoAndAudio()
    }


}

extension ViewController{
    fileprivate func setupUI(){
        view.backgroundColor = .green
        let leftBtn = UIButton(frame: CGRect(x: 50, y: 100, width: 80, height: 30))
        leftBtn.setTitle("开始", for: .normal)
        leftBtn.addTarget(self, action: #selector(start), for: .touchUpInside)
        view.addSubview(leftBtn)
        
        let rightBtn = UIButton(frame: CGRect(x: 150, y: 100, width: 80, height: 30))
        rightBtn.setTitle("结束", for: .normal)
        rightBtn.addTarget(self, action: #selector(end), for: .touchUpInside)
        view.addSubview(rightBtn)
        
    }
    
    @objc fileprivate func start(){
        session.startRunning()
    }
    @objc fileprivate func end(){
        session.stopRunning()
    }
}

extension ViewController{
    fileprivate func initVideoAndAudio(){
        setupVideoInputOutput()
        setupAudioInputOutput()
        setupVideoPreview()
    }
    // 视频的输入输出
    fileprivate func setupVideoInputOutput(){
        // 输入
        guard let devices = AVCaptureDevice.devices() as? [AVCaptureDevice] else { return }
        guard let device = devices.filter( {$0.position == .front} ).first else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        // 输出
        let output = AVCaptureVideoDataOutput()
        let queue = DispatchQueue.global()
        output.setSampleBufferDelegate(self, queue: queue)
        self.videoOutput = output
        // 添加输入输出
        session.beginConfiguration()
        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(output){
            session.addOutput(output)
        }
        session.commitConfiguration()
    }
    // 音频的输入输出
    fileprivate func setupAudioInputOutput(){
        // 输入
        guard let device = AVCaptureDevice.default(for: AVMediaType.audio) else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        // 输出
        let output = AVCaptureAudioDataOutput()
        let queue = DispatchQueue.global()
        output.setSampleBufferDelegate(self, queue: queue)
        self.audioOutput = output
        // 添加输入、输出
        session.beginConfiguration()
        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(output){
            session.addOutput(output)
        }
        session.commitConfiguration()
    }
    // 视频的预览
    fileprivate func setupVideoPreview(){
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        self.view.layer.addSublayer(previewLayer)
    }
}

extension ViewController:AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate{
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if videoOutput?.connection(with: .video) == connection {
            print("采集视频数据...")
        }else{
            print("采集音频数据...")
        }
    }
}
