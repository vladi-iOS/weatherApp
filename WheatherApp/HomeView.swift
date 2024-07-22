//
//  HomeView.swift
//  WheatherApp
//
//  Created by Vladimir Spasov on 16/7/24.
//

import SwiftUI
import Kingfisher

struct HomeView: View {
    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    Image("Header")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width)
                        .clipped()
                }
                .frame(height: 200)
                .overlay(
                    VStack {
                        HStack {
                            Text("Paris")
                                .foregroundColor(.white)
                                .font(.headline)
                            Spacer()
                        }
                        Spacer()
                    }
                        .padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
                )

                List(viewModel.dailyWeatherEntries, id: \.date) { dailyEntry in
                    NavigationLink(destination: DetailView(weatherEntries: dailyEntry.hourlyEntries, dateString: dailyEntry.date)) {
                        WeatherRow(dailyWeatherEntry: dailyEntry)
                    }
                }
                .onAppear {
                    viewModel.fetchWeather()
                }
                .alert(item: $viewModel.errorMessage) { errorMessage in
                    Alert(title: Text("Error"), message: Text(errorMessage.message), dismissButton: .default(Text("OK")))
                }

            }
            .navigationBarTitle("Weather", displayMode: .inline)
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct WeatherRow: View {
    let dailyWeatherEntry: DailyWeatherEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dailyWeatherEntry.date)
                .font(.headline)
            if let firstEntry = dailyWeatherEntry.hourlyEntries.first {
                HStack {
                    if let iconURL = dailyWeatherEntry.iconURL {
                        KFImage(iconURL)
                            .resizable()
                            .frame(width: 50, height: 50)
                    } else {
                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                    }

                    Text(dailyWeatherEntry.description)
                }
                .padding(0)

                HStack {
                    Text("Min: \(dailyWeatherEntry.minTemp)°C")
                        .bold()
                    Spacer()
                    Text("Max: \(dailyWeatherEntry.maxTemp)°C")
                        .bold()
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
