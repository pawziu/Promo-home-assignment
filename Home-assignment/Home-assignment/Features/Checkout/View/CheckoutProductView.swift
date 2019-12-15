//
//  CheckoutProductView.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 15/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import SwiftUI

struct CheckoutProductView: View {
    
    // MARK: - View model
    
    @ObservedObject private var viewModel: ProductViewModel
    
    // MARK: - Initialization
    
    init(viewModel: ProductViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - View
    
    var body: some View {
        HStack {
            Text(viewModel.product.name)
                .bold()
            Spacer()
            Text("\(viewModel.count)" + .space + viewModel.unitPlural)
            Spacer()
            Text(
                viewModel.totalPrice.formattedAmount + .space + viewModel.currencyName
            )
        }
        .padding()
    }
}

#if DEBUG
struct CheckoutProductViewPreviews: PreviewProvider {
    static var previews: some View {
        CheckoutProductView(
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
