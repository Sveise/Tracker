//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Svetlana Varenova on 03.11.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testViewControllerSnapshot() {
        let vc = TrackersViewController()
        ///isRecording = true
        assertSnapshot(matching: vc, as: .image(on: .iPhone13))
    }
    
    func testViewControllerDarkTheme() {
        let vc = TrackersViewController()
        //isRecording = true
        assertSnapshot(matching: vc, as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark)))
    }
    
    func testViewControllerLightTheme() {
        let vc = TrackersViewController()
        //isRecording = true
        assertSnapshot(matching: vc, as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light)))
    }
}
