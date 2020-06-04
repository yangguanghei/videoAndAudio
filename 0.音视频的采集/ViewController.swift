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
    fileprivate var videoInput:AVCaptureDeviceInput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        initVideoAndAudio()
    }

    lazy var previewLayer:AVCaptureVideoPreviewLayer = {[weak self] in
        let previewLayer = AVCaptureVideoPreviewLayer(session: self!.session)
        previewLayer.frame = view.bounds
        return previewLayer
    }()
    lazy var movieOutput:AVCaptureMovieFileOutput = {
        let movieOutput = AVCaptureMovieFileOutput()
        let connection = movieOutput.connection(with: .video)
        connection?.automaticallyAdjustsVideoMirroring = true
        return movieOutput
    }()
}

extension ViewController{
    fileprivate func setupUI(){
        view.backgroundColor = .green
        let leftBtn = UIButton(frame: CGRect(x: 50, y: 100, width: 80, height: 30))
        leftBtn.setTitle("开始", for: .normal)
        leftBtn.addTarget(self, action: #selector(start), for: .touchUpInside)
        leftBtn.backgroundColor = .red
        view.addSubview(leftBtn)
        
        let rightBtn = UIButton(frame: CGRect(x: 150, y: 100, width: 80, height: 30))
        rightBtn.setTitle("结束", for: .normal)
        rightBtn.addTarget(self, action: #selector(end), for: .touchUpInside)
        rightBtn.backgroundColor = .red
        view.addSubview(rightBtn)
        
        let switchBtn = UIButton(frame: CGRect(x: 50, y: 150, width: 100, height: 30))
        switchBtn.setTitle("切换摄像头", for: .normal)
        switchBtn.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        switchBtn.backgroundColor = .red
        view.addSubview(switchBtn)
        
        
    }
    
    @objc fileprivate func start(){
        session.startRunning()
        self.view.layer.insertSublayer(previewLayer, at: 0)
        startRecord()
    }
    @objc fileprivate func end(){
        session.stopRunning()
        self.previewLayer.removeFromSuperlayer()
        movieOutput.stopRecording()
    }
    
    // 切换摄像头
    @objc fileprivate func switchCamera(){
        guard let videoInput = videoInput else { return }
        
        let position:AVCaptureDevice.Position = videoInput.device.position == AVCaptureDevice.Position.front ? .back : .front
        guard let devices = AVCaptureDevice.devices() as? [AVCaptureDevice] else { return }
        guard let device = devices.filter( {$0.position == position} ).first else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        session.beginConfiguration()
        session.removeInput(videoInput)
        if session.canAddInput(input) {
            session.addInput(input)
        }
        session.commitConfiguration()
        self.videoInput = input
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
        videoInput = input
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
        
    }
    
    // 录制视频
    fileprivate func startRecord(){
        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        }
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/1.mp4"
        let url = URL(fileURLWithPath: path)
        movieOutput.startRecording(to: url, recordingDelegate: self)
    }
}

extension ViewController:AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate{
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if videoOutput?.connection(with: .video) == connection {
            print("采集视频数据...")
        }else if audioOutput?.connection(with: .audio) == connection{
            print("采集音频数据...")
        }
    }
}

extension ViewController:AVCaptureFileOutputRecordingDelegate{
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("开始写入文件")
    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("结束写入文件")
    }
    
}
