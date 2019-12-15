//
//  ProductView.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import SwiftUI

struct ProductView: View {
    @ObservedObject private var viewModel: ProductViewModel
    
    init(viewModel: ProductViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            CircleImage(imageName: viewModel.product.imageName)
                .frame(width: 70.0, height: 70.0)
            VStack(alignment: .leading) {
                Text(viewModel.product.name)
                    .bold()
                    .font(.system(size: 25.0))
                Text(viewModel.calculatedPrice.formattedAmount + String.space + viewModel.currencyName)
                Text(viewModel.product.unit)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
                .padding(.leading)
            Spacer()
            Button("-") {
                self.viewModel.decreaseCount()
            }
                .font(.largeTitle)
                .padding(.leading)
            Text("\(viewModel.count)")
            Button("+") {
                self.viewModel.increaseCount()
            }
                .font(.largeTitle)
                .padding(.trailing)
        }
            .padding(.top)
            .padding(.bottom)
    }
}

#if DEBUG
struct ProductViewPreviews: PreviewProvider {
    static var previews: some View {
        ProductView(
            viewModel: ProductViewModel(
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
#endif
