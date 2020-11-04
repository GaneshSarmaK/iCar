//
//  DatabaseController.swift
//  OnboardingLottie
//
//  Created by Sai Raghu Varma Kallepalli on 9/11/19.
//  Copyright © 2019 Brian Advent. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseController: NSObject, DatabaseProtocol {
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate

    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    var sensorRef: CollectionReference?
    var teamsRef: CollectionReference?
    var dataList: [Sensor]
    var tempList: [Sensor]
    var status: Bool = true
    var points = 1500
    
    override init(){
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        dataList = [Sensor]()
        tempList = [Sensor]()
        
        super.init()
        authController.signInAnonymously() { (authResult, error) in
            guard authResult != nil else {
                fatalError("Firebase authentication failed")
            }
            self.setUpListeners()
        }
    }
    
    func setUpListeners() {
        
        sensorRef = database.collection("iCar")
        sensorRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseSensorsSnapshot(snapshot: querySnapshot!)
        }
    }
    
    
    func parseSensorsSnapshot(snapshot: QuerySnapshot){
    
        
        snapshot.documentChanges.forEach { change in
        
            let data = change.document.data()
            
            do{
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                let sensorData = try JSONDecoder().decode(Sensor.self , from: jsonData)
                tempList.append(sensorData)
                print(change.document.documentID, sensorData.timestamp)
                if(sensorData.gps.curLat == 0)
                {
                    return
                }
                
                
            }
            catch {
                print(error.localizedDescription)
                return
            }

        }
        
        tempList = tempList.sorted(by: { $0.timestamp > $1.timestamp })
        dataList = [Sensor]()
        dataList.append(tempList[0])
        dataList.append(tempList[1])
        print(tempList[0])
        print(tempList[1])
        
        calculatePointsForUser()
        if(dataList[0].rfid.tag != 0)
        {
            if(dataList[0].rfid.name != "User"){
                    appDelegate?.createBackgroundNotification(message: "Car has been unlocked by \(dataList[0].rfid.name)", title: "Car unlocked")
            }
            else{
                appDelegate?.createBackgroundNotification(message: "An unauthorized user had tried to access your Car", title: "Unauthorized access")
            }
        }
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.data || listener.listenerType == ListenerType.all {
                listener.onDataListChange(change: .update, dataList: dataList)
                listener.getPoints(change: .update, points: points)

            }
        }
        status.toggle()

    }
    
    func addListener(listener: DatabaseListener) {
        
        listeners.addDelegate(listener)
        if listener.listenerType == ListenerType.data || listener.listenerType == ListenerType.all {
            listener.onDataListChange(change: .update, dataList: dataList)
            listener.getPoints(change: .update, points: points)

        }
        
    }
    
    func removeListener(listener: DatabaseListener) {
        
        listeners.removeDelegate(listener)
        
    }
    
    func calculatePointsForUser(){
        
        if(dataList.count >= 2){
        
            let accelX1 = dataList[0].gyro.accelX
            let accelY1 = dataList[0].gyro.accelY
            let accelZ1 = dataList[0].gyro.accelZ
            let totalAccel1 = ((accelX1 * accelX1) + (accelY1 * accelY1) + (accelZ1 * accelZ1)).squareRoot()
            
            let accelX2 = dataList[1].gyro.accelX
            let accelY2 = dataList[1].gyro.accelY
            let accelZ2 = dataList[1].gyro.accelZ
            let totalAccel2 = ((accelX2 * accelX2) + (accelY2 * accelY2) + (accelZ2 * accelZ2)).squareRoot()
            
            let totalAccel: Double = totalAccel1 - totalAccel2
                
            let gyroX = dataList[0].gyro.gyroX
            let gyroY = dataList[0].gyro.gyroY
            let gyroZ = dataList[0].gyro.gyroZ
            let totalRotation = ((gyroX * gyroX) + (gyroY * gyroY) + (gyroZ * gyroZ)).squareRoot()
            
            print(points)
            
            if(totalAccel > 10)
            {
                points = points - 3
            }
            else if(totalAccel > 7)
            {
                points = points - 1
            }
            else if(totalAccel < 1.5)
            {
                
            }
            else if(totalAccel < 5)
            {
                points = points + 1
            }
            
            if(totalRotation > 8){
                points = points - 5
            }
            else if(totalRotation > 7)
            {
                points = points - 1
            }
            else if(totalRotation < 1.5)
            {
                
            }
            else if(totalRotation < 5)
            {
                points = points + 1
            }
        
            print(totalRotation, totalAccel, points,"Total values")

            
            
        }
        
    }

}
