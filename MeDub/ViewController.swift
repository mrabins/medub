//
//  ViewController.swift
//  MeDub
//
//  Created by Mark Rabins on 5/19/17.
//  Copyright © 2017 self.edu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var audioRecordingData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        readJson()
    }

    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toRecordSegue", sender: audioRecordingData)
    }
    
    
    func readJson() {
        do {
            if let file = Bundle.main.url(forResource: "quote", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let audioObject = json as? [String: AnyObject] {
                    // json is a dictionary
                    if let name = audioObject["name"] as? String {
                        audioRecordingData.append(name)
                    }
                    if let url = audioObject["url"] as? String {
                        audioRecordingData.append(url)
                    }
                    if let waveImage = audioObject["waveform_raw_data"] as? String{
                        audioRecordingData.append(waveImage)
                        print("IAMADUI \(audioRecordingData)")
                    }
                } else if let audioObject = json as? [AnyObject] {
                    // json is an array
                    print(audioObject)
                } else {
                    print("JSON is invalid")
                }
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}






