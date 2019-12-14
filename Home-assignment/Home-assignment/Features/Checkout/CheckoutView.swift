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
            Text("Checkout tutaj")
            CurrencyPickerView(viewModel: CurrencyPickerViewModel())
        }
        .navigationBarTitle("Super Checkout")
    }
}
