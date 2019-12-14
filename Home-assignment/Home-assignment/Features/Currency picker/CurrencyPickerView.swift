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
    
    init(viewModel: CurrencyPickerViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Form {
            Section {
                Picker("Currency", selection: $viewModel.selectedCurrency) {
                    ForEach(viewModel.currencies) {
                        Text($0.name).tag($0)
                    }
                }
            }
        }
    }
}

struct CurrencyPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyPickerView(viewModel: CurrencyPickerViewModel())
            .environment(\.locale, .init(identifier: "en"))
    }
}
