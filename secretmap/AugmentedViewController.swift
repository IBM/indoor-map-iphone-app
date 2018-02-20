//
//  AugmentedViewController.swift
//  secretmap
//
//  Created by Anton McConville on 2018-02-04.
//  Copyright © 2018 Anton McConville. All rights reserved.
//

import UIKit
import Foundation
import ARKit

let kStartingPosition = SCNVector3(0, -1, -3)
let scale = SCNVector3(0.05,0.05,0.05)
let kAnimationDurationMoving: TimeInterval = 0.2
let kMovingLengthPerLoop: CGFloat = 0.05
let kRotationRadianPerLoop: CGFloat = 0.2

class AugmentedViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var pirate = Pirate()
    var ship = Ship()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupConfiguration()
        addPirate()
    }
    
    func addPirate() {
        
        let pirateStartingPosition = SCNVector3(0, -1, -3)
        let pirateScale = SCNVector3(0.1,0.1,0.1)
        
        pirate.loadModel()
        pirate.position = pirateStartingPosition
        pirate.scale = pirateScale
        
        //  pirate.rotation = SCNVector4Zero
        //  pirate.boundingBox = scale
        //  let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
        //  let boxNode = SCNNode(geometry: box)
        //  boxNode.position = SCNVector3(0,0,-0.5)
        //  scene.rootNode.addChildNode(boxNode)
    
//        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        sceneView.scene.rootNode.addChildNode(pirate)
    }
    
    func addShip() {
        
        let shipStartingPosition = SCNVector3(0, -20, -60)
        let shipScale = SCNVector3(50,50,50)
        
        ship.loadModel()
        ship.position = shipStartingPosition
        ship.scale = shipScale
        
        sceneView.scene.rootNode.addChildNode(ship)
    }
    

    func setupScene() {
        let scene = SCNScene()
        sceneView.scene = scene
    }

    func setupConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
}

