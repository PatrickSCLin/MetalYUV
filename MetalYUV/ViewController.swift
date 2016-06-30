//
//  ViewController.swift
//  MetalYUV
//
//  Created by Patrick Lin on 7/1/16.
//  Copyright © 2016 Patrick Lin. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    
    @IBOutlet var videoView: PLVideoView!
    
    // Mark: Internal Methods
    
    func dummyData() -> ([NSData], CGSize) {
        
        let data = NSData(contentsOfURL: NSBundle.mainBundle().URLForResource("sample_1280_544", withExtension: "yuv")!)!
        
        let dataY = data.subdataWithRange(NSMakeRange(0, 1280 * 544))
        
        let dataU = data.subdataWithRange(NSMakeRange(dataY.length, 640 * 272))
        
        let dataV = data.subdataWithRange(NSMakeRange(dataY.length + dataU.length, 640 * 272))
        
        return ([dataY, dataU, dataV], CGSizeMake(1280, 544))
        
    }
    
    // MARK: Init Methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let image = self.dummyData();
        
        let dataYUV = image.0
        
        let size = image.1
        
        self.videoView.render(dataYUV[0], dataU: dataYUV[1], dataV: dataYUV[2], size: size)
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }    
    
}

