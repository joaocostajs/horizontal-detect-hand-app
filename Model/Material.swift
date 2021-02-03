//
//  Material.swift
//  Augmented Reality systems for educational support
//
//  Created by João Costa on 30/01/2021.
//  Copyright © 2021 João Costa. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit

struct Material {
    
    func createMaterial(helpers: Helpers) -> SCNMaterial{
        let reflectiveMaterial = SCNMaterial()
        reflectiveMaterial.lightingModel = .physicallyBased
        reflectiveMaterial.metalness.contents = 1.0
        reflectiveMaterial.diffuse.contents  = helpers.colors[Int.random(in:1...helpers.colors.count - 1)]
        reflectiveMaterial.roughness.contents = 0
       
        return reflectiveMaterial
    }
    
}
