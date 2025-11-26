//  WebViewControllerRepresentable.swift
//  TimeDiary

import SwiftUI

struct WebViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = WebViewController
    
    func makeUIViewController(context: Context) -> WebViewController {
        return WebViewController()
    }
    
    func updateUIViewController(_ uiViewController: WebViewController, context: Context) {}
}


