//
//  ViewController.swift
//  BuildAR
//
//  Created by Tay Jin Wen on 5/6/19.
//  Copyright © 2019 Tay Jin Wen. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

// TO DO: add comments, ask different questions for each object, create scrollable bar for objects, debug hit test

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var shipButton: UIButton!
    @IBOutlet weak var dogButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var buildButton: UIButton!
    @IBOutlet weak var answerView: UIView!
    @IBOutlet var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    var objectScene: String = ""
    var objectNode: String = ""
    var objectSet = Set<String>()
    var isBuilding: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        // Do any additional setup after loading the view.
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        let tappedView = sender.view as! SCNView
        let touchLocation = sender.location(in: tappedView)
        let hitTest = tappedView.hitTest(touchLocation, options: nil)
        
        let result = sceneView.hitTest(touchLocation, types: ARHitTestResult.ResultType.estimatedHorizontalPlane)
        guard let hitResult = result.last else {
            return
        }
        let hitTransform = hitResult.worldTransform
        let hitMat = SCNMatrix4(hitTransform)
        let hitVector = SCNVector3Make(hitMat.m41, hitMat.m42, hitMat.m43)
        
        
        if !hitTest.isEmpty {
            let result = hitTest.first!
            let name = result.node.name
            print("tapped \(String(describing: name))")
            
            if isBuilding{
                createObject(position: hitVector)
            } else if objectSet.contains(name ?? "null") {
                question.isHidden = false
                answerView.isHidden = false
            } else {
                print("not object")
            }
        } else {
            print("hitTest is empty")
        }
    }
    
    //MARK: Actions
    
    @IBAction func done(_ sender: UIButton) {
        shipButton.isHidden = true
        dogButton.isHidden = true
        resetButton.isHidden = true
        doneButton.isHidden = true
        buildButton.isHidden = false
        
        isBuilding = false
    }
    
    @IBAction func build(_ sender: UIButton) {
        shipButton.isHidden = false
        dogButton.isHidden = false
        resetButton.isHidden = false
        doneButton.isHidden = false
        buildButton.isHidden = true
        question.isHidden = true
        answerView.isHidden = true
        
        isBuilding = true
    }
    
    @IBAction func dog(_ sender: UIButton) {
        objectScene = "art.scnassets/beagle/Mesh_Beagle.scn"
        objectNode = "Beagle"
    }
    
    @IBAction func ship(_ sender: UIButton) {
        objectScene = "art.scnassets/ship/ship.scn"
        objectNode = "shipMesh"
    }
    
    @IBAction func reset(_ sender: Any) {
        self.resetSession()
    }
    
    @IBAction func answered(_ sender: UIButton) {
        question.isHidden = true
        answerView.isHidden = true
    }
    
    //MARK: Functions
    
    func createObject(position: SCNVector3) {
        
        guard let createScene = SCNScene(named: objectScene) else {
            return
        }
        guard let createNode = createScene.rootNode.childNode(withName: objectNode, recursively: true) else {
            return
        }
        createNode.position = position
        sceneView.scene.rootNode.addChildNode(createNode)
        objectSet.insert(objectNode)
    }
    
    func resetSession() {
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
}

