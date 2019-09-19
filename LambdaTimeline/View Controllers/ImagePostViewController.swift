//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos

class ImagePostViewController: ShiftableViewController {
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    //slider outlets
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    
    //taking original image to make it smaller and easier to manupulate while making changes for its preview
    var originalimage: UIImage? {
        didSet {
            guard let originalImage = self.originalimage else {return} //once we selected image we run it
            
            //height and width
            var scaledSize = imageView.bounds.size
            
            // 1x, 2x, 3x(10x max)
            let scale = UIScreen.main.scale  //screen size based on user's device
            
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            
            self.scaledImage = originalImage.imageByScaling(toSize: scaledSize) //when originalimage gets available then make scaledImage
        }
    }
    
    var scaledImage: UIImage? {
        didSet {
            self.updateImage()
        }
    }
    
    private let context = CIContext(options: nil)
    private let filter = CIFilter(name: "CIColorControls")!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        updateViews()
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }
        
        title = post?.title
        
        setImageViewHeight(with: image.ratio)
        
        imageView.image = image
        
        chooseImageButton.setTitle("", for: [])
    }
    
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != "" else {
                presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
                return
        }
        
        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                
                self.presentImagePickerController()
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
            
        }
        presentImagePickerController()
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    
    // MARK: - Slider actions
    
    @IBAction func brightnessChanged(_ sender: Any) {
        self.updateImage()
    }
    
    @IBAction func contrastChanged(_ sender: Any) {
        self.updateImage()
    }
    
    @IBAction func saturationChanged(_ sender: Any) {
        self.updateImage()
    }
    
    private func updateImage() {
        if let scaledImage = self.scaledImage {
            imageView.image = self.image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    private func image(byFiltering image: UIImage) -> UIImage {
        
        //this will take scaledImage
        
        //uiimage -> cgimage -> ciimage
        guard let cgImage = image.cgImage else {return image}  //cgImage can be used from UIImage
        let ciImage = CIImage(cgImage: cgImage)
        
        //Set the values of the filter's paremeters
        filter.setValue(ciImage, forKey: "inputImage")  //take the image
        filter.setValue(saturationSlider.value, forKey: "inputSaturation")  //set the saturationSlider to have inputSaturation
        filter.setValue(brightnessSlider.value, forKey: "inputBrightness") // set the brightnessSlider to have inputBrightness
        filter.setValue(contrastSlider.value, forKey: "inputContrast") // set the contrastSlider to hvae inputContrast
        
        // the metadata to be processed. not the actual filtered image
        //ciimage -> cgimage -> uiimage
        guard let outputCIImage = filter.outputImage else {return image}
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {return image}
        return UIImage(cgImage: outputCGImage)
    }
}



extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        //imageView.image = image
        self.originalimage = image
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    //slider actions
    
    
}
