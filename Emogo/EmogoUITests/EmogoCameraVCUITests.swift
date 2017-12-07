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
    
    func testOpenCamera(){
        let btnCamera        = app.navigationBars.buttons["camera icon"]
        let btnCaptureIcon   = app.buttons["capture icon"]

        let prediatForCamerabutton = NSPredicate(format: "isHittable == 1")
        expectation(for: prediatForCamerabutton, evaluatedWith: btnCamera, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        btnCamera.tap()
        
        XCTAssertTrue(btnCaptureIcon.exists, "btnCaptureIcon not exists , screen not moved to camera screen")
        
        sleep(2)
    }
    
    func testClickOnePicAndCheckItInCollectionView(){
        let btnCamera        = app.navigationBars.buttons["camera icon"]
        let btnCaptureIcon   = app.buttons["capture icon"]

        
        let prediatForCamerabutton = NSPredicate(format: "isHittable == 1")
        expectation(for: prediatForCamerabutton, evaluatedWith: btnCamera, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        btnCamera.tap()
        btnCaptureIcon.tap()
        
        let collectionView = app.collectionViews.element.children(matching:.any)
        
        sleep(1)
        XCTAssertTrue( (collectionView.allElementsBoundByAccessibilityElement.count == 1 ), "Collection view not appeared!")
        sleep(2)
        
    }
    
    func testClickTwoPhotosAndCheckThierPosition(){
        
        let btnCamera        = app.navigationBars.buttons["camera icon"]
        let btnCaptureIcon   = app.buttons["capture icon"]
        
        let prediatForCamerabutton = NSPredicate(format: "isHittable == 1")
        expectation(for: prediatForCamerabutton, evaluatedWith: btnCamera, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        btnCamera.tap()
        btnCaptureIcon.tap()
        
        let collectionView = app.collectionViews.element.children(matching:.any)
        
        let firstPic    =   collectionView.allElementsBoundByAccessibilityElement.first
        btnCaptureIcon.tap()
        let secondPic   =   collectionView.allElementsBoundByAccessibilityElement.first
        
        XCTAssertFalse(( firstPic == secondPic ), "Images are same that means updated image is not appearing in first position!")
        
        sleep(2)
        
    }
    
    func testImageGallery(){
        let btnCamera        = app.navigationBars.buttons["camera icon"]
        let prediatForCamerabutton = NSPredicate(format: "isHittable == 1")
        expectation(for: prediatForCamerabutton, evaluatedWith: btnCamera, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        btnCamera.tap()
        
        let btnGallery = app.buttons["add galery"]
        btnGallery.tap()
        let galleryNavBar = app.navigationBars["All Photos"]

        XCTAssertTrue(galleryNavBar.exists, "Gallery view not appeared on tap of gallery Icon")
    }
    
    func testChooseFromGallery(){
        let btnCamera        = app.navigationBars.buttons["camera icon"]
        let prediatForCamerabutton = NSPredicate(format: "isHittable == 1")
        expectation(for: prediatForCamerabutton, evaluatedWith: btnCamera, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        btnCamera.tap()
        
        let btnGallery = app.buttons["add galery"]
        btnGallery.tap()
        
        let gg = app.collectionViews.cells.element.children(matching: .any).element(boundBy: 0)
        
        if gg.exists {
            gg.forceTapElement()
        }
        let galleryNavBar = app.navigationBars["All Photos"]
        let btnSelect1     = galleryNavBar.buttons["Select(1)"]
        
        btnSelect1.tap()
        
        sleep(2)
    }
    
    func testChooseImageFromGalleryAndCheckItsPositionINCollectionView(){
        
        let btnCamera        = app.navigationBars.buttons["camera icon"]
        let btnCaptureIcon   = app.buttons["capture icon"]
        
        
        let prediatForCamerabutton = NSPredicate(format: "isHittable == 1")
        expectation(for: prediatForCamerabutton, evaluatedWith: btnCamera, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        btnCamera.tap()
        btnCaptureIcon.tap()
        
        let collectionView = app.collectionViews.element.children(matching:.any)
        
        sleep(1)
        XCTAssertTrue( (collectionView.allElementsBoundByAccessibilityElement.count == 1 ), "Collection view not appeared!")
        
        let picClicked  =   collectionView.allElementsBoundByAccessibilityElement.first
        
        let btnGallery = app.buttons["add galery"]
        btnGallery.tap()
        
        let gg = app.collectionViews.cells.element.children(matching: .any).element(boundBy: 0)
        
        if gg.exists {
            gg.forceTapElement()
        }
        let galleryNavBar = app.navigationBars["All Photos"]
        let btnSelect1     = galleryNavBar.buttons["Select(1)"]
        
        btnSelect1.tap()
        
        XCTAssertTrue( (collectionView.allElementsBoundByAccessibilityElement.count == 2 ), "Collection view does not have 2 images as expected!")
        
        let picChoosed  =   collectionView.allElementsBoundByAccessibilityElement.first

        XCTAssertFalse(( picClicked == picChoosed ), "Images are same that means updated image is not appearing in first position!")

        
        sleep(2)
    }
    
    func testVideoRecording(){

        let btnCamera        = app.navigationBars.buttons["camera icon"]
        
        let btnVideo    =   app.buttons["video icon"]
        let btnVideoPlay    =   app.buttons["video play"]
        let btnVideoStop    =   app.buttons["video stop"]
        
        let prediatForCamerabutton = NSPredicate(format: "isHittable == 1")
        expectation(for: prediatForCamerabutton, evaluatedWith: btnCamera, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        btnCamera.tap()

        XCTAssertTrue(btnVideo.exists, "camera button not exists , presented screen is not camera screen or btnVideo has been removed!")
        XCTAssertFalse(btnVideoPlay.exists, "btnVideoPlay should not be seen after the camera button tapped!")

        btnVideo.tap()
        
        XCTAssertTrue(btnVideoPlay.exists, "btnVideoPlay button not exists after btnVideo tappped")
        XCTAssertFalse(btnVideo.exists, "btnVideo should not be seen after the btnVideo button tapped!")
        
        btnVideoPlay.tap()
        
        XCTAssertTrue(btnVideoStop.exists, "btnVideoStop button not exists after btnVideoPlay tappped")
        XCTAssertFalse(btnVideoPlay.exists, "btnVideoPlay should not be seen after the btnVideoPlay button tapped!")
        
        sleep(2)
        
        btnVideoStop.tap()
        
        sleep(1)
        
        let collectionView = app.collectionViews.element.children(matching:.any)
        
        XCTAssertTrue((collectionView.allElementsBoundByAccessibilityElement.count == 1 ), "collectionView not exists after successfully stopped video recording as btnVideoStop tappped")
        XCTAssertFalse(btnVideoStop.exists, "btnVideoStop should not be seen after the btnVideoStop button tapped!")

        sleep(2)
        
        
    }
    
    func testBackActionFromCameraView(){
        
        
        let btnCamera        = app.navigationBars.buttons["camera icon"]
        let btnBack         =   app.buttons["white back icon"]
        
        
        let prediatForCamerabutton = NSPredicate(format: "isHittable == 1")
        expectation(for: prediatForCamerabutton, evaluatedWith: btnCamera, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
       
        btnCamera.tap()
        
        XCTAssertTrue(btnBack.exists, "btnBack not exists , might not be in Camera view")
        XCTAssertFalse(btnCamera.exists, "btnCamera should not be seen after the camera button tapped!")
        
        btnBack.tap()
        
        XCTAssertTrue(btnCamera.exists, "btnCamera not exists , might not be in Home Screen")
        XCTAssertFalse(btnBack.exists, "btnBack should not be seen after the btnBack button tapped!")
        
        sleep(2)
        
    }
    
    func testGetBackFromEditView(){
        let btnCamera        = app.navigationBars.buttons["camera icon"]
        let btnCaptureIcon   = app.buttons["capture icon"]
        let btnShare = app.buttons["share button"]
        let btnBackEditImage =  app.buttons["back circle icon"]

        
        let prediatForCamerabutton = NSPredicate(format: "isHittable == 1")
        expectation(for: prediatForCamerabutton, evaluatedWith: btnCamera, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        btnCamera.tap()
        btnCaptureIcon.tap()
        
        let collectionView = app.collectionViews.element.children(matching:.any)
        
        sleep(1)
        XCTAssertTrue( (collectionView.allElementsBoundByAccessibilityElement.count == 1 ), "Collection view not appeared!")

        btnShare.tap()
        
        let predicate   =  NSPredicate(format: "exists == 1")
        
        expectation(for: predicate, evaluatedWith: btnBackEditImage, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        btnBackEditImage.tap()
        
        XCTAssertTrue(btnShare.exists, "btnShare is not present not in Camer view")
        
        sleep(2)
        
    }
    
    func testBackkk(){
        XCUIApplication().buttons["back circle icon"].tap()
        
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
}

extension XCUIElement {

    func forceTapElement() {
        if self.isHittable {
            self.tap()
        }
        else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx:0.0, dy:0.0))
            coordinate.tap()
        }
    }
}

