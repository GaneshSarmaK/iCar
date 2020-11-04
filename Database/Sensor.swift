//
//  Sensor.swift
//  OnboardingLottie
//
//  Created by Sai Raghu Varma Kallepalli on 9/11/19.
//  Copyright © 2019 Brian Advent. All rights reserved.
//

struct Sensor: Codable{
    let id: String
    let temp: temp
    let gps: gps
    let rfid: rfid
    let gyro: gyro
    let light: light
    let ultrasonic: ultrasonic
    let timestamp: Int
}

struct temp: Codable{
    let inside: Int
    let outside: Int
}

struct gyro: Codable{
    let accelX: Double
    let accelY: Double
    let accelZ: Double
    let gyroX: Double
    let gyroY: Double
    let gyroZ: Double
}

struct gps: Codable{
    let curLat: Double
    let curLong: Double
    let curTime: Int
    let prevLat: Double
    let prevLong: Double
    let prevTime: Int
}

struct rfid: Codable{
    let name: String
    let tag: Int
    let lockStatus: Bool
}

struct light: Codable{
    let lux: Double
}

struct ultrasonic: Codable{
    let distance: Int
}
