//
//  ViewController.swift
//  flickrfeed
//
//  Created by Jeong Jin Kim on 2017. 4. 24..
//  Copyright © 2017년 Jeong Jin Kim. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var timerStepper : UIStepper?
    @IBOutlet weak var timerLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startGallery(sender:UIButton) {
        if let viewController:FlickrGalleryViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "galleryViewController") as? FlickrGalleryViewController {
            self.present(viewController, animated: true, completion: {
                if let tick = self.timerStepper?.value {
                    viewController.timerTick = tick
                }
            })
            
        }
        
    }
    
    @IBAction func stepperValueChanged(sender: UIStepper) {
        self.timerLabel?.text = "전환 속도 : \(Int(sender.value)) 초"
    }
}

