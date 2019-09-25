//
//  ViewController.swift
//  LambdaTimeline
//
//  Created by Dongwoo Pae on 9/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.showCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granter) in
                if granter {
                    DispatchQueue.main.async {
                        self.showCamera()
                    }
                }
            }
        case .denied:
            return
        case .restricted:
            return
        default:
            return
        }
    }
    private func showCamera() {
        performSegue(withIdentifier: "ShowCamera", sender: self)
    }
}
