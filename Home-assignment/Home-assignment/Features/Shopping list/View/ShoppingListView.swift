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
    @ObservedObject var viewModel: ShoppingListViewModel
    
    @State private var isCurrencyPickerPresented = false
    @State private var pickedCurrency: Currency = .default

    init(viewModel: ShoppingListViewModel) {
      self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    shoppingListSection
                }
                basketLabel
            }
            .navigationBarTitle("shoppingList.title")
        }
    }
    
    private var shoppingListSection: some View {
      Section {
        ForEach(viewModel.dataSource, content: ProductView.init(item:))
      }
    }
    
    private var basketLabel: some View {
        HStack {
            Text("🧺 Total")
                .font(.largeTitle)
                .padding()
            Spacer()
            Text(viewModel.totalAmount.formattedAmount)
                .padding()
            checkoutButton
        }
        .background(Color.gray.opacity(0.3))
    }
    
    private var checkoutButton: some View {
        NavigationLink(destination: ShoppingListView.checkoutDestination)  {
            Text("Checkout")
                .padding()
        }
    }
    
    static private var checkoutDestination: some View {
        CheckoutView(viewModel: CheckoutViewModel())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView(viewModel: ShoppingListViewModel())
            .environment(\.locale, .init(identifier: "en"))
    }
}
