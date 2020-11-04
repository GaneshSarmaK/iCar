//
//  AboutViewController.swift
//  OnboardingLottie
//
//  Created by Sai Raghu Varma Kallepalli on 10/11/19.
//  Copyright © 2019 Brian Advent. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var segmentBar: UISegmentedControl!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.font = textLabel.font.withSize(13)
        textLabel.text = "This is the main screen \n  1. Shows the status of lock and unlock status of the Car \n 2. The animation plays when the car is in motion else it stays still \n 3. Shows the current or last updates location of the Car \n 4. Displays the current or last accessed user's name \n 5. Tab bar can be used to navigate to  other screens"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func Menu(_ sender: Any) {
        switch segmentBar.selectedSegmentIndex {
        case 0:
            imageView.image = UIImage(named: "home")
            textLabel.font = textLabel.font.withSize(13)
            textLabel.text = "This is the main screen \n  1. Shows the status of lock and unlock status of the Car \n 2. The animation plays when the car is in motion else it stays still \n 3. Shows the current or last updates location of the Car \n 4. Displays the current or last accessed user's name \n 5. Tab bar can be used to navigate to  other screens"
            break
        case 1:
            imageView.image = UIImage(named: "car")
            textLabel.font = textLabel.font.withSize(12)
            textLabel.text = "This screens shows all the sensor details along with the data from speedlimit API\n 1. Here no animation is displayed if the path in the front is clear or will play an caution or danger animation and makes sound depending on the distance left from the car at the front \n 2. Shows the Current and Max speed of the car and road respetively \n 3. displays the temperature of both inside and outside the car \n 4. Shows the distance dynamically, if the distance is more than 2 meters it shows Clear else shows the exact distance in 'cms' \n 5. Displays the Moon and Sun animation accordingly from the luminance"
            break
        case 2:
            imageView.image = UIImage(named: "map")
            textLabel.font = textLabel.font.withSize(15)
            textLabel.text = "This screen shows the Car location and user's location and aslo displays the current speed and max speed \n 1. This image display the Car's location \n 2. Displays the user location in blue cirlce \n 3. Displays the speed limit on the left, Street name in the middle and Current speed of the car in the right \n > Also warns the user by shows a red border when he is overspeeding"
            break
        case 3:
            imageView.image = UIImage(named: "pro")
            textLabel.font = textLabel.font.withSize(15)
            textLabel.text = "This screen shows the profile of the user along with the score, progress and all card holders \n 1. Here the directions are shown from user's location to car's location \n 2. The user can see his performance from the score and progress items \n 3. Shows all the card holders enroled to access the Car"
            break
        default:
            imageView.image = UIImage(named: "home")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
