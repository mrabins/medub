//
//  AudioDataModel.swift
//  MeDub
//
//  Created by Mark Rabins on 5/19/17.
//  Copyright © 2017 self.edu. All rights reserved.
//

import Foundation

struct RecordingInformation {
    var url: String
    var name: String
    var waveImage: String
    
    init(url: String, name: String, waveImage: String) {
        self.url = url
        self.name = name
        self.waveImage = waveImage
    }
    
}

