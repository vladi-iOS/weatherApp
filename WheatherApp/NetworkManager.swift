//
//  NetworkManager.swift
//  WheatherApp
//
//  Created by Vladimir Spasov on 16/7/24.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
}

protocol WeatherService {
    func fetchWeather(for city: String) -> AnyPublisher<WeatherResponse, NetworkError>
}

class NetworkManager: WeatherService {
    private let baseURL = "https://api.openweathermap.org/data/2.5/forecast"
    private let apiKey = "d61cb8237bfecdd662686b8345b65623"

    func fetchWeather(for city: String) -> AnyPublisher<WeatherResponse, NetworkError> {
        guard let url = URL(string: "\(baseURL)?q=\(city)&appid=\(apiKey)&units=metric") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { _ in NetworkError.requestFailed }
            .flatMap { data, response -> AnyPublisher<WeatherResponse, NetworkError> in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    return Fail(error: NetworkError.requestFailed).eraseToAnyPublisher()
                }

                return Just(data)
                    .decode(type: WeatherResponse.self, decoder: JSONDecoder())
                    .mapError { _ in NetworkError.decodingFailed }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

