//
//  CarScrollView.swift
//  MileMark
//
//  Created by Matthew Secketa on 4/27/25.
//


import SwiftUI

struct CarScrollView: View {
    let cars: [Car]
    let onEdit: (Car) -> Void
    let onDelete: (Car) -> Void
    let onSelect: (Car) -> Void
    let selectedCar: Car?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(cars) { car in
                    CarCardView(car: car, isSelected: selectedCar?.id == car.id)
                        .onTapGesture {
                            onSelect(car)
                        }
                        .contextMenu {
                            Button("Edit", systemImage: "pencil") {
                                onEdit(car)
                            }
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                onDelete(car)
                            }
                        }
                }
            }
            .padding(.vertical, 5)
            .padding(.leading, 15)
        }
    }
}

