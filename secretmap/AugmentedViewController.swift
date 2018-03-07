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
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var pirate = Pirate()
    var ship = Ship()
    var treasure = Treasure()
    var zone:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let themeColor = UIColor.init(red: 0.16078431372549018, green:0.66666666666666663, blue: 0.76078431372549016, alpha:1 )
        let statusBar = UIView(frame: CGRect(x:0, y:0, width:view.frame.width, height:UIApplication.shared.statusBarFrame.height))
        statusBar.backgroundColor = themeColor
        statusBar.tintColor = themeColor
        view.addSubview(statusBar)
        setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupConfiguration()
        
        if self.zone == 7{
            addPirate()
        }
        
        if self.zone == 3{
            addTreasure()
        }
    }
    
    func addPirate() {
        
        let pirateStartingPosition = SCNVector3(0, -5, -6)
        let pirateScale = SCNVector3(0.35,0.35,0.35)
        
        pirate.loadModel()
        pirate.position = pirateStartingPosition
        pirate.scale = pirateScale
    
        sceneView.scene.rootNode.addChildNode(pirate)
    }
    
    func addTreasure() {
        
        let pirateStartingPosition = SCNVector3(0, -2, -2)
        
        treasure.loadModel()
        treasure.position = pirateStartingPosition
        
        sceneView.scene.rootNode.addChildNode(treasure)
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
