//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by semrumyantsev on 21.08.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker


final class TrackersViewControllerSnapshotTests: XCTestCase {
    
    func testMainScreenSnapshot() {
        let VC = TrackersViewController()
        let navigationController = UINavigationController(rootViewController: VC)
        
        VC.loadViewIfNeeded()

        assertSnapshot(
            matching: navigationController,
            as: .image(on: .iPhone13),
            named: "main_screen",
            record: false
        )
    }
    
    func testMainScreenDarkTheme() {
           let VC = TrackersViewController()
           let navigationController = UINavigationController(rootViewController: VC)
           
           VC.loadViewIfNeeded()

           assertSnapshot(
               matching: navigationController,
               as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark)),
               named: "main_screen_dark",
               record: false
           )
       }
}
