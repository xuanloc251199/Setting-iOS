//
//  SettingsTopLevelPanesRenderTests.swift
//  SettingsTests
//

import XCTest

final class SettingsTopLevelPanesRenderTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // MARK: Interact with SLink buttons (Radio section)
        let buttons = ["Wi-Fi", "Bluetooth", "Cellular", "Battery"]
        
        for button in buttons {
            let btn = app.buttons[button]
            if !btn.exists {
                XCTAssertTrue(btn.exists, "\(button) does not exist")
            }
            btn.tap()
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }
    
    // MARK: Search TextField
    @MainActor
    func testSearchField() throws {
        let app = XCUIApplication()
        app.launch()
        
        let searchField = app.navigationBars.searchFields["Search"]
        XCTAssertTrue(searchField.exists, "Search field does not exist")
        
        searchField.tap()
        searchField.typeText("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        let cancelButton = app.buttons["Cancel"]
        cancelButton.firstMatch.tap()
    }
    
    // MARK: Search Suggestions Buttons
    @MainActor
    func testSearchSuggestions() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.searchFields["Search"].tap()
        let cancelButton = app.buttons["Cancel"]
        // Apps [by symbol image]
        app.buttons.images["app.grid.3x3"].tap()
        let settingsButton = app.buttons["Settings"]
        settingsButton.tap()
        // General [by symbol image]
        app.images.matching(identifier: "gear").element(boundBy: 1).tap()
        settingsButton.tap()
        // Accessibility [by text]
        app.staticTexts.matching(identifier: "Accessibility").element(boundBy: 1).tap()
        settingsButton.tap()
        // Privacy & Security [by text]
        app.staticTexts["Privacy & Security"].tap()
        settingsButton.tap()
        cancelButton.tap()
    }
    
    // MARK: Settings > General [Scrolling]
    @MainActor
    func testGeneral() throws {
        let app = XCUIApplication()
        app.launch()
        let elementsQuery = app.otherElements
        var element = elementsQuery.element(boundBy: 20)
        element.swipeUp()
        let generalButton = app.buttons["General"]
        XCTAssertTrue(generalButton.exists, "General link not found")
        generalButton.tap()
        element = elementsQuery.element(boundBy: 10)
        element.swipeUp()
    }
    
    // MARK: Check Accessibility Settings
    @MainActor
    func testSettingsAccessibilitySettingsExistence() throws {
        let app = XCUIApplication()
        app.launch()
        
        let accessibilityButton = app.buttons["Accessibility"].firstMatch
        if !accessibilityButton.exists {
            let elementsQuery = app.otherElements
            let element = elementsQuery.element(boundBy: 20)
            element.swipeUp()
        }
        XCTAssertTrue(accessibilityButton.exists, "Accessibility link not found")
        accessibilityButton.tap()
        let accessibilityTitle = app.staticTexts["Accessibility"]
        XCTAssertTrue(accessibilityTitle.exists, "Accessibility pane not found")
    }
    
    // MARK: Check Auto-Lock Settings
    @MainActor
    func testSettingsAutoLockSettingsExistence() throws {
        let app = XCUIApplication()
        app.launch()
        
        let accessibilityButton = app.buttons.containing(.image, identifier: "accessibility").firstMatch
        if !accessibilityButton.exists {
            let elementsQuery = app.otherElements
            let element = elementsQuery.element(boundBy: 20)
            element.swipeUp()
        } else {
            accessibilityButton.swipeUp()
        }
        let displayBrightnessButton = app.buttons["Display & Brightness"].staticTexts.firstMatch
        XCTAssertTrue(displayBrightnessButton.exists, "Display & Brightness link not found")
        displayBrightnessButton.tap()
        
        let brightnessHeader = app.staticTexts["BRIGHTNESS"]
        brightnessHeader.swipeUp()
        
        let autoLockButton = app.buttons.containing(.staticText, identifier: "Auto-Lock").firstMatch
        XCTAssertTrue(autoLockButton.exists, "Auto-Lock link not found")
        autoLockButton.tap()
    }
    
    // MARK: Check Control Center Settings
    @MainActor
    func testSettingsControlCenterExistence() throws {
        let app = XCUIApplication()
        app.launch()
        
        let accessibilityButton = app.buttons.containing(.image, identifier: "accessibility").firstMatch
        if !accessibilityButton.exists {
            let elementsQuery = app.otherElements
            let element = elementsQuery.element(boundBy: 20)
            element.swipeUp()
        } else {
            accessibilityButton.swipeUp()
        }
        
        let controlCenterButton = app.buttons["Control Center"].staticTexts.firstMatch
        XCTAssertTrue(controlCenterButton.exists, "Control Center link not found")
        controlCenterButton.tap()
        
        let navTitle = app.staticTexts["Control Center"]
        XCTAssertTrue(navTitle.exists, "Control Center title not found")
    }
    
    // MARK: Check Display Text Size Settings
    @MainActor
    func testSettingsDisplayTextSizeSettingsExistence() throws {
        let app = XCUIApplication()
        app.launch()
        
        let accessibilityButton = app.buttons.containing(.image, identifier: "accessibility").firstMatch
        if !accessibilityButton.exists {
            let elementsQuery = app.otherElements
            let element = elementsQuery.element(boundBy: 20)
            element.swipeUp()
        } else {
            accessibilityButton.swipeUp()
        }
        
        let displayBrightnessButton = app.buttons["Display & Brightness"].staticTexts.firstMatch
        XCTAssertTrue(displayBrightnessButton.exists, "Display & Brightness link not found")
        displayBrightnessButton.tap()
        
        let textSizeButton = app.buttons["Text Size"].staticTexts.firstMatch
        XCTAssertTrue(textSizeButton.exists, "Text Size link not found")
        textSizeButton.tap()
    }
    
    // MARK: Check Focus Settings Navigation
    @MainActor
    func testSettingsFocusNavigate() throws {
        let app = XCUIApplication()
        app.launch()
        
        let accessibilityButton = app.buttons.containing(.image, identifier: "accessibility").firstMatch
        if !accessibilityButton.exists {
            let elementsQuery = app.otherElements
            let element = elementsQuery.element(boundBy: 20)
            element.swipeUp()
        } else {
            accessibilityButton.swipeUp()
        }
        
        let focusButton = app.buttons["Focus"].staticTexts.firstMatch
        XCTAssertTrue(focusButton.exists, "Focus link not found")
        focusButton.tap()
    }
    
    @MainActor
    func testSettingsTopLevelAccessibilityIsRendered() throws {
        let app = XCUIApplication()
        app.launch()
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
