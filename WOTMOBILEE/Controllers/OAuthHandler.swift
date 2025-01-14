import UIKit
import Swifter
import WebKit
import AuthenticationServices

class OAuthHandler: NSObject {
    private let clientID = AppData.APPID// Twój application_id
    private let localRedirectURI = "http://127.0.0.1:8080/callback"
    private let authorizationEndpoint = "https://api.worldoftanks.eu/wot/auth/login/"
    private var httpServer: HttpServer?
    private var webAuthSession: ASWebAuthenticationSession?
    private var completion: ((Result<WargamingAuthResponse, Error>) -> Void)?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func startAuthentication(completion: @escaping (Result<WargamingAuthResponse, Error>) -> Void) {
        self.completion = completion
        
        // Startujemy zadanie w tle
        startBackgroundTask()
        
        do {
            // Na wszelki wypadek zatrzymaj stary serwer (jeśli istnieje)
            httpServer?.stop()
            
            // Inicjalizuj nowy serwer
            httpServer = HttpServer()
            
            // Konfiguracja endpointu /callback
            configureCallbackEndpoint()
            
            // Uruchom serwer
            try httpServer?.start(8080, forceIPv4: true)
            print("Serwer HTTP działa na porcie 8080")
            
            // Przygotowanie URL do logowania

          
            let loginURLString = "\(authorizationEndpoint)?application_id=\(clientID)&redirect_uri=\(localRedirectURI)&display=popup"
            
            guard let loginURL = URL(string: loginURLString) else {
                throw NSError(domain: "InvalidURL", code: -1, userInfo: nil)
            }
            
            // Użycie ASWebAuthenticationSession
            startWebAuthenticationSession(with: loginURL)
        } catch {
            print("Nie udało się uruchomić serwera HTTP: \(error.localizedDescription)")
            completion(.failure(error))
            endBackgroundTask()
        }
    }

    private func configureCallbackEndpoint() {
        httpServer?["/callback"] = { request in
            print("Otrzymano zapytanie na /callback")

            guard let wargamingAuthResponse = self.parseQuery(request.queryParams) else {
                DispatchQueue.main.async {
                    self.httpServer?.stop()
                    self.httpServer = nil
                    self.endBackgroundTask()
                    self.completion?(.failure(NSError(domain: "InvalidResponse", code: -5, userInfo: nil)))
                }
                return .ok(.html("Błąd uwierzytelniania. Spróbuj ponownie."))
            }

            DispatchQueue.main.async {
                self.httpServer?.stop()
                self.httpServer = nil
                self.endBackgroundTask()
                self.completion?(.success(wargamingAuthResponse))
            }
            
            DispatchQueue.main.async {
                self.webAuthSession?.cancel()
                self.webAuthSession = nil  // Zerowanie sesji
            }

            return .ok(.html("Uwierzytelnianie zakończone. Możesz wrócić do aplikacji."))
        }
    }

    private func parseQuery(_ queryItems: [(String, String)]) -> WargamingAuthResponse? {
        var queryParams = [String: String]()

        for (key, value) in queryItems {
            queryParams[key] = value
        }

        guard
            let status = queryParams["status"],
            let accessToken = queryParams["access_token"],
            let nickname = queryParams["nickname"],
            let accountId = queryParams["account_id"],
            let expiresAt = queryParams["expires_at"]
        else {
            return nil // Zwraca nil, jeśli brakuje któregokolwiek z wymaganych pól
        }

        return WargamingAuthResponse(
            status: status,
            access_token: accessToken,
            nickname: nickname,
            account_id: accountId,
            expires_at: expiresAt
        )
    }

    // MARK: - ASWebAuthenticationSession

    private func startWebAuthenticationSession(with url: URL) {
        webAuthSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: "http", // Scheme używany w callbacku
            completionHandler: { [weak self] callbackURL, error in
                guard let self = self else { return }
                if let error = error {
                    print("Błąd uwierzytelniania: \(error.localizedDescription)")
                    self.stopServer()
                    self.completion?(.failure(error))
                    self.endBackgroundTask()
                    return
                }
                
                self.endBackgroundTask()
            }
        )
        
        if #available(iOS 13.0, *) {
                webAuthSession?.prefersEphemeralWebBrowserSession = true
            }
        
        webAuthSession?.presentationContextProvider = self
        webAuthSession?.start()
    }

    // MARK: - Background Task Management

    private func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "HTTPServerBackgroundTask") {
            UIApplication.shared.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = .invalid
        }
        print("Rozpoczęto zadanie w tle: \(backgroundTask)")
    }

    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
            print("Zakończono zadanie w tle")
        }
    }

    func stopServer() {
        httpServer?.stop()
        httpServer = nil
        print("Serwer został zatrzymany")
        endBackgroundTask()
    }
    
    
}



    

extension OAuthHandler: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
}

