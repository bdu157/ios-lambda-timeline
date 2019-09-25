//
//  CameraPreiviewView.swift
//  LambdaTimeline
//
//  Created by Dongwoo Pae on 9/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreviewView: UIView {  //this will overwrite UIView
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

