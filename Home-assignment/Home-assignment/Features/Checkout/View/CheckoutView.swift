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
    
    // MARK: - View model
    
    @ObservedObject var viewModel: CheckoutViewModel
    
    // MARK: - Initialiation
    
    init(viewModel: CheckoutViewModel) {
      self.viewModel = viewModel
    }
    
    // MARK: - View
    
    var body: some View {
        VStack {
            if viewModel.dataSource.isEmpty {
                Text("basket.empty")
            } else {
                checkoutView
            }
        }
        .navigationBarTitle("checkout")
    }
    
    private var checkoutView: some View  {
        VStack {
            List {
                checkoutListSection
            }
            HStack {
                Text("basket.total")
                    .padding()
                Spacer()
                Text(viewModel.totalAmount.formattedAmount + .space + viewModel.currencyName)
                    .padding()
            }
            changeCurrencyButton
        }
    }
    
    private var checkoutListSection: some View {
        Section {
            ForEach(viewModel.dataSource, content: CheckoutProductView.init(viewModel:))
        }
    }
    
    private var changeCurrencyButton: some View {
        NavigationLink(destination: CurrencyPickerView(viewModel: CurrencyPickerViewModel())) {
            Text("currency.change")
                .padding()
        }
    }
}
