//
//  Models.swift
//  WheatherApp
//
//  Created by Vladimir Spasov on 16/7/24.
//

import Foundation

struct WeatherResponse: Decodable {
    let list: [WeatherEntry]
}

struct WeatherEntry: Decodable {
    let dt: TimeInterval
    let main: Main
    let weather: [Weather]
    let wind: Wind
    let dt_txt: String
}

struct Main: Decodable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Double
    let humidity: Double
    let feels_like: Double
}

struct Weather: Decodable {
    let description: String
    let icon: String
}

struct Wind: Decodable {
    let speed: Double
}

