//
//  CarCardView.swift
//  MileMark
//
//  Created by Matthew Secketa on 4/27/25.
//

import SwiftUI

struct CarCardView: View {
    let car: Car
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Image("car.default")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 120)
                .clipped()
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 5) {
                Text("\(car.year) \(car.make)")
                    .font(.headline)
                Text(car.model)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Mileage: \(car.mileage) mi")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding([.horizontal, .bottom], 8)
        }
        .frame(width: 200)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
        )
        .shadow(radius: 4)
    }
}

#Preview {
    CarCardView(car: Car(id: "demo", make: "Honda", model: "Civic", year: "2020", mileage: 56876), isSelected: false)
}

