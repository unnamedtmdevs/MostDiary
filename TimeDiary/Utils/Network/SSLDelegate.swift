//  SSLDelegate.swift
//  TimeDiary

import Foundation

// SSL Delegate для обработки сертификатов
class SSLDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Принимаем любые сертификаты (только для разработки!)
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}


