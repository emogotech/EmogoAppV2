//
//  EmogoCameraVCUITests.swift
//  EmogoUITests
//
//  Created by Sourabh on 04/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import XCTest
//@testable import Emogo

class EmogoCameraVCUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app     =       XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
        app         = nil
    }
    
    func testCamera_Capture_Image_And_Edit_With_A_Line_And_SaveToPhotoLibrary(){
        
        sleep(2)
        app.navigationBars.buttons["camera icon"].tap()
        app.buttons["capture icon"].tap()
        sleep(1)
        app.buttons["share button"].tap()
        
        let editIconButton = app.buttons["edit icon"]
        
        let predicate   =  NSPredicate(format: "exists == 1")
        
        expectation(for: predicate, evaluatedWith: editIconButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        editIconButton.tap()

        
        let pencilButton = app.buttons["pencil icon"]
        expectation(for: predicate, evaluatedWith: pencilButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        pencilButton.tap()
        
        sleep(1)
        
        
        let cooridnate1 = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: 20 , dy: 100))
        let cooridnate2 = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: 40 , dy: 300))
        let cooridnate3 = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: 70 , dy: 200))


        cooridnate1.tap()
        cooridnate2.tap()
        cooridnate3.tap()
        
        cooridnate1.press(forDuration: TimeInterval.init(exactly: 0)!, thenDragTo: cooridnate2)
        cooridnate2.press(forDuration: TimeInterval.init(exactly: 0)!, thenDragTo: cooridnate3)
        
        sleep(1)

        let btnEditingDone = app.buttons["editing done icon"]
        btnEditingDone.tap()
        let btnDownload = app.buttons["download icon"]
        btnDownload.tap()

    }
    
    func testCamera_Capture_Image_And_Edit_With_A__Color_Line_And_SaveToPhotoLibrary(){
        
        sleep(2)
        app.navigationBars.buttons["camera icon"].tap()
        app.buttons["capture icon"].tap()
        sleep(1)
        app.buttons["share button"].tap()
        
        let editIconButton = app.buttons["edit icon"]
        
        let predicate   =  NSPredicate(format: "exists == 1")
        
        expectation(for: predicate, evaluatedWith: editIconButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        editIconButton.tap()
        
        
        let pencilButton = app.buttons["pencil icon"]
        expectation(for: predicate, evaluatedWith: pencilButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        pencilButton.tap()
        
        sleep(1)
        
        
        let cooridnate1 = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: 20 , dy: 100))
        let cooridnate2 = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: 40 , dy: 300))
        let cooridnate3 = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: 70 , dy: 200))
        
        
        cooridnate1.tap()
        cooridnate2.tap()
        cooridnate3.tap()
        
        cooridnate1.press(forDuration: TimeInterval.init(exactly: 0)!, thenDragTo: cooridnate2)
        cooridnate2.press(forDuration: TimeInterval.init(exactly: 0)!, thenDragTo: cooridnate3)
        
        sleep(1)
        let colorBucketIconUnactiveButton = app.buttons["color bucket icon unactive"]
        colorBucketIconUnactiveButton.tap()
        
        
        let collectionView = app.collectionViews.element.children(matching:.any)
        let count = collectionView.count
        print(count)
        
        for cell in  collectionView.allElementsBoundByAccessibilityElement {
            cell.tap()
            
            sleep(1)
            cooridnate1.press(forDuration: TimeInterval.init(exactly: 0)!, thenDragTo: cooridnate2)
            cooridnate2.press(forDuration: TimeInterval.init(exactly: 0)!, thenDragTo: cooridnate3)
        }
        
        
        sleep(1)
        
        let btnEditingDone = app.buttons["editing done icon"]
        btnEditingDone.tap()
        let btnDownload = app.buttons["download icon"]
        btnDownload.tap()
        
    }
    
    func testForSave(){
        
        sleep(2)
        app.navigationBars.buttons["camera icon"].tap()
        app.buttons["capture icon"].tap()
        sleep(1)
        app.buttons["share button"].tap()
        app.buttons["edit icon"].tap()
        app.buttons["pencil icon"].tap()
        
        let colorBucketIconUnactiveButton = app.buttons["color bucket icon unactive"]
        colorBucketIconUnactiveButton.tap()
        
        let colorBucketIconButton = app.buttons["color bucket icon"]
        colorBucketIconButton.tap()
        
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element
        let collectionView = element.children(matching: .other).element(boundBy: 1).children(matching: .collectionView).element
      
        collectionView.tap()
        collectionView.swipeLeft()

        
        let penIconUnactiveButton = app.buttons["pen icon unactive"]
        penIconUnactiveButton.tap()
        app.buttons["pen big"].tap()
        element.children(matching: .other).element(boundBy: 0).children(matching: .image).element(boundBy: 1).swipeRight()
        penIconUnactiveButton.tap()
        app.buttons["pen medium"].tap()
        penIconUnactiveButton.tap()
        
        let penSmallButton = app.buttons["pen small"]
        penSmallButton.tap()
        penIconUnactiveButton.tap()
        penSmallButton.tap()
        
    }

    
    func testCamera_With_Timer(){
        sleep(2)
        
        app.navigationBars.buttons["camera icon"].tap()
        let btnTimer = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element.children(matching: .button).element(boundBy: 3)
        btnTimer.tap()
        
        let selectTimeSheet = app.sheets["Select Time"]
        let cancelButton = selectTimeSheet.buttons["Cancel"]
        cancelButton.tap()
        btnTimer.tap()
        cancelButton.tap()
        btnTimer.tap()
        selectTimeSheet.buttons["5s"].tap()
        
        sleep(8)
    }
    
    func testCamera_With_Timer_And_Save(){
        sleep(2)
        
        app.navigationBars.buttons["camera icon"].tap()
        let btnTimer = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element.children(matching: .button).element(boundBy: 3)
        btnTimer.tap()
        
        let selectTimeSheet = app.sheets["Select Time"]
        let cancelButton = selectTimeSheet.buttons["Cancel"]
        cancelButton.tap()
        btnTimer.tap()
        cancelButton.tap()
        btnTimer.tap()
        selectTimeSheet.buttons["5s"].tap()
        
        sleep(8)
        
        app.buttons["share button"].tap()
        
        let titleYourImageTextField = app.textFields["Title your Image"]
        titleYourImageTextField.clearAndEnterText(text: "Sourabh")
        titleYourImageTextField.typeText("\n")
        
        
        let descriptionTextTextField = app.textFields["Description text"]
        descriptionTextTextField.clearAndEnterText(text: "Sourabh Desc")
        app.typeText("\n")
        
        let doneButton = app.buttons["  Done"]
        doneButton.tap()
    }
    
    func testCamera_Capture_Live_Image_And_Save(){
        
        sleep(2)
        app.navigationBars.buttons["camera icon"].tap()
        app.buttons["capture icon"].tap()
        app.buttons["share button"].tap()
        
        let titleYourImageTextField = app.textFields["Title your Image"]
        titleYourImageTextField.clearAndEnterText(text: "Sourabh")
        titleYourImageTextField.typeText("\n")
        
        
        let descriptionTextTextField = app.textFields["Description text"]
        descriptionTextTextField.clearAndEnterText(text: "Sourabh Desc")
        app.typeText("\n")
        
        let doneButton = app.buttons["  Done"]
        doneButton.tap()
        doneButton.tap()
        
    }
    
    func testCamera_Capture_Live_Image_And_Save_It_With_Text(){
        
        sleep(2)
        app.navigationBars.buttons["camera icon"].tap()
        app.buttons["capture icon"].tap()

        app.buttons["share button"].tap()

        let editIconButton = app.buttons["edit icon"]

        let predicate   =  NSPredicate(format: "exists == 1")

        expectation(for: predicate, evaluatedWith: editIconButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)

        editIconButton.tap()
        
        let textIconButton = app.buttons["text icon"]
        textIconButton.tap()
        
        
        let textView = XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .image).element(boundBy: 1).children(matching: .textView).element
        textView.clearAndEnterText(text: "Sourabh")
        sleep(2)
        
        textView.typeText("\n")
        
        let downladBtn = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 4)
        downladBtn.tap()
    }
    
    func testRecord(){
        sleep(2)
        app.navigationBars.buttons["camera icon"].tap()
        app.buttons["add galery"].tap()
        sleep(1)
        let firstChild = app.collectionViews.element.children(matching:.any).element(boundBy: 0)
        if firstChild.exists == true {
            firstChild.tap()
        }
        //        app.navigationBars["All Photos"].buttons["Select(1)"].tap()
        sleep(2)
    }
    
    func testSignInForCameraTest(){
        
        sleep(1)
        let homeIconActiveNavBar = app.navigationBars["home icon active"]
        let homeButton = homeIconActiveNavBar.buttons["home icon active"]
        
        if homeButton.exists{
            print("HOme :)")
            
            app.navigationBars.buttons["camera icon"].tap()
            
            
            let bb = app.alerts.staticTexts["“Emogo” Would Like to Access the Camera"]
            
            addUIInterruptionMonitor(withDescription: "“Emogo” Would Like to Access the Camera") { (alert) -> Bool in
                print("emogo")
                return true
            }

            if bb.exists {
                print(bb)
            }
            
            let accessCameraAlert = app.alerts["“Emogo” Would Like to Access the Camera"].buttons["OK"]
            sleep(2)
            if accessCameraAlert.exists {
                accessCameraAlert.tap()
            }
            
            let accessMicroPhone = app.alerts["“Emogo” Would Like to Access the Microphone"].buttons["OK"]
            sleep(1)
            if accessMicroPhone.exists {
                accessMicroPhone.tap()
            }
            sleep(1)
            
            let btnGallery = app.buttons["add galery"]
            
            if btnGallery.exists {
                btnGallery.tap()
            }
            sleep(1)
            
            let alertAccessPhotos = app.alerts["“Emogo” Would Like to Access Your Photos"].buttons["OK"]
            sleep(2)
            if alertAccessPhotos.exists {
                alertAccessPhotos.tap()
                sleep(2)
            }
        }
        
    }
    
    func test(){
        sleep(1)
        app.buttons["sign up btn"].tap()
        
        sleep(2)

        let lblChooseUserName = app.staticTexts["Choose a User Name"]
        
        if lblChooseUserName.exists {
            let txtUserName = app.textFields["Your text here"]
            txtUserName.tap()
            
            txtUserName.clearAndEnterText(text: "Nihir101")
            
            let btnNext     =   app.buttons["next btn"]
            btnNext.tap()
            
            sleep(2)

            let lblEnterPhone = app.staticTexts["Enter Your Phone Number"]
            
            if lblEnterPhone.exists   {
                let txtPhoneNumber = app.textFields["Please enter phone number"]
                txtPhoneNumber.clearAndEnterText(text: "7509820455")
                let btnTextCode     =   app.buttons["text me my code btn"]
                btnTextCode.tap()
                sleep(2)
                
                let lblTextedCode = app.staticTexts["We texted you a 5 digit code. Please enter it below."]
                if lblTextedCode.exists {
                    let strOTP : String  =  UserDefaults.standard.string(forKey: "OTP")!   //SharedData.sharedInstance.strSignUpOTP
                    
                    
                    let txtOTPCode = app.textFields["Please enter the code"]
                    txtOTPCode.typeText(strOTP)
                    app.buttons["done btn"].tap()
                    sleep(2)
                    let homeButton = app.navigationBars["home icon active"]
                    if homeButton.exists {
                        print("HOme :)")
                        
                        app.navigationBars.buttons["camera icon"].tap()

                        
                        let accessCameraAlert = app.alerts["“Emogo” Would Like to Access the Camera"].buttons["OK"]
                        sleep(1)
                        if accessCameraAlert.exists {
                            accessCameraAlert.tap()
                        }
                        
                        let accessMicroPhone = app.alerts["“Emogo” Would Like to Access the Microphone"].buttons["OK"]
                        sleep(1)
                        if accessMicroPhone.exists {
                            accessMicroPhone.tap()
                        }
                        sleep(1)
                        
                        let btnGallery = app.buttons["add galery"]
                            
                        if btnGallery.exists {
                            btnGallery.tap()
                        }
                        sleep(1)
                        
                        let alertAccessPhotos = app.alerts["“Emogo” Would Like to Access Your Photos"].buttons["OK"]
                        
                        if alertAccessPhotos.exists {
                            alertAccessPhotos.tap()
                        }
                    }

                    
                }



            }

        }
    }
    
    func testEmogoCamerVC_HappyUITest() {
        
//        let app2 = app
//        let app = app2
        app.buttons["sign up btn"].tap()
        
        let chooseAUserNameStaticText = app.staticTexts["Choose a User Name"]
        chooseAUserNameStaticText.tap()
        chooseAUserNameStaticText.tap()
        
        let yourTextHereTextField = app.textFields["Your text here"]
        yourTextHereTextField.tap()
        XCUIDevice.shared.orientation = .portrait
        
        let shiftButton = app/*@START_MENU_TOKEN@*/.keyboards.buttons["shift"]/*[[".keyboards.buttons[\"shift\"]",".buttons[\"shift\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/
        shiftButton.tap()
        yourTextHereTextField.typeText("Nihir")
        app.buttons["next btn"].tap()
        
        let enterYourPhoneNumberStaticText = app.staticTexts["Enter Your Phone Number"]
        enterYourPhoneNumberStaticText.tap()
        enterYourPhoneNumberStaticText.tap()
        
        let pleaseEnterPhoneNumberTextField = app.textFields["Please enter phone number"]
        pleaseEnterPhoneNumberTextField.tap()
        pleaseEnterPhoneNumberTextField.typeText("75098220455")
        
        let deleteKey = app/*@START_MENU_TOKEN@*/.keys["Delete"]/*[[".keyboards.keys[\"Delete\"]",".keys[\"Delete\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        pleaseEnterPhoneNumberTextField.typeText("0455")
        app.buttons["text me my code btn"].tap()
        
        let weTextedYouA5DigitCodePleaseEnterItBelowStaticText = app.staticTexts["We texted you a 5 digit code. Please enter it below."]
        weTextedYouA5DigitCodePleaseEnterItBelowStaticText.tap()
        weTextedYouA5DigitCodePleaseEnterItBelowStaticText.tap()
        
        let pleaseEnterTheCodeTextField = app.textFields["Please enter the code"]
        pleaseEnterTheCodeTextField.tap()
        pleaseEnterTheCodeTextField.typeText("51726")
        app.buttons["done btn"].tap()
        
        let homeIconActiveNavigationBar = app.navigationBars["home icon active"]
        let homeIconActiveButton = homeIconActiveNavigationBar.buttons["home icon active"]
        homeIconActiveButton.tap()
        homeIconActiveButton.tap()
        XCUIDevice.shared.orientation = .faceUp
        XCUIDevice.shared.orientation = .portrait
        homeIconActiveNavigationBar.buttons["camera icon"].tap()
        XCUIDevice.shared.orientation = .faceUp
        XCUIDevice.shared.orientation = .portrait
        app.alerts["“Emogo” Would Like to Access the Camera"].buttons["OK"].tap()
        app.alerts["“Emogo” Would Like to Access the Microphone"].buttons["OK"].tap()
        app.buttons["add galery"].tap()
        app.alerts["“Emogo” Would Like to Access Your Photos"].buttons["OK"].tap()
        
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element
        let element2 = element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        let collectionView = element2.children(matching: .other).element.children(matching: .collectionView).element
        collectionView.tap()
        collectionView.tap()
        collectionView.tap()
        app.navigationBars["All Photos"].buttons["Select(1)"].tap()
        element2.children(matching: .other).element(boundBy: 3).children(matching: .collectionView).element.tap()
        app.buttons["share button"].tap()
        app.buttons["edit icon"].tap()
        app.buttons["pencil icon"].tap()
        app.buttons["pen icon unactive"].tap()
        app.buttons["pen big"].tap()
        element/*@START_MENU_TOKEN@*/.press(forDuration: 4.8);/*[[".tap()",".press(forDuration: 4.8);"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        app.buttons["editing done icon"].tap()
        XCUIDevice.shared.orientation = .faceUp
        XCUIDevice.shared.orientation = .portrait
        app.buttons["download icon"].tap()
        app.buttons["editing cross icon"].tap()
        XCUIDevice.shared.orientation = .faceUp
        XCUIDevice.shared.orientation = .portrait
        
        let titleYourImageTextField = app.textFields["Title your Image"]
        titleYourImageTextField.tap()
        shiftButton.tap()
        titleYourImageTextField.typeText("Sour")
        shiftButton.tap()
        
        let sourabhElement = app/*@START_MENU_TOKEN@*/.otherElements["Sourabh"]/*[[".keyboards",".otherElements[\"Typing Predictions\"].otherElements[\"Sourabh\"]",".otherElements[\"Sourabh\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        sourabhElement.tap()
        
        let deleteKey2 = app/*@START_MENU_TOKEN@*/.keys["delete"]/*[[".keyboards.keys[\"delete\"]",".keys[\"delete\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        deleteKey2.tap()
        deleteKey2.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Next:"]/*[[".keyboards",".buttons[\"Next\"]",".buttons[\"Next:\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let descriptionTextTextField = app.textFields["Description text"]
        descriptionTextTextField.typeText("\n")
        shiftButton.tap()
        descriptionTextTextField.typeText("Spu")
        app/*@START_MENU_TOKEN@*/.keys["r"]/*[[".keyboards.keys[\"r\"]",".keys[\"r\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        descriptionTextTextField.typeText("ra")
        sourabhElement.tap()
        descriptionTextTextField.typeText(" desc")
        app/*@START_MENU_TOKEN@*/.buttons["Done"]/*[[".keyboards.buttons[\"Done\"]",".buttons[\"Done\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.typeText("\n")
        app.buttons["  Done"].tap()
        
        let statusBarsQuery = app.statusBars
        statusBarsQuery.otherElements["1:14 PM"].tap()
        XCUIDevice.shared.orientation = .faceUp
        XCUIDevice.shared.orientation = .portrait
        app.buttons["up arrow"].tap()
        XCUIDevice.shared.orientation = .faceUp
        XCUIDevice.shared.orientation = .portrait
        app.buttons["back circle icon"].tap()
        XCUIDevice.shared.orientation = .faceUp
        
        let noSimElement = statusBarsQuery.otherElements["No SIM"]
        noSimElement.tap()
        noSimElement.tap()
        noSimElement.tap()
        noSimElement.tap()
        noSimElement.tap()
        app.buttons["white back icon"].tap()
        noSimElement.tap()
        homeIconActiveNavigationBar.buttons["my profile"].tap()
        XCUIDevice.shared.orientation = .faceUp
        XCUIDevice.shared.orientation = .faceUp
        XCUIDevice.shared.orientation = .portrait
        app/*@START_MENU_TOKEN@*/.scrollViews.otherElements.collectionViews.containing(.cell, identifier:"NotificationCell").element/*[[".windows[\"SBCoverSheetWindow\"].scrollViews.otherElements",".collectionViews.containing(.cell, identifier:\"TIPS, Wed 2:05 PM, See what’s new in iOS 11, Discover new features you’ll ❤️\").element",".collectionViews.containing(.cell, identifier:\"NotificationCell\").element",".scrollViews.otherElements"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        XCUIDevice.shared.orientation = .portrait
        XCUIDevice.shared.orientation = .portrait
        XCUIDevice.shared.orientation = .faceUp
        
    }
    
    //        app.alerts["“Emogo” Would Like to Add to your Photos"].buttons["OK"].tap()

    
}
