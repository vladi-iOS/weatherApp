//
//  WheatherAppTests.swift
//  WheatherAppTests
//
//  Created by Vladimir Spasov on 16/7/24.
//

import XCTest
import Combine
@testable import WheatherApp

class WeatherViewModelTests: XCTestCase {
    var viewModel: WeatherViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        viewModel = WeatherViewModel(weatherService: MockWeatherService())
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchWeatherCountIsCorrect() {
        let expectation = XCTestExpectation(description: "Fetch weather data")

        viewModel.fetchWeather()

        viewModel.$dailyWeatherEntries
            .sink { dailyEntries in
                if !dailyEntries.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)

        XCTAssertEqual(viewModel.dailyWeatherEntries.count, 6)
    }

    func testFetchWeatherCorrectDailyDateFormat() {
        let expectation = XCTestExpectation(description: "Fetch weather data")

        viewModel.fetchWeather()

        viewModel.$dailyWeatherEntries
            .sink { dailyEntries in
                if !dailyEntries.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)

        XCTAssertEqual(viewModel.dailyWeatherEntries.first?.date, "Friday, Jul 19")
    }

    func testFetchWeatherCorrectHourlyDateFormat() {
        let expectation = XCTestExpectation(description: "Fetch weather data")

        viewModel.fetchWeather()

        viewModel.$dailyWeatherEntries
            .sink { dailyEntries in
                if !dailyEntries.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)

        XCTAssertEqual(viewModel.dailyWeatherEntries.first?.hourlyEntries.first?.time, "00:00")
    }
}
