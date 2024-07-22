//
//  Mocks.swift
//  WheatherAppTests
//
//  Created by Vladimir Spasov on 18/7/24.
//

import Combine
import Foundation
@testable import WheatherApp

class MockWeatherService: WeatherService, Mockable {
    func fetchWeather(for city: String) -> AnyPublisher<WeatherResponse, NetworkError> {
        let  weatherResponse = loadJSON(filename: "Paris5day", type: WeatherResponse.self)

        return Just(weatherResponse)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
}

class MockWeatherViewModel: WeatherViewModelProtocol {
    @Published var dailyWeatherEntries: [DailyWeatherEntry] = []
    @Published var errorMessage: ErrorMessage?

    func fetchWeather() {
        
    }
}

