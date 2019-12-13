//
//  ShoppingListView.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 13/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import SwiftUI

struct ShoppingListView: View {
    var strengths = ["Mild", "Medium", "Mature"]

    @State private var selectedStrength = 0
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Subviews.item
                    Subviews.item
                    Subviews.item
                    Subviews.item
                }
                Spacer()
                Subviews.basketLabel
                Subviews.basket
            }
            .navigationBarTitle("shoppingList.title")
            .navigationBarItems(trailing:
                HStack {
                    Button("Currency") {
                        print("Help tapped!")
                    }
                }
            )
        }
    }
}

private enum Subviews {
    
    static var basketLabel: some View {
        HStack {
            Text("🧺 Basket")
                .font(.largeTitle)
                .padding()
            Spacer()
            Text("Currency")
                .padding()
        }
    }
    
    static var basket: some View {
        List {
            Subviews.item
            Subviews.item
            Subviews.item
            Subviews.item
        }
    }
    
    static var item: some View {
        HStack {
            Text("🍏")
            Text("nazwa czegoś tam")
            Spacer()
            priceLabel
            Spacer()
            Text("➕")
        }
    }
    
    private static var priceLabel: some View {
        VStack {
            price
            quantityLabel
        }
    }
    
    private static var price: some View {
        HStack(alignment: .center, spacing: .zero) {
            Text("12.4")
            Text(String.space)
            Text("$")
        }
    }
    
    private static var quantityLabel: some View {
        HStack(alignment: .center, spacing: .zero) {
            Text("common.per")
                .font(.caption)
                .foregroundColor(.gray)
            Text(" ")
                .font(.caption)
                .foregroundColor(.gray)
            Text("bag")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView()
            .environment(\.locale, .init(identifier: "en"))
    }
}
