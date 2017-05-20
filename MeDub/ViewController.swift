//
//  ViewController.swift
//  MeDub
//
//  Created by Mark Rabins on 5/19/17.
//  Copyright © 2017 self.edu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var audioRecordingData = [String: AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        readJson()
    }
    
    func readJson() {
        do {
            if let file = Bundle.main.url(forResource: "quote", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let audioObject = json as? [String: AnyObject] {
                    // json is a dictionary
                    if let name = audioObject["name"] as? String {
                        audioRecordingData["name"] = name as AnyObject

                    }
                    if let url = audioObject["url"] as? String {
                        audioRecordingData["url"] = url as AnyObject


                    }
                    if let waveImage = audioObject["waveform_raw_data"] as? String{
                        audioRecordingData["waveImage"] = waveImage as AnyObject
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

    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toRecordSegue", sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRecordSegue" {
            let navController = segue.destination as! UINavigationController
            let vc = navController.topViewController as! RecordingViewController
            vc.recordingData = audioRecordingData
        }
    }
    

    
    
    
}






