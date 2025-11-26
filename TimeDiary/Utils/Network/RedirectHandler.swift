//  RedirectHandler.swift
//  TimeDiary

import Foundation

// Класс для отключения автоматических редиректов
class RedirectHandler: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        // Возвращаем nil, чтобы НЕ следовать редиректу
        completionHandler(nil)
    }
}


