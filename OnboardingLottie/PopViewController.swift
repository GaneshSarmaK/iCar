//
//  PopViewController.swift
//  OnboardingLottie
//
//  Created by Sai Raghu Varma Kallepalli on 6/11/19.
//  Copyright © 2019 Brian Advent. All rights reserved.
//

import UIKit
import Lottie

class PopViewController: UIViewController {
    
    var insideView: UIView = UIView()

    var animationView = LAAnimationView.animationNamed("")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeCircle()
        
        loadLottie(fileName: "scan2", x: 95, y: 305, width: 230, height: 230, loopStatus: false, enableTouch: false, magnitude: 15)
       
    }
    
    func makeCircle() {
        UIView.animate(withDuration: 1, animations: {
            //self.speedLimitBgImage.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            self.insideView.frame = CGRect(x: self.view.bounds.midX - 150 , y: self.view.bounds.midY - 150, width: 300, height: 250)
            self.insideView.layer.cornerRadius = 50
            self.insideView.clipsToBounds = true
            self.insideView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            self.view.addSubview(self.insideView)
        })
    }
    
    func loadLottie(fileName: String, x: Int, y: Int, width: CGFloat, height: CGFloat, loopStatus: Bool, enableTouch: Bool, magnitude: Int)
    {
        animationView = LAAnimationView.animationNamed(fileName)
        animationView?.frame = CGRect(x: x, y: y, width: Int(width), height: Int(height))
        animationView?.contentMode = .scaleAspectFill
        animationView?.isUserInteractionEnabled = enableTouch
        animationView?.loopAnimation = loopStatus
        self.view.addSubview(animationView!)
        if loopStatus {
            animationView?.play()
        } else {
            animationView?.play { (finished) in
                self.dismiss(animated: true, completion: nil)
            }
        } 
        
    }
    
   
}
