//
//  Bruit_BlancUITests.swift
//  Bruit BlancUITests
//
//  Created by Mathieu Dutour on 09/04/2022.
//

import XCTest

class Bruit_BlancUITests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    XCUIDevice.shared.orientation = .portrait

    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testExample() throws {
    // UI tests must launch the application that they test.
    let app = XCUIApplication()
    setupSnapshot(app)
    app.launch()

    addUIInterruptionMonitor(withDescription: "“Bruit Blanc” Would Like to Access the Microphone") { alert in
      alert.buttons.element(boundBy: 1).tap()
        return true
    }

    let scrollViewsQuery = app.scrollViews
    let elementsQuery = scrollViewsQuery.otherElements
    elementsQuery.buttons["Forest"].tap()
    elementsQuery.buttons["Birds"].tap()

    snapshot("0 - playing")

    app.buttons["Equalizer"].tap()
    app.sliders.firstMatch.adjust(toNormalizedSliderPosition: 0.7)

    snapshot("1 - equalizer")

    app.buttons["Decrescendo"].tap()

    snapshot("3 - decrescendo")

    app.navigationBars["Decrescendo"].buttons["Cancel"].tap()

    app.navigationBars["Equalizer"].buttons["Done"].tap()
    scrollViewsQuery.otherElements.containing(.staticText, identifier:"Noises").element.swipeUp()
    elementsQuery.buttons["New"].tap()

    let recordButton = app.buttons["Record"]
    recordButton.tap()

    recordButton.tap()

    snapshot("2 - record")

    app.textFields["My Shhhh"].tap()
    app.textFields["My Shhhh"].typeText("Shhhhh")

    app.navigationBars["Recorder"].buttons["Save"].tap()

    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }

  func testLaunchPerformance() throws {
    if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
        // This measures how long it takes to launch your application.
      measure(metrics: [XCTApplicationLaunchMetric()]) {
        XCUIApplication().launch()
      }
    }
  }
}
