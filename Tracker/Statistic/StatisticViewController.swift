//
//  StatisticViewController.swift
//  Tracker
//
//  Created by semrumyantsev on 23.06.2025.
//

import UIKit

final class StatisticViewController: UIViewController {
    private var fakeLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
        fakeLabel = UILabel()
        guard let fakeLabel else { print("Pen") ; return}
        fakeLabel.text = "Stat"
        fakeLabel.textColor = .white
        fakeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fakeLabel)
        
        NSLayoutConstraint.activate([
            fakeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fakeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
