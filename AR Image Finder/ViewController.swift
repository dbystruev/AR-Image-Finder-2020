//
//  ViewController.swift
//  AR Image Finder
//
//  Created by Denis Bystruev on 24.09.2020.
//

import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let videoPlayer: AVPlayer = {
        let url = Bundle.main.url(forResource: "rub",
                                  withExtension: "mp4",
                                  subdirectory: "art.scnassets")!
        return AVPlayer(url: url)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        // Detect images
        configuration.maximumNumberOfTrackedImages = 2
        configuration.trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)!
        
        // Detect planes
//        configuration.planeDetection = [.horizontal]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        switch anchor {
        case let imageAnchor as ARImageAnchor:
            nodeAdded(node, for: imageAnchor)
        case let planeAnchor as ARPlaneAnchor:
            nodeAdded(node, for: planeAnchor)
        default:
            print(#line, #function, "Unknown anchor has been discovered")
        }
    }
    
    func nodeAdded(_ node: SCNNode, for imageAnchor: ARImageAnchor) {
        // Get image size
        let image = imageAnchor.referenceImage
        let size = image.physicalSize
        
        // Create plane of the same size
        let height = 69 / 65 * size.height
        let width = image.name == "horses" ?
            157 / 150 * 15 / 8.1231 * size.width :
            157 / 150 * 15 / 5.7514 * size.width
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial?.diffuse.contents = image.name == "horses" ?
            UIImage(named: "monument") :
            videoPlayer
        
        if image.name == "horses" {
            videoPlayer.play()
        }
        
        // Create plane node
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2
        
        // Move plane node
        planeNode.position.x += image.name == "theatre" ? 0.01 : 0
        
        // Run animation
        planeNode.runAction(
            .sequence([
                .wait(duration: 10),
                .fadeOut(duration: 3),
                .removeFromParentNode(),
            ])
        )
        
        // Add plane node to the given node
        node.addChildNode(planeNode)
    }
    
    func nodeAdded(_ node: SCNNode, for planeAnchor: ARPlaneAnchor) {
        print(#line, #function, "Plane \(planeAnchor) added")
    }
}
