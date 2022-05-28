//
//  UIViewController+ActivityIndicator.swift
//  QueUp
//
//  Created by Louis Menacho on 5/26/22.
//

import Foundation
import NVActivityIndicatorView

extension UIViewController {
    
    func showActivityIndicator() {
        let activityIndicatorView = NVActivityIndicatorView(frame: view.frame, type: .ballPulse, color: .init(white: 1, alpha: 1), padding: view.frame.width/2.5)
        activityIndicatorView.backgroundColor = .init(white: 0, alpha: 0.5)
        DispatchQueue.main.async {
            self.navigationController?.view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
        }
    }
    
    func hideActivityIndicator() {
        let activityIndicatorView = navigationController?.view.subviews.first(where: { $0 is NVActivityIndicatorView }) as? NVActivityIndicatorView
        DispatchQueue.main.async {
            activityIndicatorView?.removeFromSuperview()
            activityIndicatorView?.stopAnimating()
        }
    }
}
