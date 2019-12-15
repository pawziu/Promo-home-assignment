//
//  CircleImage.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import SwiftUI

struct CircleImage: View {
    
    private enum Configuration {
        static var strokeLineWidth: CGFloat { 4.0 }
        static var shadowRadius: CGFloat { 10.0 }
    }
    
    // MARK: - Properties
    
    private let imageName: String
    
    init(imageName: String) {
        self.imageName = imageName
    }
    var body: some View {
        Image(imageName)
            .resizable()
            .clipShape(Circle())
            .overlay(
                Circle().stroke(Color.white, lineWidth: Configuration.strokeLineWidth)
            )
            .shadow(radius: Configuration.shadowRadius)
            .aspectRatio(contentMode: .fill)
    }
}

struct CircleImage_Preview: PreviewProvider {
    static var previews: some View {
        CircleImage(imageName: "peas")
    }
}
