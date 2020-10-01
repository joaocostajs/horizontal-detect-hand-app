//
//  TouchManager.swift
//  Hand Interactive AR Playground
//
//  Created by João Costa on 09/06/2020.
//  Copyright © 2020 João Costa. All rights reserved.
//

import Foundation
import ARKit
import AVFoundation

var player: AVAudioPlayer?

struct TouchManager{
    var contact = false
    var buttonState = false
    mutating func touchBegan(nodeA:SCNNode, nodeB:SCNNode, physicsWorld:SCNPhysicsWorld){
        
        let physics = physicsWorld
        let checked =  physics.contactTestBetween(nodeA.physicsBody!, nodeB.physicsBody!,
                                                  options: nil)
        if checked == [] {
            print(checked)
            buttonState = true
        }else{
            print("on")
            contact = true
            if buttonState == true{
                if (nodeB.name == "Sphere"){
                    playSound(sound: "d3")
                }
              
                if (nodeB.name == "a3" || nodeB.name == "bb3" || nodeB.name == "c3" || nodeB.name == "d3" || nodeB.name == "e3" || nodeB.name == "f3" || nodeB.name == "g3"){
                    playSound(sound: nodeB.name!)
                }
                buttonState = false
            }
        }
    }
    
    let connectQueue = DispatchQueue(label: "connectQueue", attributes: .concurrent)//This creates a concurrent Queue

    func  playSound(sound:String) {
         connectQueue.sync {
        guard let url = Bundle.main.url(forResource: sound, withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }
            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
        }
    }
    
    
    
   

    
}


//#colorLiteral(red: 0, green: 0.007843137254, blue: 1, alpha: 1)
