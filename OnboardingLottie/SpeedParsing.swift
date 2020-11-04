//
//  SpeedParsing.swift
//  OnboardingLottie
//
//  Created by Sai Raghu Varma Kallepalli on 6/11/19.
//  Copyright © 2019 Brian Advent. All rights reserved.
//

struct JsonResponse: Codable {
    let Response: ResponseData?
}

struct ResponseData: Codable {
    let View: [ViewData]?
}

struct ViewData: Codable {
    let Result: [ResultData]?
}

struct ResultData: Codable {
    let Location: LocationData?
}

struct LocationData: Codable{
    let LinkInfo: LinkInfo?
    let Address: Address?
}

struct Address: Codable{
    let District: String?
    let Street: String? 
}

struct LinkInfo: Codable{
    let SpeedCategory: String?
}
