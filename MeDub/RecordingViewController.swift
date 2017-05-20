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

class RecordingViewController: UIViewController {
    
    var recordingData = [String:AnyObject]()
    var audioPlayer = AVAudioPlayer()
    let frontCameraController = UIImagePickerController()
    
    @IBOutlet weak var progressBar: UIImageView!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        playAudio()
        startCameraFromViewController(viewController: self, withDelegate: self)

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        print("RECORD \(recordingData)")
        
        self.navigationItem.title = recordingData["name"] as? String
        
        let navigationItemCustomFont = UIFont(name: "Helvetica Neue", size: 20)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: navigationItemCustomFont!]
        
        let imageURL = recordingData["waveImage"] as! String
        
        if let decodedData = Data(base64Encoded: imageURL, options: .ignoreUnknownCharacters) {
            let decImage = UIImage(data: decodedData)
            progressBar.image = decImage
        }
        
    }
    
    func playAudio() {
        let fileUrl: NSURL = NSURL(string: recordingData["url"] as! String)!
        
        print("FILEURL \(fileUrl)")
        
        let soundData = NSData(contentsOf: fileUrl as URL)
        
        do {
            audioPlayer = try AVAudioPlayer(data: soundData! as Data)
        } catch {
            print("something bad happned")
        }
        audioPlayer.delegate = self as? AVAudioPlayerDelegate
        audioPlayer.prepareToPlay()
        audioPlayer.numberOfLoops = -1
        audioPlayer.play()

    }

}


// MARK: UIImagePickerControllerDelegate

extension RecordingViewController: UIImagePickerControllerDelegate {
    
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let recordedVideo = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        
        // Video Recording Logic
        if recordedVideo == kUTTypeVideo {
            guard let videoPath = (info[UIImagePickerControllerMediaURL] as! NSURL).path else { return }
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath) {
                UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, #selector(RecordingViewController.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
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
        let audioDuractionInSeconds = CMTimeGetSeconds(audioDuration)
        
        frontCameraController.sourceType = .camera
        frontCameraController.cameraDevice = .front
        frontCameraController.mediaTypes = [kUTTypeMovie as NSString as String]
        frontCameraController.allowsEditing = false
        frontCameraController.delegate = delegate
        frontCameraController.startVideoCapture()
        frontCameraController.videoMaximumDuration = audioDuractionInSeconds
        
        frontCameraController.videoMaximumDuration = audioDuractionInSeconds
        
        present(frontCameraController, animated: true, completion: nil)
        return true
    }

}
