//
//  BotAlert.swift
//  Starstruck
//
//  Created by Arhan Busam on 11/3/2023.
//

import UIKit

class BotAlert {
    
    struct Constants {
        static let backgroundAlphaTo: CGFloat = 0.6
    }
    
    private let backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0
        return backgroundView
    }()
    
    private let alertView: UIView = {
        let alert = UIView()
        alert.backgroundColor = .white
        alert.layer.masksToBounds = true
        alert.layer.cornerRadius = 12
        return alert
    }()
    
    private var targetView: UIView?
    private var vc: ChatViewController?
    
    func showAlert(with title: String, message: String, on viewController: ChatViewController) {
        guard let targetView = viewController.view else {
            return
        }
        
        self.targetView = targetView
        vc = viewController
        
        backgroundView.frame = targetView.bounds
        targetView.addSubview(backgroundView)
        targetView.addSubview(alertView)
        alertView.frame = CGRect(x: 40, y: -300, width: targetView.frame.size.width-80, height: 330)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: alertView.frame.size.width, height: 80))
        
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        alertView.addSubview(titleLabel)
        
        let messageLabel = UILabel(frame: CGRect(x: 20, y: 80, width: alertView.frame.size.width-40, height: 200))
        
        messageLabel.numberOfLines = 0
        messageLabel.text = message
        messageLabel.textAlignment = .left
        alertView.addSubview(messageLabel)
        
        let button = UIButton(frame: CGRect(x: 0, y: alertView.frame.size.height-50, width: alertView.frame.size.width, height: 50))
        
        button.setTitle("Got It", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        alertView.addSubview(button)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundView.alpha = Constants.backgroundAlphaTo
            viewController.messageInputBar.alpha = 0
        }, completion: { done in
            if done {
                UIView.animate(withDuration: 0.25, animations: {
                    self.alertView.center = targetView.center
                })
            }
        })
    }
    
    @objc func dismissAlert() {
        
        guard let targetView = self.targetView else {
            return
        }
        guard let viewController = self.vc else {
            return
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.alertView.frame = CGRect(x: 40, y: targetView.frame.size.height, width: targetView.frame.size.width-80, height: 300)
        }, completion: { done in
            if done {
                UIView.animate(withDuration: 0.25, animations: {
                    self.backgroundView.alpha = 0
                    viewController.messageInputBar.alpha = 1
                }, completion: { done in
                    self.alertView.removeFromSuperview()
                    self.backgroundView.removeFromSuperview()
                })
            }
        })
    }
    
}
