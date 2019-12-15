//
//  ShoppingListView.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 13/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import SwiftUI
import Combine

struct ShoppingListView: View {
    
    private enum Configuration {
        static var sumUpBackgroundOpacity: Double { 0.1 }
    }
    
    // MARK: - View model
    
    @ObservedObject var viewModel: ShoppingListViewModel

    // MARK: - Initialization
    
    init(viewModel: ShoppingListViewModel) {
      self.viewModel = viewModel
    }
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    shoppingListSection
                }
                basketLabel
            }
            .buttonStyle(BorderlessButtonStyle())  
            .navigationBarTitle("shoppingList.title")
        }
    }
    
    private var shoppingListSection: some View {
      Section {
        ForEach(viewModel.dataSource, content: ProductView.init(viewModel:))
      }
    }
    
    private var basketLabel: some View {
        VStack {
            HStack {
                Text("Total")
                    .padding()
                Spacer()
                Text(viewModel.totalAmount.formattedAmount + .space + viewModel.currencyName)
                    .padding()
            }
            HStack {
                changeCurrencyButton
                    .padding(.leading)
                Spacer()
                checkoutButton
                    .padding(.trailing)
            }
        }
        .background(
            Color.gray
                .opacity(Configuration.sumUpBackgroundOpacity)
        )
    }
    
    private var checkoutButton: some View {
        NavigationLink(destination: CheckoutView(viewModel: checkoutViewModel)) {
            Text("Checkout")
                .padding()
        }
    }
    
    private var checkoutViewModel: CheckoutViewModel {
        CheckoutViewModel(
            products: viewModel.checkoutItems,
            totalAmount: viewModel.totalAmount,
            currencyName: viewModel.currencyName
        )
    }
    
    private var changeCurrencyButton: some View {
        NavigationLink(destination: CurrencyPickerView(viewModel: CurrencyPickerViewModel())) {
            Text("Change currency")
                .padding()
        }
    }
    
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView(viewModel: ShoppingListViewModel())
            .environment(\.locale, .init(identifier: "en"))
    }
}
#endif
