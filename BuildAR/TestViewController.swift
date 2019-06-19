//
//  ViewController.swift
//  BuildAR
//
//  Created by Tay Jin Wen on 5/6/19.
//  Copyright © 2019 Tay Jin Wen. All rights reserved.
//

import UIKit
import Firebase

class TestViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storage = Storage.storage().reference()
        let tempImageRef = storage.child("tempDir/tempImage.jpg")

        let image = UIImage(named: "1")

        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        let imageData = image?.jpegData(compressionQuality: 0.8)!

        tempImageRef.putData(imageData!, metadata: metaData) { (metadata, error) in
            if error == nil {
                print("UPLOAD SUCCESSFUL: \(String(describing: metadata))")
            } else {
                print("There is an error: \(String(describing: error?.localizedDescription))")
            }
        }
  
//        let maxSize: Int64 = 3 * 1000 * 1000 //3MB
//
//        tempImageRef.getData(maxSize: maxSize) { (data, error) in
//            if error == nil {
//                print(data!)
//                print("SUCCESS")
//                self.imageView.image = UIImage(data: data!)
//            } else {
//                print("THERE IS AN ERROR \(String(describing: error?.localizedDescription))")
//            }
//        }
        
    }
}
