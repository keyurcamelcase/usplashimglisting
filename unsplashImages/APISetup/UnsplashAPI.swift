//
//  UnsplashAPI.swift
//  unsplashImages
//
//  Created by Keyur barvaliya on 13/04/24.
//
import Foundation
import UIKit

class UnsplashAPI {
    static let baseURLString = "https://api.unsplash.com"
    static let accessKey = "JRuCw14Oq9hZbF8Ih3V8rVJJSNNzJsqcUN3LNluFemI" // Replace with your actual access key
    
    enum APIError: Error {
            case invalidURL
            case requestFailed(Error)
            case invalidResponse
            case decodingFailed(Error)
        }
    
    static func fetchPhotos(page: Int, perPage: Int, completion: @escaping (Result<[Photo], APIError>) -> Void) {
        guard var urlComponents = URLComponents(string: baseURLString + "/photos") else {
            completion(.failure(.invalidURL))
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "client_id", value: accessKey)
        ]
        
        guard let url = urlComponents.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let photos = try JSONDecoder().decode([Photo].self, from: data)
                
                // Preload images into cache
                preloadImages(for: photos)
                
                completion(.success(photos))
            } catch {
                completion(.failure(.decodingFailed(error)))
            }
        }
        
        task.resume()
    }
    
    static func preloadImages(for photos: [Photo]) {
        for photo in photos {
            guard let urlString = photo.urls["regular"], let url = URL(string: urlString) else {
                continue
            }
            
            // Check if image is already cached
            if ImageCache.shared.getImage(forKey: urlString) == nil {
                // If not cached, fetch image and add to cache
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    ImageCache.shared.setImage(image, forKey: urlString)
                }
            }
        }
    }
}

