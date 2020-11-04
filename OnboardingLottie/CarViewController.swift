//
//  CarViewController.swift
//  OnboardingLottie
//
//  Created by Sai Raghu Varma Kallepalli on 5/11/19.
//  Copyright © 2019 Brian Advent. All rights reserved.
//
//  Source for Car image - Car PNG Top View Png link - "http://pluspng.com/car-png-top-view-png-3190.html"
//  radar animation https://lottiefiles.com/10484-heart-fluttering
//  caution animation https://lottiefiles.com/4386-connection-error
//  danger animation https://lottiefiles.com/4970-unapproved-cross
//  moon animation https://lottiefiles.com/2801-night-moon



import UIKit
import Lottie
import CoreLocation

class CarViewController: UIViewController, DatabaseListener {

    @IBOutlet weak var speedTopBG: UIImageView!
    @IBOutlet weak var tempTopBg: UIImageView!
    
    @IBOutlet weak var speedTopLabel: UILabel!
    @IBOutlet weak var speedCurrent: UILabel!
    @IBOutlet weak var currentSpeedNumberLabel: UILabel!
    @IBOutlet weak var speedMax: UILabel!
    @IBOutlet weak var maxSpeedNumberLabel: UILabel!
    
    @IBOutlet weak var speedImgBg: UIImageView!
    @IBOutlet weak var tempImgBg: UIImageView!
    
    @IBOutlet weak var tempTopLabel: UILabel!
    @IBOutlet weak var tempOut: UILabel!
    @IBOutlet weak var tempOutNumLabel: UILabel!
    @IBOutlet weak var insideTemp: UILabel!
    @IBOutlet weak var insideTempNumLabel: UILabel!
    
    @IBOutlet weak var blackBg: UIImageView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var distanceNumberLabel: UILabel!
    
    var imageView = UIImageView()
    
    var homeViewCtrl = HomeViewController()
    
    weak var databaseController: DatabaseProtocol?
    var dataList: [Sensor] = [Sensor]()
    
    var animationView = LAAnimationView.animationNamed("")
    var radarAnimation = LAAnimationView.animationNamed("")
    var cautionAnimation = LAAnimationView.animationNamed("")
    var dangerAnimation = LAAnimationView.animationNamed("")
    var moonAnimation = LAAnimationView.animationNamed("")
    var sunAnimation = LAAnimationView.animationNamed("")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadRadar()
        loadCaution()
        loadStop()
        loadLight()
        loadSun()
        addCarImage()
        startAnimation()
        
        let seconds = 3.0
        let y: CGFloat = -170
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            UIView.animate(withDuration: 1, animations: {
                self.blackBg.transform = CGAffineTransform(translationX: 0, y: y)
                self.distance.transform = CGAffineTransform(translationX: 0, y: y)
                self.distanceNumberLabel.transform = CGAffineTransform(translationX: 0, y: y)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.moonAnimation?.isHidden = false
                    self.moonAnimation?.play()
                }
            })
        }

        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate!.databaseController
    }
    
    func loadRadar() {
        radarAnimation = LAAnimationView.animationNamed("radar")
        radarAnimation?.frame = CGRect(x: 126, y: 40, width: 170, height: 500)
        radarAnimation?.contentMode = .scaleAspectFill
        radarAnimation?.loopAnimation = true
        self.view.addSubview(radarAnimation!)
        radarAnimation?.isHidden = true
        //radarAnimation?.play()
    }
    
    func loadCaution() {
        cautionAnimation = LAAnimationView.animationNamed("cautionYellow")
        cautionAnimation?.frame = CGRect(x: 160, y: 70, width: 100, height: 100)
        cautionAnimation?.contentMode = .scaleAspectFill
        cautionAnimation?.loopAnimation = true
        self.view.addSubview(cautionAnimation!)
        cautionAnimation?.isHidden = true
        //radarAnimation?.play()
    }
    
    func loadStop() {
        dangerAnimation = LAAnimationView.animationNamed("stop")
        dangerAnimation?.frame = CGRect(x: 160, y: 70, width: 100, height: 100)
        dangerAnimation?.contentMode = .scaleAspectFill
        dangerAnimation?.loopAnimation = true
        self.view.addSubview(dangerAnimation!)
        dangerAnimation?.isHidden = true
        //radarAnimation?.play()
    }
    
    func loadLight() {
        moonAnimation = LAAnimationView.animationNamed("dark")
        moonAnimation?.frame = CGRect(x: 20, y: 710, width: 100, height: 100)
        moonAnimation?.contentMode = .scaleAspectFill
        moonAnimation?.loopAnimation = true
        self.view.addSubview(moonAnimation!)
        moonAnimation?.isHidden = true
        //radarAnimation?.play()
    }
    
    func loadSun() {
        sunAnimation = LAAnimationView.animationNamed("bright")
        sunAnimation?.frame = CGRect(x: 20, y: 710, width: 100, height: 100)
        sunAnimation?.contentMode = .scaleAspectFill
        sunAnimation?.loopAnimation = true
        self.view.addSubview(sunAnimation!)
        sunAnimation?.isHidden = true
        //radarAnimation?.play()
    }
    
    var listenerType = ListenerType.data
    
    func getPoints(change: DatabaseChange, points: Int) {
    }
    
    func onDataListChange(change: DatabaseChange, dataList: [Sensor]) {
        self.dataList = dataList
        if(dataList.count >= 2)
        {
            self.tempOutNumLabel.text = String(dataList[0].temp.outside)
            self.insideTempNumLabel.text = String(dataList[0].temp.inside)
            print(String(Int(dataList[0].ultrasonic.distance)) + "cm")
            updateSppedLimit(latitude: dataList[0].gps.curLat, longitude: dataList[0].gps.curLong)
            calculateSpeed(data: dataList)
            
            if(dataList[0].light.lux < 17000)
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    self.sunAnimation?.isHidden = true
                    self.sunAnimation?.pause()
                    self.moonAnimation?.isHidden = false
                    self.moonAnimation?.play()
                }
            }
            else
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {                    self.moonAnimation?.isHidden = true
                    self.moonAnimation?.pause()
                    self.sunAnimation?.isHidden = false
                    self.sunAnimation?.play()
                }
            }
        
            print("its set here")
            if (Int(dataList[0].ultrasonic.distance) > 300) {
                self.distanceNumberLabel.text = "Clear"
            } else {
                self.distanceNumberLabel.text = String(Int(dataList[0].ultrasonic.distance)) + "cm"
            }
            
            
            if (dataList[0].ultrasonic.distance < 150)
                //Danger
            {
                homeViewCtrl.playSound(name: "danger")
                cautionAnimation?.isHidden = true
                cautionAnimation?.pause()
                dangerAnimation?.isHidden = false
                dangerAnimation?.play()
            }
            else if (dataList[0].ultrasonic.distance < 300)
                //Caution
            {
                homeViewCtrl.playSound(name: "caution")
                dangerAnimation?.isHidden = true
                dangerAnimation?.pause()
                cautionAnimation?.isHidden = false
                cautionAnimation?.play()
            }
            else
            {
                dangerAnimation?.isHidden = true
                dangerAnimation?.pause()
                cautionAnimation?.isHidden = true
                cautionAnimation?.pause()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        databaseController?.removeListener(listener: self)
    }
    
    func startAnimation() {
        let x: CGFloat = 90
        let y: CGFloat = -90
        let seconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            UIView.animate(withDuration: 1, animations: {
                self.imageView.transform = CGAffineTransform(translationX: 0, y: -780)
                
            })
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds + 1) {
            UIView.animate(withDuration: 1, animations: {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.radarAnimation?.isHidden = false
                    self.radarAnimation?.play()
                }
                
                self.animationView?.play()
                self.animationView?.isHidden = false
                self.speedTopBG.transform = CGAffineTransform(translationX: x, y: 0)
                self.speedImgBg.transform = CGAffineTransform(translationX: x, y: 0)
                self.speedTopLabel.transform = CGAffineTransform(translationX: x, y: 0)
                self.speedCurrent.transform = CGAffineTransform(translationX: x, y: 0)
                self.currentSpeedNumberLabel.transform = CGAffineTransform(translationX: x, y: 0)
                self.speedMax.transform = CGAffineTransform(translationX: x, y: 0)
                self.maxSpeedNumberLabel.transform = CGAffineTransform(translationX: x, y: 0)
                self.tempTopBg.transform = CGAffineTransform(translationX: y, y: 0)
                self.tempImgBg.transform = CGAffineTransform(translationX: y, y: 0)
                self.tempTopLabel.transform = CGAffineTransform(translationX: y-2, y: 0)
                self.tempOut.transform = CGAffineTransform(translationX: y, y: 0)
                self.tempOutNumLabel.transform = CGAffineTransform(translationX: y, y: 0)
                self.insideTemp.transform = CGAffineTransform(translationX: y, y: 0)
                self.insideTempNumLabel.transform = CGAffineTransform(translationX: y, y: 0)
                
                self.tempImgBg.layer.cornerRadius = (self.blackBg.frame.size.width)/10
                self.tempImgBg.clipsToBounds = true
                
                self.speedImgBg.layer.cornerRadius = (self.blackBg.frame.size.width)/10
                self.speedImgBg.clipsToBounds = true
                
//                self.speedTopBG.layer.cornerRadius = (self.blackBg.frame.size.width)/10
//                self.speedTopBG.clipsToBounds = true
//
//                self.tempTopBg.layer.cornerRadius = (self.blackBg.frame.size.width)/10
//                self.tempTopBg.clipsToBounds = true
                
                self.blackBg.layer.cornerRadius = (self.blackBg.frame.size.width)/10
                self.blackBg.clipsToBounds = true
            })
        }
    }
    
    func loadAnimations(name: String)
    {
        loadLottie(fileName: name, x: 50, y: 700, width: 100, height: 100, loopStatus: true, enableTouch: false, magnitude: -5, play: true)
        loadLottie(fileName: "caution", x: 160, y: 70, width: 100, height: 100, loopStatus: true, enableTouch: false, magnitude: 0,play: true)
        loadLottie(fileName: "stop", x: 160, y: 70, width: 100, height: 100, loopStatus: true, enableTouch: false, magnitude: 0, play: true)
    }

    func addCarImage() {
        imageView  = UIImageView(frame:CGRect(x: 95, y: 1020, width: 230, height: 400));
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named:"redcar")
        self.view.addSubview(imageView)
    }
    
    func applyMotionEffect (toView view:LAAnimationView, magnitude:Float) {
        let xMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = -magnitude
        xMotion.maximumRelativeValue = magnitude
        
        let yMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        yMotion.minimumRelativeValue = -magnitude
        yMotion.maximumRelativeValue = magnitude
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [xMotion, yMotion]
        
        view.addMotionEffect(group)
    }
    
    func addBlurEffect(iv: UIImageView, x: CGFloat, y: CGFloat)
    {
        if #available(iOS 13.0, *) {
            let blurEffect = UIBlurEffect(style: .regular)
            let blurredEffectView = UIVisualEffectView(effect: blurEffect)
            blurredEffectView.frame = iv.bounds
            blurredEffectView.transform = CGAffineTransform(translationX: x, y: y)
            view.addSubview(blurredEffectView)
        } else {
            // Fallback on earlier versions
        }
    }
    
    func loadLottie(fileName: String, x: Int, y: Int, width: CGFloat, height: CGFloat, loopStatus: Bool, enableTouch: Bool, magnitude: Float, play: Bool)
        {
            animationView = LAAnimationView.animationNamed(fileName)
            animationView?.frame = CGRect(x: x, y: y, width: Int(width), height: Int(height))
            animationView?.contentMode = .scaleAspectFill
            animationView?.isUserInteractionEnabled = enableTouch
            animationView?.loopAnimation = loopStatus
            animationView?.loopAnimation = loopStatus
            self.view.addSubview(animationView!)
            if play {
                animationView?.play()
                
            }
            animationView?.isHidden = true
            applyMotionEffect(toView: animationView!, magnitude: magnitude)
            
        
        }
    
    func updateSppedLimit(latitude: Double, longitude: Double)
    {
        let lat = String(format: "%f", latitude)
        let lon = String(format: "%f", longitude)
        
        let url = URL(string: "https://reverse.geocoder.api.here.com/6.2/reversegeocode.json?prox=" + lat + "," + lon + ",50&mode=retrieveAddresses&locationAttributes=linkInfo&gen=9&app_id=bGsxRlcLJl9jlkPw8llT&app_code=P61HIba-X4DxDhv2SypcFg")
        
        URLSession.shared.dataTask(with: url!) { data, _, _ in
            if let data = data {
                let resp = try? JSONDecoder().decode(JsonResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.displaySpeedLimit(speed: (resp?.Response?.View?.first?.Result?.first?.Location?.LinkInfo?.SpeedCategory)!)
                }
            }
            }.resume()
    }
    
    func displaySpeedLimit(speed: String) {
        if speed == "SC1"{
            print(">130")
            self.maxSpeedNumberLabel.text = ">130"
        }
        else if speed == "SC2"{
            print("130")
            self.maxSpeedNumberLabel.text = "130"
        }
        else if speed == "SC3"{
            print("100")
            self.maxSpeedNumberLabel.text = "100"
        }
        else if speed == "SC4"{
            print("90")
            self.maxSpeedNumberLabel.text = "90"
        }
        else if speed == "SC5"{
            print("70")
            self.maxSpeedNumberLabel.text = "70"
        }
        else if speed == "SC6"{
            print("50")
            self.maxSpeedNumberLabel.text = "50"
        }
        else if speed == "SC7"{
            print("30")
            self.maxSpeedNumberLabel.text = "30"
        }
        else if speed == "SC8"{
            print("<11")
            self.maxSpeedNumberLabel.text = "10"
        }
    }
    
    func calculateSpeed(data: [Sensor])
    {
        if(data[0].gps.prevLat == 0 )
        {
            return
        }
        else
        {
            let coordinate1 = CLLocation(latitude: data[0].gps.curLat, longitude: data[0].gps.curLong)
            let coordinate2 = CLLocation(latitude: data[0].gps.prevLat, longitude: data[0].gps.prevLong)
            
            let distanceInMeters = coordinate1.distance(from: coordinate2)
            let timeDiff = data[0].gps.curTime - data[0].gps.prevTime
            let speedKph: Int = Int((Double(distanceInMeters) / Double(timeDiff)) * ( 3.6 ))
            self.currentSpeedNumberLabel.text = String(speedKph)
            
            
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
    @IBAction func carTopButton(_ sender: Any) {
         _ = navigationController?.popToRootViewController(animated: true)
    }
    
}
