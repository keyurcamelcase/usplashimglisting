//
//  ToastView.swift
//  unsplashImages
//
//  Created by Keyur barvaliya on 14/04/24.
//

import UIKit

class ToastView: UIView {
    private let toastLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureSubviews()
    }
    
    private func configureSubviews() {
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        layer.cornerRadius = 10
        clipsToBounds = true
        
        addSubview(toastLabel)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            toastLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            toastLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            toastLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func setMessage(_ message: String) {
        toastLabel.text = message
    }
}

extension UIViewController {
    func showToast(message: String) {
        let toastView = ToastView()
        toastView.setMessage(message)
        
        view.addSubview(toastView)
        toastView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            toastView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -40)
        ])
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            toastView.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: .curveEaseInOut, animations: {
                toastView.alpha = 0.0
            }, completion: { _ in
                toastView.removeFromSuperview()
            })
        })
    }
}


