//
//  ViewController.swift
//  WhichPet
//
//  Created by Mac on 01/01/22.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        // Do any additional setup after loading the view.
    }
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: PetImageRecognition().model) else{
            fatalError("Loading CoreML Model Failed.")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation]else{
                fatalError("Fails to create request")
            }
            print(results)
            if let firstResult = results.first{
                print(firstResult.confidence)
                if firstResult.identifier.contains("Cat") && firstResult.confidence > 0.80 {
                    self.title = "Its A Cat"
                }else if firstResult.identifier.contains("Dog") && firstResult.confidence > 0.80 {
                    self.title = "Its A Dog"
                }else if firstResult.identifier.contains("Rabbit") && firstResult.confidence > 0.80 {
                    self.title = "Its A Rabbit"
                }else{
                    self.title = "Opps..."
                }

            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        try! handler.perform([request])
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[.originalImage] as? UIImage{
            imageView.image = userPickedImage
            // CIImage is data type of coreML framework
            guard let ciImage = CIImage(image: userPickedImage) else{
                fatalError("unable to convert UIImage into CIImage.")
            }
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
