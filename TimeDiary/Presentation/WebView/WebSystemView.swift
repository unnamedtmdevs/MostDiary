//  WebSystemView.swift
//  TimeDiary

import SwiftUI

struct WebSystemView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all)
            
            WebViewControllerRepresentable()
        }
    }
}

#Preview {
    WebSystemView()
}


