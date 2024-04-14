//
//  ViewController.swift
//  unsplashImages
//
//  Created by Keyur barvaliya on 13/04/24.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start a timer to transition to the next view controller after a delay
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { timer in
            self.navigateToNextController()
        }
    }
    
    func navigateToNextController() {
        // Transition to the next view controller
        let unsplashImageControllerObj = UnsplashImageListVC() // Replace "NextViewController" with the identifier of your next view controller
        self.navigationController?.setViewControllers([unsplashImageControllerObj], animated: true)
    }
    
    
}

