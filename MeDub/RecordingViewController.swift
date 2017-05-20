//
//  RecordingViewController.swift
//  MeDub
//
//  Created by Mark Rabins on 5/19/17.
//  Copyright © 2017 self.edu. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController {
    
    var recordingData = [String:AnyObject]()
    
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        print("RECORD \(recordingData)")
        
        self.navigationItem.title = recordingData["name"] as? String
        
        let navigationItemCustomFont = UIFont(name: "Helvetica Neue", size: 20)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: navigationItemCustomFont!]
        
        
        
    }
    
    func playAudio() {
        let fileUrl: NSURL = NSURL(string: recordingData["url"] as! String)!
        let soundData = NSData(contentsOf: fileUrl as URL)
        
        do {
            audioPlayer = try AVAudioPlayer(data: soundData! as Data)
        } catch {
            print("something bad happned")
        }
        audioPlayer.delegate = self as? AVAudioPlayerDelegate
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        

    }
    
 
@IBAction func recordButtonPressed(_ sender: UIButton) {
    
    playAudio()
    
    }


}
