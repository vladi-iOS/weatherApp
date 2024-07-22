//
//  WeatherViewModel.swift
//  WheatherApp
//
//  Created by Vladimir Spasov on 16/7/24.
//

import Foundation
import Combine

struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}

protocol WeatherViewModelProtocol: ObservableObject {
    var dailyWeatherEntries: [DailyWeatherEntry] { get }
    var errorMessage: ErrorMessage? { get }
    func fetchWeather()
}

class WeatherViewModel: WeatherViewModelProtocol {
    @Published var dailyWeatherEntries: [DailyWeatherEntry] = []
    @Published var errorMessage: ErrorMessage?
    private var cancellables = Set<AnyCancellable>()
    private let weatherService: WeatherService

    init(weatherService: WeatherService = NetworkManager()) {
        self.weatherService = weatherService
    }

    func fetchWeather() {
        weatherService.fetchWeather(for: "Paris")
            .map { response in
                self.mapToDailyWeatherEntries(response.list)
            }
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.handleError(error)
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] dailyEntries in
                self?.dailyWeatherEntries = dailyEntries
            })
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: NetworkError) {
        switch error {
        case .invalidURL:
            errorMessage = ErrorMessage(message: "Invalid URL. Please try again later.")
        case .requestFailed:
            errorMessage = ErrorMessage(message: "Failed to fetch weather data. Please try again later.")
        case .decodingFailed:
            errorMessage = ErrorMessage(message: "Failed to decode weather data. Please try again later.")
        }
    }
    
    private func mapToDailyWeatherEntries(_ entries: [WeatherEntry]) -> [DailyWeatherEntry] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "EEEE, MMM d"
        
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH:mm"
        
        var groupedEntries = [String: [WeatherEntry]]()
        
        for entry in entries {
            if let date = formatter.date(from: entry.dt_txt) {
                let dayString = displayFormatter.string(from: date)
                
                if var existingEntries = groupedEntries[dayString] {
                    existingEntries.append(entry)
                    groupedEntries[dayString] = existingEntries
                } else {
                    groupedEntries[dayString] = [entry]
                }
            } else {
                print("Error: Unable to parse date \(entry.dt_txt)")
            }
        }
        
        return groupedEntries.map { key, value in
            let hourlyEntries = value.map { entry in
                let iconURL: URL?
                if let iconCode = entry.weather.first?.icon {
                    iconURL = URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")
                } else {
                    iconURL = nil
                }
                
                return HourlyWeatherEntry(
                    time: hourFormatter.string(from: formatter.date(from: entry.dt_txt)!),
                    temp: String(format: "%.1f", entry.main.temp_max),
                    description: entry.weather.first?.description.capitalized ?? "",
                    iconURL: iconURL,
                    pressure: String(format: "%.1f", entry.main.pressure),
                    humidity: String(format: "%.1f", entry.main.humidity),
                    windSpeed: String(format: "%.1f", entry.wind.speed),
                    feelsLike: String(format: "%.1f", entry.main.feels_like)
                )
            }
            
            let firstEntry = value.first!
            let iconURL: URL?
            if let iconCode = firstEntry.weather.first?.icon {
                iconURL = URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")
            } else {
                iconURL = nil
            }
            
            return DailyWeatherEntry(
                date: key,
                minTemp: String(format: "%.1f", firstEntry.main.temp_min),
                maxTemp: String(format: "%.1f", firstEntry.main.temp_max),
                description: firstEntry.weather.first?.description.capitalized ?? "",
                iconURL: iconURL,
                hourlyEntries: hourlyEntries
            )
        }.sorted { $0.date < $1.date }
    }
}


struct HourlyWeatherEntry {
    let time: String
    let temp: String
    let description: String
    let iconURL: URL?
    let pressure: String
    let humidity: String
    let windSpeed: String
    let feelsLike: String
}

struct DailyWeatherEntry {
    let date: String
    let minTemp: String
    let maxTemp: String
    let description: String
    let iconURL: URL?
    let hourlyEntries: [HourlyWeatherEntry]
}
