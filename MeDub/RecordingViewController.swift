//
//  RecordingViewController.swift
//  MeDub
//
//  Created by Mark Rabins on 5/19/17.
//  Copyright © 2017 self.edu. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import MediaPlayer
import AVKit
import AssetsLibrary


class RecordingViewController: UIViewController {
    
    var recordingData = [String:AnyObject]()
    var audioPlayer = AVAudioPlayer()
    var player: AVPlayer!
    let frontCameraController = UIImagePickerController()
    
    @IBOutlet weak var progressBar: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        startCameraFromViewController(viewController: self, withDelegate: self)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = recordingData["name"] as? String
        let navigationItemCustomFont = UIFont(name: "Helvetica Neue", size: 20)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: navigationItemCustomFont!]
        
        let imageURL = recordingData["waveImage"] as! String
        
        print("imageURL \(imageURL)")
        
        
    }
    
    func playAudio() {
        let fileUrl = NSURL(string: recordingData["url"] as! String)!
        
        let url = fileUrl
        let file = try! AVAudioFile(forReading: url as URL)
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)
        print(file.fileFormat.channelCount)
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(file.length))
        try! file.read(into: buf)
        
        readFile.waveArrayOfFloatValues = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
        
        print("FILEURL \(fileUrl)")
        
        let soundData = NSData(contentsOf: fileUrl as URL)
        
        do {
            audioPlayer = try AVAudioPlayer(data: soundData! as Data)
        } catch {
            print("something bad happned")
        }
        audioPlayer.delegate = self as? AVAudioPlayerDelegate
        audioPlayer.prepareToPlay()
        //        audioPlayer.numberOfLoops = -1
        audioPlayer.play()
        
    }

    func startMediaBrowserFromViewController(viewController: UIViewController, usingDelegate delegate: protocol<UINavigationControllerDelegate, UIImagePickerControllerDelegate>) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
            return false
        }
        let mediaInterface = UIImagePickerController()
        mediaInterface.sourceType = .savedPhotosAlbum
        mediaInterface.mediaTypes = [kUTTypeMovie as NSString as String]
        mediaInterface.allowsEditing = false
        mediaInterface.delegate = delegate
        
        present(mediaInterface, animated: true, completion: nil)
        
        return true
        
    }
    
    func mergeFilesWithUrl(videoUrl:NSURL, audioUrl:NSURL)
    {
        let mixComposition : AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack : [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack : [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        
        
        //start merge
        let aVideoAsset = AVAsset(url: videoUrl as URL)
        let aAudioAsset = AVAsset(url: audioUrl as URL)
        
        
        mutableCompositionVideoTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid))
        mutableCompositionAudioTrack.append( mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid))
        
        let aVideoAssetTrack : AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaTypeVideo)[0]
        let aAudioAssetTrack : AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaTypeAudio)[0]
        
        
        
        do{
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: kCMTimeZero)
            
            //In my case my audio file is longer then video file so i took videoAsset duration
            //instead of audioAsset duration
            
            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: kCMTimeZero)
            
            //Use this instead above line if your audiofile and video file's playing durations are same
            
            //            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), ofTrack: aAudioAssetTrack, atTime: kCMTimeZero)
            
        }catch{
            
        }
        
        totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero,aVideoAssetTrack.timeRange.duration )
        
        let mutableVideoComposition : AVMutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(1, 30)
        
        mutableVideoComposition.renderSize = CGSize(width: 1280, height: 720)
        
        
        //find your video on this URl
        let savePathUrl : NSURL = NSURL(fileURLWithPath: NSHomeDirectory() + "/Documents/newVideo.mp4")
        
        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        assetExport.outputFileType = AVFileTypeMPEG4
        assetExport.outputURL = savePathUrl as URL
        assetExport.shouldOptimizeForNetworkUse = true
        
        assetExport.exportAsynchronously { () -> Void in
            switch assetExport.status {
                
            case AVAssetExportSessionStatus.completed:
                
                //Uncomment this if u want to store your video in asset
                
                //let assetsLib = ALAssetsLibrary()
                //assetsLib.writeVideoAtPathToSavedPhotosAlbum(savePathUrl, completionBlock: nil)
                
                print("success")
            case  AVAssetExportSessionStatus.failed:
                print("failed \(assetExport.error)")
            case AVAssetExportSessionStatus.cancelled:
                print("cancelled \(assetExport.error)")
            default:
                print("complete")
            }
        }
        
        
    }
}





// MARK: UIImagePickerControllerDelegate

extension RecordingViewController: UIImagePickerControllerDelegate {
    
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let recordedVideo = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        
        // Video Recording Logic
        if recordedVideo == kUTTypeMPEG4 {
            guard let videoPath = (info[UIImagePickerControllerMediaURL] as! NSURL).path else { return }
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath) {
                UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, #selector(RecordingViewController.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
                print("recorded vdeio \(videoPath)")
            }
        }
    }
    
    
    func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        
        if let error = error {
            print("Error... \(error.debugDescription)")
        } else {
            print("The Video saved properly")
        }
    }
}

// MARK: UINavigationControllerDelegate
extension RecordingViewController: UINavigationControllerDelegate {
    
    func startCameraFromViewController(viewController: UIViewController, withDelegate delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            return false
        }
        
        // Calculate the duration of the audio file
        let fileUrl: NSURL = NSURL(string: recordingData["url"] as! String)!
        let soundByte = AVURLAsset(url: fileUrl as URL)
        let audioDuration = soundByte.duration
        let audioDurationInSeconds = CMTimeGetSeconds(audioDuration)
        
        frontCameraController.sourceType = .camera
        frontCameraController.cameraDevice = .front
        frontCameraController.mediaTypes = [kUTTypeMovie as NSString as String]
        frontCameraController.allowsEditing = false
        frontCameraController.delegate = delegate
        frontCameraController.startVideoCapture()
        
        if frontCameraController.videoMaximumDuration == audioDurationInSeconds {
            self.frontCameraController.stopVideoCapture()
        }
        
        
        /*
         
         let videoUrl : NSURL =  NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("SampleVideo", ofType: "mp4")!)
         let audioUrl : NSURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("SampleAudio", ofType: "mp3")!)
         
         mergeFilesWithUrl(videoUrl, audioUrl: audioUrl)
         
         */
        
        
        
        //        frontCameraController.videoMaximumDuration = audioDurationInSeconds
        
        
        present(frontCameraController, animated: true, completion: frontCameraController.stopVideoCapture)
        
        return true
    }
    
}
