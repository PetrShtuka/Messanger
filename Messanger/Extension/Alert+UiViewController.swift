//
//  Alert+UiViewController.swift
//  Messanger
//
//  Created by Peter on 06.05.2022.
//

import UIKit

extension UIViewController {
    
    func presentAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: title, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
