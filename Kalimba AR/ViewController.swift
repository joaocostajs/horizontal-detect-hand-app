//
//  ViewController.swift
//  Kalimba AR
//
//  Created by João Costa on 08/06/2020.
//  Copyright © 2020 João Costa. All rights reserved.
//



// nesta app o objetivo é colocar objetos em superficies horizontais e permitir aos users tocar com as maos, acho que sera mais facil do que quando os objetos estao a flutuar no ar

// escrever um algoritmo para saber a distancia do dedo para um objeto (funçao ja ta iniciada chamasse loop())
// depois para varios objetos




import UIKit
import SceneKit
import ARKit
import Vision
import CoreML
import Foundation
import AVFoundation
import AudioToolbox


enum BitMaskCategory: Int {
    case finger = 4
    case button = 8
    case box1 = 10
    case pyra = 2
    case C = 3
    case d3 = 5
    case e3 = 6
    case f3 = 7
    case g3 = 9
    case a3 = 11
    case bb3 = 13
}

class ViewController: UIViewController, ARSCNViewDelegate,SCNSceneRendererDelegate, ARSessionDelegate,AVCaptureVideoDataOutputSampleBufferDelegate, SCNPhysicsContactDelegate{
    
    @IBOutlet var movementLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var sceneView: ARSCNView!
    var index = 0
    var helpers = Helpers()
    var boxDebug = Box()
    let nodes = Nodes()
    var touchmanager = TouchManager()
    let playground = SCNScene(named: "art.scnassets/playground.scn")!
    
    var startButton:SCNNode = SCNNode()
    
    var bNode = SCNNode()
    var C = SCNNode()
    var d3 = SCNNode()
    var e3 = SCNNode()
    var f3 = SCNNode()
    var g3 = SCNNode()
    var a3 = SCNNode()
    var bb3 = SCNNode()
    
    var wrapper = SCNNode()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
//        sceneView.debugOptions = .showPhysicsShapes
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.scene.physicsWorld.timeStep = 1/60
//        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
       
        
         var detectionTimer = Timer.scheduledTimer(timeInterval: 0.0166, target: self, selector: #selector(ViewController.startDetection), userInfo: nil, repeats: true)
        
        
        startButton = playground.rootNode.childNode(withName: "startButton", recursively: true)!
        startButton.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNBox(width: 0.4 , height: 0.4, length: 0.2, chamferRadius: 0)))
        startButton.physicsBody?.categoryBitMask = BitMaskCategory.button.rawValue
        startButton.physicsBody?.contactTestBitMask = BitMaskCategory.finger.rawValue
        sceneView.scene.rootNode.addChildNode( startButton)
        
     
     
//        C = playground.rootNode.childNode(withName: "c3", recursively: true)!
//             C.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.2, chamferRadius: 0) ))
//             C.physicsBody?.categoryBitMask = BitMaskCategory.C.rawValue
//             C.physicsBody?.contactTestBitMask = BitMaskCategory.finger.rawValue
//             sceneView.scene.rootNode.addChildNode(C)
//
        d3 = playground.rootNode.childNode(withName: "d3", recursively: true)!
        d3.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.2, chamferRadius: 0) ))
        d3.physicsBody?.categoryBitMask = BitMaskCategory.d3.rawValue
        d3.physicsBody?.contactTestBitMask = BitMaskCategory.finger.rawValue
        sceneView.scene.rootNode.addChildNode(d3)


        bNode = d3
        sceneView.scene.rootNode.addChildNode(bNode)
        
        
        
        
        nodes.caixa.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNBox(width: 0.02, height: 0.02, length: 0.02, chamferRadius: 0.01)))
        nodes.caixa.physicsBody?.categoryBitMask = BitMaskCategory.finger.rawValue
        nodes.caixa.physicsBody?.contactTestBitMask = BitMaskCategory.button.rawValue
        nodes.caixa.name = "Finger"
        
        
      
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first{
                
                let sphereSize = 0.07
                
                let sphereNode = SCNNode(geometry: SCNSphere(radius: CGFloat(sphereSize)))
               
                
                // Create material for sphere
                let reflectiveMaterial = SCNMaterial()
                reflectiveMaterial.lightingModel = .physicallyBased
                reflectiveMaterial.metalness.contents = 1.0
                reflectiveMaterial.diffuse.contents  = self.helpers.colors[Int.random(in:1...self.helpers.colors.count - 1)]
                reflectiveMaterial.roughness.contents = 0
                sphereNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x,
                                                 y:hitResult.worldTransform.columns.3.y + Float(sphereSize),
                                                 z:hitResult.worldTransform.columns.3.z )
                                                                 
                sphereNode.geometry?.firstMaterial = reflectiveMaterial
                sphereNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNSphere(radius: 0.07)))
                sphereNode.physicsBody?.categoryBitMask = BitMaskCategory.d3.rawValue
                sphereNode.physicsBody?.contactTestBitMask = BitMaskCategory.finger.rawValue
                sphereNode.name = "Sphere"
                
                
                sceneView.scene.rootNode.addChildNode(sphereNode)
                
              
            }
           
            
        }
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2 , 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            planeNode.opacity = 0.3
            
            node.addChildNode(planeNode)

        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // We want to receive the frames from the video
        sceneView.session.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        // Run the view's session
        sceneView.session.run(configuration)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.togglePeopleOcclusion()
        })
        
            self.sceneView.scene.rootNode.addChildNode(nodes.caixa)
              
              var smallestDistance:Double = helpers.calculateDistance(finger: nodes.caixa, closestNode: self.sceneView.scene.rootNode.childNodes[1])
              
              let allNodes = self.sceneView.scene.rootNode.childNodes
//            var finalDistance = helpers.getClosestNode(allNodes:allNodes, smallestDistance: smallestDistance)
//        print(finalDistance, "finalDistance")
        
        func loop(){
            for node in allNodes {
                               if (helpers.calculateDistance(finger: nodes.caixa, closestNode: node) < smallestDistance && helpers.calculateDistance(finger: nodes.caixa, closestNode: node) != 0 ){
                                   smallestDistance = helpers.calculateDistance(finger: nodes.caixa, closestNode: node)
                               }
                         }

            print("acabou", smallestDistance)
        }

        loop()
             
        
       
    }
    fileprivate func togglePeopleOcclusion() {
          guard let config = sceneView.session.configuration as? ARWorldTrackingConfiguration else {
              fatalError("Unexpectedly failed to get the configuration.")
          }
          guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
              fatalError("People occlusion is not supported on this device.")
          }
          switch config.frameSemantics {
          case [.personSegmentationWithDepth]:
              config.frameSemantics.remove(.personSegmentationWithDepth)
              
          default:
              config.frameSemantics.insert(.personSegmentationWithDepth)
              
          }
          sceneView.session.run(config)

        
      }
    
//    var bNodeBool = false
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        
        if contact.nodeA.physicsBody?.categoryBitMask == 4 {
            bNode = contact.nodeB
        }else {
            bNode = contact.nodeA
        }
    }

      var eulerX:Float = 0
    var eulerY:Float = 0
    var currentBuffer: CVPixelBuffer?
    
//    https://stackoverflow.com/questions/45084187/arkit-get-current-position-of-arcamera-in-a-scene
    
    
    func session(_: ARSession, didUpdate frame: ARFrame) {
        eulerY = frame.camera.eulerAngles.y * -1
        eulerX = frame.camera.eulerAngles.x
        currentBuffer = frame.capturedImage
        
       
//        startDetection()
    }
    
 
    let visionQueue = DispatchQueue(label: "joao.visionQueue")
    
    private lazy var predictionRequest: VNCoreMLRequest = {
        // Load the ML model through its generated class and create a Vision request for it.
        do {
            let model = try VNCoreMLModel(for: Hand().model)
            let request = VNCoreMLRequest(model: model)
            
            // This setting determines if images are scaled or cropped to fit our 224x224 input size. Here we try scaleFill so we don't cut part of the image.
            request.imageCropAndScaleOption = .scaleFill
            
            return request
        } catch {
            fatalError("can't load Vision ML model: \(error)")
        }
    }()
    
    var obs:AnyObject?

    @objc private func startDetection() {
            // Here we will do our CoreML request on currentBuffer
            
            guard let buffer = currentBuffer else { return }
         
            // Right orientation because the pixel data for image captured by an iOS device is encoded in the camera sensor's native landscape orientation
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .right)
           
            // We perform our CoreML Requests asynchronously.
            visionQueue.async {
                // Run our CoreML Request
                try? requestHandler.perform([self.predictionRequest])
                
                guard let results = self.predictionRequest.results else {
                    fatalError("Unexpected result type from VNCoreMLRequest")
                }
               
                DispatchQueue.main.async {
                    for observation in results where observation is VNRecognizedObjectObservation {
                        guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                            continue
                        }
                        let topLabelObservation = objectObservation.labels[0].identifier
                        let confidence = objectObservation.confidence
                        if confidence > 0.65 {
                             if topLabelObservation == "Index" {
                    //                            este f value nao esta correto mas assim a app funciona bem
                                                let f = 8.25
                                                let resY = self.view.frame.height
                                                let sensorSizeX = 5.76
                                                
                                                self.obs = objectObservation
                                                let rect = objectObservation.boundingBox
                                                
                                                self.boxDebug.MakeBox()
                                                let debugBoxPosition = self.helpers.DebugBoxPosition(rect: rect, VC:self)
                                                self.boxDebug.redView.frame = CGRect(x:debugBoxPosition.minX, y: debugBoxPosition.minY, width: debugBoxPosition.width, height: debugBoxPosition.height)
                                                self.view.addSubview(self.boxDebug.redView)
                                                
                                                let depth = self.helpers.getDepth(heightOfObject: 35.0, focal: f, h: debugBoxPosition.height, resY: resY, sensorSizeX: sensorSizeX)
                                                let translate = self.helpers.getTranslation(x: self.sceneView.pointOfView!.position.x, y: self.sceneView.pointOfView!.position.y, z: self.sceneView.pointOfView!.position.z)
                                                
                                                let X = self.helpers.findX(x:debugBoxPosition.minX, width:debugBoxPosition.width, depth:depth,VC:self)
                                                let Y = self.helpers.findY(y:debugBoxPosition.minY, height:debugBoxPosition.height, depth:depth,VC:self)
                                                
                                                let rotatedPoint = self.helpers.rotatePoint(X: X,Y: Y,depth: depth,eulerX: self.eulerX,eulerY: self.eulerY)
                                                let join = SCNVector3(rotatedPoint.x + translate.x,rotatedPoint.y + translate.y,rotatedPoint.z + translate.z)

                                                self.nodes.caixa.geometry?.firstMaterial?.diffuse.contents = self.helpers.getColor()
                                                self.nodes.caixa.position = SCNVector3(join.x, join.y, join.z)
                                
                                
                                
                                
                                                let snake = SCNNode(geometry: SCNBox(width: 0.02, height: 0.02, length: 0.02, chamferRadius: 0.01))
                                                    snake.geometry?.firstMaterial?.diffuse.contents = self.helpers.getColor()
                                                    snake.position = SCNVector3(join.x, join.y, join.z)
                                                    self.sceneView.scene.rootNode.addChildNode(snake)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                                                    snake.removeFromParentNode()
                                                })
                                
                                                self.sceneView.scene.rootNode.addChildNode(self.nodes.caixa)
                                                
                                                self.touchmanager.touchBegan(nodeA: self.nodes.caixa, nodeB: self.bNode, physicsWorld: self.sceneView.scene.physicsWorld)
                                            }
                        }
                    }
                }
                // Release currentBuffer to allow processing next frame
                self.currentBuffer = nil
                
            }
      
        }
    
  
}


