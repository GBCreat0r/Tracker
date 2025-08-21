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
        // Given
        let VC = TrackersViewController()
        let navigationController = UINavigationController(rootViewController: VC)
        
        VC.loadViewIfNeeded()

        assertSnapshot(
            matching: navigationController,
            as: .image(on: .iPhone13),
            named: "main_screen",
            record: false // Измените на true для записи нового скриншота
        )
    }
}
