//
//  ProductView.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import SwiftUI

struct ProductView: View {
    private let item: Product
    
    init(item: Product) {
        self.item = item
    }
    
    var body: some View {
        HStack {
            CircleImage(imageName: item.imageName)
                .frame(width: 100.0, height: 100.0)
            Text(item.name)
                .bold()
                .font(.system(size: 25.0))
                .padding(.leading)
            Spacer()
            Text("\(item.priceUSD)" + String.space + "$")
                .font(.system(size: 20.0))
            VStack {
                Text("common.per")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(String.space + item.unit)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

private enum Subviews {
    static var priceLabel: some View {
        VStack {
            price
            quantityLabel
        }
    }

    static var price: some View {
        HStack(alignment: .center, spacing: .zero) {
            Text("12.4")
            Text(String.space)
            Text("$")
        }
    }

    static var quantityLabel: some View {
        HStack(alignment: .center, spacing: .zero) {
            Text("common.per")
                .font(.caption)
                .foregroundColor(.gray)
            Text(" ")
                .font(.caption)
                .foregroundColor(.gray)
            Text("bag")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct ProductViewPreviews: PreviewProvider {
    static var previews: some View {
        ProductView(item: Product(
            name: "Peas",
            priceUSD: 20.0,
            unit: "bag",
            imageName: "peas"
        ))
            .environment(\.locale, .init(identifier: "en"))
    }
}
