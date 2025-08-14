//
//  TrackerOnboarding.swift
//  Tracker
//
//  Created by semrumyantsev on 12.08.2025.
//

import UIKit

final class TrackerOnboarding: UIPageViewController {
    static let onboardingKey = "onboardingCompleted"
    
    lazy var pages: [UIViewController] = {
        let firstPage = createPage(
            imageName: "firstBackground",
            text: "Отслеживать только то что вы хотите",
            buttonTitle: "Вот это технологии"
        )
        
        let secondPage = createPage(
            imageName: "secondBackground",
            text: "Даже если это не литры воды и йога",
            buttonTitle: "Вот это технологии"
        )
        
        return [firstPage, secondPage]
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
        
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -168),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func createPage(imageName: String, text: String, buttonTitle: String) -> UIViewController {
        let VC = UIViewController()
        
        let image = UIImageView(image: UIImage(named: imageName))
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        VC.view.addSubview(image)
        
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        VC.view.addSubview(label)
        
        let button = UIButton(type: .system)
        button.setTitle(buttonTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        VC.view.addSubview(button)
        
        
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: VC.view.topAnchor),
            image.bottomAnchor.constraint(equalTo: VC.view.bottomAnchor),
            image.leadingAnchor.constraint(equalTo: VC.view.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: VC.view.trailingAnchor),
            
            button.bottomAnchor.constraint(equalTo: VC.view.bottomAnchor, constant: -84),
            button.leadingAnchor.constraint(equalTo: VC.view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: VC.view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 60),
            
            label.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -160),
            label.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            label.leadingAnchor.constraint(equalTo: button.leadingAnchor)
        ])
        
        return VC
    }
    
    @objc private func buttonTapped() {
        UserDefaults.standard.set(true, forKey: TrackerOnboarding.onboardingKey)
        dismiss(animated: true)
    }
}

extension TrackerOnboarding: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let VCIndex = pages.firstIndex(of: viewController) else { return nil}
        let previousIndex = VCIndex - 1
        
        if previousIndex < 0 {
            return pages.last
        } else {
            return pages[previousIndex]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let VCIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = VCIndex + 1
        
        if nextIndex >= pages.count {
            return pages.first
        } else {
            return pages[nextIndex]
        }
    }
}

extension TrackerOnboarding: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
