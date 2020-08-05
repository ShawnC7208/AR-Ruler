//
//  ViewController.swift
//  AR Ruler
//
//  Created by Shawn Chandwani on 8/5/20.
//  Copyright © 2020 Shawn Chandwani. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes.removeAll()
            textNode.removeFromParentNode()
        }
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = hitTestResults.first {
                addDot(hitResult)
            }
        }
    }
    
    func addDot(_ hitResult: ARHitTestResult) {
        let sphere = SCNSphere(radius: 0.002)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        sphere.materials = [material]
        
        let node = SCNNode(geometry: sphere)
        node.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                   hitResult.worldTransform.columns.3.y,
                                   hitResult.worldTransform.columns.3.z)
        
        dotNodes.append(node)
        
        if dotNodes.count >= 2 {
            calculate()
        }
        
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    func calculate() {
        let start = dotNodes[0];
        let end = dotNodes[1];
        
        let distance = sqrt(
                pow(end.position.x - start.position.x, 2) +
                pow(end.position.y - start.position.y, 2) +
                pow(end.position.z - start.position.z, 2)
        )
        updateText("\(distance * 39.37)", end.position)
    }
    
    func updateText(_ distance: String,_ atPosition: SCNVector3) {
        let textGeometry = SCNText(string: "\(distance) in", extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.yellow
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(atPosition.x, atPosition.y + 0.01, atPosition.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
