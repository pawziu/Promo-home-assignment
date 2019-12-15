//
//  CheckoutView.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import SwiftUI
import Combine

struct CheckoutView: View {
    @ObservedObject var viewModel: CheckoutViewModel
    
    init(viewModel: CheckoutViewModel) {
      self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            if viewModel.dataSource.isEmpty {
                Text("Your basket is empty!")
            } else {
                List {
                    checkoutListSection
                }
                HStack {
                    Text("Total")
                        .padding()
                    Spacer()
                    Text(viewModel.totalAmount.formattedAmount + .space + viewModel.currencyName)
                        .padding()
                }
                changeCurrencyButton
            }
        }
        .navigationBarTitle("Checkout")
    }
    
    private var checkoutListSection: some View {
        Section {
            ForEach(viewModel.dataSource, content: CheckoutProductView.init(viewModel:))
        }
    }
    
    private var changeCurrencyButton: some View {
        NavigationLink(destination: CurrencyPickerView(viewModel: CurrencyPickerViewModel())) {
            Text("Change currency")
                .padding()
        }
    }
}
