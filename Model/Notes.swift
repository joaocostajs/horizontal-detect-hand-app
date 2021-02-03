//
//  Notes.swift
//  Augmented Reality systems for educational support
//
//  Created by João Costa on 30/01/2021.
//  Copyright © 2021 João Costa. All rights reserved.
//

import Foundation



import UIKit
import SceneKit
import ARKit
import Vision
import CoreML
import Foundation
import AVFoundation
import AudioToolbox






struct Notes{
    
    
    
    func notesCreator(sceneView: ARSCNView!, playground: SCNScene) -> SCNNode{
        
        var d3 = SCNNode()
        
        d3 = playground.rootNode.childNode(withName: "d3", recursively: true)!
        d3.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.2, chamferRadius: 0) ))
        d3.physicsBody?.categoryBitMask = BitMaskCategory.d3.rawValue
        d3.physicsBody?.contactTestBitMask = BitMaskCategory.finger.rawValue
        sceneView.scene.rootNode.addChildNode(d3)
        d3.opacity = 0.01
        
        
        return d3

    }
   
    
    
    
}
