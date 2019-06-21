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
import FirebaseDatabase
import Firebase

// TO DO: add comments, ask different questions for each object, create scrollable bar for objects, debug hit test

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var shipButton: UIButton!
    @IBOutlet weak var dogButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var buildButton: UIButton!
    @IBOutlet weak var answerView: UIView!
    @IBOutlet weak var nextView: UIStackView!
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var labelA: UILabel!
    @IBOutlet weak var labelB: UILabel!
    @IBOutlet weak var labelC: UILabel!
    @IBOutlet weak var labelD: UILabel!
    
    @IBOutlet var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    let roofRef = Database.database().reference()
    
    var questionBranch = "animal"
    var questionID = 0
    var objectScene: String = ""
    var objectNode: String = ""
    var objectSet = Set<String>()
    var isBuilding: Bool = true
    var text = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        // Do any additional setup after loading the view.
        
        // Recognize taps
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
        
        
        // When the hit test is not empty
        if !hitTest.isEmpty {
            let result = hitTest.first!
            let name = result.node.name
            print("tapped \(String(describing: name))")
            
            // In Buiding mode
            if isBuilding{
                createObject(position: hitVector)
            }
            // In Quiz mode
            else if objectSet.contains(name ?? "null") {
                question.isHidden = false
                answerView.isHidden = false
                questionBranch = name!
                generateQuestion()
            }
            // No object tapped
            else {
                question.isHidden = true
                answerView.isHidden = true
                print("not object")
            }
        } else {
            question.isHidden = true
            answerView.isHidden = true
            print("hitTest is empty")
        }
    }
    
    //MARK: Actions
    
    // Goes into quiz mode
    @IBAction func done(_ sender: UIButton) {
        shipButton.isHidden = true
        dogButton.isHidden = true
        resetButton.isHidden = true
        doneButton.isHidden = true
        buildButton.isHidden = false
        
        isBuilding = false
        
        // Comment out later
        question.isHidden = false
        answerView.isHidden = false
        generateQuestion()
    }
    
    // Goes into building mode
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
        objectNode = "animal"
    }
    
    @IBAction func ship(_ sender: UIButton) {
        objectScene = "art.scnassets/ship/ship.scn"
        objectNode = "vehicle"
    }
    
    @IBAction func reset(_ sender: Any) {
        self.resetSession()
    }
    
    @IBAction func answer(_ sender: UIButton) {
        guard let choiceButtonPressed = sender.currentTitle else {return}
        let choiceButton = "choice" + choiceButtonPressed
        let choiceRef = roofRef.child("\(questionBranch)/qn\(questionID)/\(String(describing: choiceButton))")
        choiceRef.observe(.value) { (snap: DataSnapshot) in
            let choice = snap.value as? String
            
            self.answerPressed(choice: choice!)
        }
    }

    @IBAction func next(_ sender: UIButton) {
        
    }
    
    @IBAction func back(_ sender: UIButton) {
    }
    
    //MARK: Functions
    
    func answerPressed(choice: String) {
        
        let answerRef = roofRef.child("\(questionBranch)/qn\(questionID)/answer")
        answerRef.observe(.value) { (snap: DataSnapshot) in
            let answer = snap.value as? String
            
            print("answer is: \(String(describing: snap.value)))")
            
            // Check if answer is correct
            if choice == answer {
                print("Correct!")
                self.resultImage.image = UIImage(named: "C")
            } else {
                print("Wrong answer")
                self.resultImage.image = UIImage(named: "D")
            }
        }
        
        generateQuestion()
    }
    
    func generateQuestion() {
        
        // Need to find a way to enumerate questions
        let numberOfQuestions = 4
        questionID = Int.random(in: 1...numberOfQuestions)
        
        labelTextFromFirebase(key: "question", label: self.question)
        labelTextFromFirebase(key: "choiceA", label: self.labelA)
        labelTextFromFirebase(key: "choiceB", label: self.labelB)
        labelTextFromFirebase(key: "choiceC", label: self.labelC)
        labelTextFromFirebase(key: "choiceD", label: self.labelD)
    }
    
    func labelTextFromFirebase(key: String, label: UILabel) {
        
        let referance = roofRef.child("\(questionBranch)/qn\(questionID)/\(key)")
        referance.observe(.value) { (snap: DataSnapshot) in
            label.text = snap.value as? String
        }
    }
    
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
}

