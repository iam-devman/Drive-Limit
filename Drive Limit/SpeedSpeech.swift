//
//  SpeedSpeech.swift
//  Drive Limit
//
//  Created by Alexander Torres on 6/4/23.
//

import Foundation
import AVFoundation

let speechSynthesizer = AVSpeechSynthesizer()
let speechQueue = DispatchQueue(label: "com.example.app.speech", qos: .background)

func speakSpeedLimitExceeded() {
    speechQueue.async {
        let speechUtterance = AVSpeechUtterance(string: "You are exceeding the speed limit")
        speechSynthesizer.speak(speechUtterance)
        print("Done speaking")
    }
}
