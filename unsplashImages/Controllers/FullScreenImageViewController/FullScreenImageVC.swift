//
//  FullScreenImageVC.swift
//  unsplashImages
//
//  Created by Keyur barvaliya on 14/04/24.
//

import UIKit

class FullScreenImageVC: UIViewController {
    
    var imageView = UIImageView()
    var photos: Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
//        if let urlString = self.photos?.urls["regular"], let url = URL(string: urlString) {
//            // Load image from URL
//            // Example: imageView.load(url: imageUrl)
//            
//        }
        
        // Check if the image is already cached
        if let cachedImage = ImageCache.shared.getImage(forKey: self.photos?.id ?? "") {
            // If cached, use the cached image
            self.imageView.image = cachedImage
        } else {
            // If not cached, set a placeholder image and start asynchronous image loading
            self.imageView.image = UIImage(named: "placeholder")
            
            if let urlString = self.photos?.urls["regular"], let url = URL(string: urlString) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            // Save the downloaded image to the cache
                            ImageCache.shared.setImage(image, forKey: self.photos?.id ?? "")
                            self.imageView.image = image
                        }
                    }
                }
            }
        }
        
//        // Add tap gesture recognizer to dismiss full screen
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissFullScreen))
//        view.addGestureRecognizer(tapGestureRecognizer)
        // Add close button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissFullScreen))
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    @objc func dismissFullScreen() {
        dismiss(animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
