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
    private let currency: String
    
    init(item: ProductItem) {
        self.item = item.product
        self.currency = item.currencyName
    }
    
    var body: some View {
        HStack {
            CircleImage(imageName: item.imageName)
                .frame(width: 60.0, height: 60.0)
            Text(item.name)
                .bold()
                .font(.system(size: 25.0))
                .padding(.leading)
            Spacer()
            Text(item.priceUSD.formattedAmount + String.space + currency)
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

struct ProductViewPreviews: PreviewProvider {
    static var previews: some View {
        ProductView(
            item: ProductItem(
                product: Product(
                    name: "Peas",
                    priceUSD: 20.0,
                    unit: "bag",
                    imageName: "peas"
                ),
                currencyName: "USD"
            )
        )
            .environment(\.locale, .init(identifier: "en"))
    }
}
