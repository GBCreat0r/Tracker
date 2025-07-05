//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by semrumyantsev on 03.07.2025.
//

import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    var backgroundImage = UIImageView()
    let emojiLabel = UILabel()
    let textLabel = UILabel()
    let counterLabel = UILabel()
    let checkButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundImage.backgroundColor = .blue
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.layer.cornerRadius = 16
        contentView.addSubview(backgroundImage)

        emojiLabel.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        emojiLabel.textAlignment = .center
        emojiLabel.clipsToBounds = true
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.text = "🥒"
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)

        textLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        textLabel.textColor = .white
        textLabel.text = "Trackers"
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)

        counterLabel.textColor = .black
        counterLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(counterLabel)
        
        checkButton.setImage(UIImage(resource: .plus), for: .normal)
        checkButton.backgroundColor = .blue
        checkButton.clipsToBounds = true
        checkButton.layer.cornerRadius = 17
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkButton)

    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImage.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: backgroundImage.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: backgroundImage.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            textLabel.leadingAnchor.constraint(equalTo: backgroundImage.leadingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(equalTo: backgroundImage.trailingAnchor, constant: -12),
            textLabel.bottomAnchor.constraint(equalTo: backgroundImage.bottomAnchor, constant: -12),
            
            checkButton.topAnchor.constraint(equalTo: backgroundImage.bottomAnchor, constant: 8),
            checkButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkButton.widthAnchor.constraint(equalToConstant: 34),
            checkButton.heightAnchor.constraint(equalToConstant: 34),
            
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            counterLabel.centerYAnchor.constraint(equalTo: checkButton.centerYAnchor),
            
        ])
    }
}

