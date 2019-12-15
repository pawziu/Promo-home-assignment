//
//  CurrencyPickerView.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import SwiftUI

struct CurrencyPickerView: View {
    
    // MARK: - View model
    
    @ObservedObject var viewModel: CurrencyPickerViewModel
    
    // MARK: - Properties
    
    @Environment(\.presentationMode) var presentation
    
    // MARK: - Initialization
    
    init(viewModel: CurrencyPickerViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - View
    
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
        .navigationBarTitle("currency.change")
    }
}

#if DEBUG
struct CurrencyPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyPickerView(viewModel: CurrencyPickerViewModel())
            .environment(\.locale, .init(identifier: "en"))
    }
}
#endif
