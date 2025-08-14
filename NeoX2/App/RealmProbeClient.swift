import Foundation

struct RealmProbeClient {
    enum ProbeError: Error { case invalidURL, noData }

    func fetchRealm(from urlString: String, timeout: TimeInterval = 4.0, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: urlString) else { completion(.failure(ProbeError.invalidURL)); return }
        var req = URLRequest(url: url)
        req.timeoutInterval = timeout
        req.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data, !data.isEmpty else { completion(.failure(ProbeError.noData)); return }

            // Try JSON first { "realm": "sony.net" }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let realm = json["realm"] as? String, !realm.isEmpty {
                completion(.success(realm))
                return
            }
            // Fallback: treat as plaintext
            if let text = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
                completion(.success(text))
                return
            }
            completion(.failure(ProbeError.noData))
        }
        task.resume()
    }
}

