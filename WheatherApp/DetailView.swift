//
//  DetailView.swift
//  WheatherApp
//
//  Created by Vladimir Spasov on 16/7/24.
//

import SwiftUI
import Kingfisher

struct DetailView: View {
    let weatherEntries: [HourlyWeatherEntry]
    let dateString: String

    var body: some View {
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
                        Text(dateString)
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    Spacer()
                }
                    .padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
            )

            List(weatherEntries, id: \.time) { entry in
                VStack(alignment: .leading) {
                    HStack {
                        Text(entry.time)
                            .font(.headline)
                        Spacer()
                        Text("\(entry.temp)°C")
                    }

                    HStack {
                        if let iconURL = entry.iconURL {
                            KFImage(iconURL)
                                .resizable()
                                .frame(width: 50, height: 50)
                        } else {
                            Image(systemName: "questionmark.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        }

                        Text(entry.description)
                    }
                    .padding(0)

                    Text("Feels Like: \(entry.feelsLike)°C")
                    Text("Pressure: \(entry.pressure) hPa")
                    Text("Humidity: \(entry.humidity)%")
                    Text("Wind Speed: \(entry.windSpeed) m/s")


                }
            }
        }
        .navigationTitle("Hourly Forecast")
    }
}
