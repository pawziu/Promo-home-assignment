//
//  CurrencyPickerView.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import SwiftUI

struct CurrencyPickerView: View {
    @ObservedObject var viewModel: CurrencyPickerViewModel
    
    @Environment(\.presentationMode) var presentation
    
    init(viewModel: CurrencyPickerViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List {
            Section {
                ForEach(viewModel.currencies) { currency in
                    Button(currency.name) {
                        self.viewModel.selectedCurrency = currency
                        self.presentation.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationBarTitle("Change currency")
    }
}

struct CurrencyPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyPickerView(viewModel: CurrencyPickerViewModel())
            .environment(\.locale, .init(identifier: "en"))
    }
}
