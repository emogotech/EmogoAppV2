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
    
    //MARK:- Edit Image
    func testToPerformHAppyCase(){
        let btnSignIn = app.buttons["sign in btn"]
        let txtPhone = app.textFields["Please enter phone number"]
        let btnDone = app.buttons["done btn"]
        
        let btnCamera        = app.navigationBars.buttons["camera icon"]
        let btnCaptureIcon   = app.buttons["capture icon"]

        let btnShare = app.buttons["share button"]
 


        
        let prediatForHittable = NSPredicate(format: "isHittable == 1")
//        expectation(for: prediatForHittable, evaluatedWith: btnSignIn, handler: nil)
//        waitForExpectations(timeout: 10, handler: nil)
//        btnSignIn.tap()
//
//        expectation(for: prediatForHittable, evaluatedWith: txtPhone, handler: nil)
//        waitForExpectations(timeout: 10, handler: nil)
//        txtPhone.clearAndEnterText(text: "7389020926")
//        btnDone.tap()
        
//        sleep(2)
        expectation(for: prediatForHittable, evaluatedWith: btnCamera, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        btnCamera.tap()
        
        
        expectation(for: prediatForHittable, evaluatedWith: btnCaptureIcon, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        btnCaptureIcon.tap()

        let collectionView = app.collectionViews.element.children(matching:.any)

        sleep(1)
        XCTAssertTrue( (collectionView.allElementsBoundByAccessibilityElement.count == 1 ), "Collection view not appeared!")

        let picClicked  =   collectionView.allElementsBoundByAccessibilityElement.first

        let btnGallery = app.buttons["add galery"]
        btnGallery.tap()

        let galleryCollectionViewCell = app.collectionViews.cells.element.children(matching: .any).element(boundBy: 0)

        if galleryCollectionViewCell.exists {
            galleryCollectionViewCell.forceTapElement()
        }
        let btnDoneGallery = app.buttons["Done"]
        btnDoneGallery.tap()

        sleep(2)
        XCTAssertTrue( (collectionView.allElementsBoundByAccessibilityElement.count == 2 ), "Collection view does not have 2 images as expected!")

        let picChoosed  =   collectionView.allElementsBoundByAccessibilityElement.first

        XCTAssertFalse(( picClicked == picChoosed ), "Images are same that means updated image is not appearing in first position!")
        
        let btnBack         =   app.buttons["white back icon"]
        expectation(for: prediatForHittable, evaluatedWith: btnBack, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        btnBack.tap()
        
        expectation(for: prediatForHittable, evaluatedWith: btnCamera, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        btnCamera.tap()
        
        expectation(for: prediatForHittable, evaluatedWith: btnCaptureIcon, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        btnCaptureIcon.tap()
        
        
        sleep(1)
        XCTAssertTrue( (collectionView.allElementsBoundByAccessibilityElement.count == 1 ), "Collection view not appeared!")
        
        let picClicked01  =   collectionView.allElementsBoundByAccessibilityElement.first
        
        btnGallery.tap()
        
        let galleryCollectionViewCell01 = app.collectionViews.cells.element.children(matching: .any).element(boundBy: 0)
        
        if galleryCollectionViewCell01.exists {
            galleryCollectionViewCell01.forceTapElement()
        }
        
        btnDoneGallery.tap()
        
        XCTAssertTrue( (collectionView.allElementsBoundByAccessibilityElement.count == 2 ), "Collection view does not have 2 images as expected!")
        
        let picChoosed01  =   collectionView.allElementsBoundByAccessibilityElement.first
        
        XCTAssertFalse(( picClicked01 == picChoosed01 ), "Images are same that means updated image is not appearing in first position!")
        
        expectation(for: prediatForHittable, evaluatedWith: btnShare, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        btnShare.tap()

        
        let collectionViewForEdit = app.collectionViews.element.children(matching:.any)

        let seeconPicForEdit = collectionViewForEdit.allElementsBoundByAccessibilityElement.last
        
        seeconPicForEdit?.forceTapElement()
        
        sleep(2)
        
        let titleYourImageTextField = app.textFields["Title your Image"]
        expectation(for: prediatForHittable, evaluatedWith: titleYourImageTextField, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        titleYourImageTextField.forceTapElement()
        titleYourImageTextField.clearAndEnterText(text: "Sourabh")
        titleYourImageTextField.typeText("\n")
        
        let descriptionTextTextField = app.textFields["Description text"]
        descriptionTextTextField.clearAndEnterText(text: "Sourabh Desc")
        app.typeText("\n")
        
        let doneButton = app.buttons["  Done"]
        
        doneButton.tap()
        
        let editIconButton = app.buttons["edit icon"]
        expectation(for: prediatForHittable, evaluatedWith: editIconButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        editIconButton.tap()
        
        
        
        let pencilButton = app.buttons["pencil icon"]
        expectation(for: prediatForHittable, evaluatedWith: pencilButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        pencilButton.tap()
        
        sleep(1)
        
        
        let cooridnate1 = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: 20 , dy: 100))
        let cooridnate2 = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: 40 , dy: 300))
        let cooridnate3 = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: 70 , dy: 200))
        let cooridnate4 = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: 250 , dy: 500))
        let cooridnate5 = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: 199 , dy: 450))
        let cooridnate6 = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: 150 , dy: 100))

        
        
        cooridnate1.tap()
        cooridnate2.tap()
        cooridnate3.tap()
        cooridnate4.tap()
        cooridnate5.tap()
        cooridnate6.tap()
        
        sleep(1)
        let colorBucketIconUnactiveButton = app.buttons["color bucket icon unactive"]
        colorBucketIconUnactiveButton.tap()
        
        
        let collectionViewColors = app.collectionViews.element.children(matching:.any)
        
        //pencil button for brush
//        let penIconButton            = app.buttons["pen icon"]
        let penIconUnactiveButton    = app.buttons["pen icon unactive"]
        let brushContainer = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element
        let firstBrush = brushContainer.children(matching: .button).element(boundBy: 0)
        let secondBrush = brushContainer.children(matching: .button).element(boundBy: 1)
        let thirdBrush = brushContainer.children(matching: .button).element(boundBy: 2)

        
        for (index, cell) in collectionViewColors.allElementsBoundByAccessibilityElement.enumerated() {
            print("Item \(index): \(cell)")
            cell.tap()
            if index % 2 == 0  {
                penIconUnactiveButton.tap()
                firstBrush.tap()
                
                cooridnate1.press(forDuration: TimeInterval.init(exactly: 0)!, thenDragTo: cooridnate2)
                cooridnate2.press(forDuration: TimeInterval.init(exactly: 0)!, thenDragTo: cooridnate3)

            }else if index % 3 == 0{
                penIconUnactiveButton.tap()
                secondBrush.tap()
                
                cooridnate3.press(forDuration: TimeInterval.init(exactly: 0)!, thenDragTo: cooridnate4)
                cooridnate4.press(forDuration: TimeInterval.init(exactly: 0)!, thenDragTo: cooridnate5)

            }else{
                penIconUnactiveButton.tap()
                thirdBrush.tap()
                cooridnate5.press(forDuration: TimeInterval.init(exactly: 0)!, thenDragTo: cooridnate6)
            }
        }
        
        sleep(1)
        
        let btnEditingDone = app.buttons["editing done icon"]
        btnEditingDone.tap()
        let btnDownload = app.buttons["download icon"]
        btnDownload.tap()
        
        
        
        let btnAddEmoji = app.buttons["emoji icon"]
        btnAddEmoji.tap()
        app.scrollViews.children(matching: .collectionView).element.swipeLeft()

        let smileyEmoji = app.collectionViews.staticTexts["😃"]
        smileyEmoji.tap()

        btnAddEmoji.tap()
        app.scrollViews.children(matching: .collectionView).element.swipeLeft()

        let laughEmoji = app.collectionViews.staticTexts["😂"]
        laughEmoji.tap()
        
        let emojiSmiley = app.staticTexts["😃"]
        let emojiLaugh = app.staticTexts["😂"]

    
        emojiLaugh.swipeLeft()
        emojiLaugh.swipeLeft()
        
        emojiSmiley.swipeRight()
        emojiSmiley.swipeRight()
        
        sleep(1)
        
        let btnNext  =  app.buttons["next icon"]
        btnNext.tap()
        
        let btnAddToStream = app.buttons["  Add to Stream"]
        btnAddToStream.tap()
        
        doneButton.tap()
        
        sleep(1)
        
        XCTAssertEqual(titleYourImageTextField.value as! String, "Sourabh", "Title is not same as entered.")
        XCTAssertEqual(descriptionTextTextField.value as! String, "Sourabh Desc", "description is not same as entered.")
        
        
        let btnBackFromEdit = app.buttons["back circle icon"]
        btnBackFromEdit.tap()
        
        btnBack.tap()
        sleep(5)
        
        
        //video rcording
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
        
        let videoCollectionView = app.collectionViews.element.children(matching:.any)
        
        XCTAssertTrue((videoCollectionView.allElementsBoundByAccessibilityElement.count == 1 ), "collectionView not exists after successfully stopped video recording as btnVideoStop tappped")
        XCTAssertFalse(btnVideoStop.exists, "btnVideoStop should not be seen after the btnVideoStop button tapped!")
        
        sleep(2)
        
        btnBack.tap()
        
        expectation(for: prediatForCamerabutton, evaluatedWith: btnCamera, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        btnCamera.tap()
        
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
        
        let title = app.textFields["Title your Image"]
        title.clearAndEnterText(text: "Sourabh")
        title.typeText("\n")
        
        
        let desc = app.textFields["Description text"]
        desc.clearAndEnterText(text: "Sourabh Desc")
        desc.typeText("\n")
        doneButton.tap()
        
        btnBackFromEdit.tap()
        btnBack.tap()
        
        sleep(1)
        let btnAdd = app.buttons["add icon home"]
        btnAdd.tap()
        sleep(4)

    }
    
    func testTEst(){
        XCUIApplication().scrollViews.children(matching: .other).element.children(matching: .other).element(boundBy: 0).buttons["Done"].tap()
        
        let app = XCUIApplication()
        let element = app.scrollViews.children(matching: .other).element.children(matching: .other).element(boundBy: 0)
        let element2 = element.children(matching: .other).element
        let collectionView = element2.children(matching: .collectionView).element
        collectionView.tap()
        collectionView.tap()
        collectionView.tap()
        element.buttons["Done"]/*@START_MENU_TOKEN@*/.press(forDuration: 0.5);/*[[".tap()",".press(forDuration: 0.5);"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        app.tables.cells.containing(.textField, identifier:"Stream Name").children(matching: .button).element.tap()
        app.buttons["PHOTOS"].tap()
        collectionView.swipeUp()
        collectionView.swipeDown()
        collectionView/*@START_MENU_TOKEN@*/.swipeRight()/*[[".swipeUp()",".swipeRight()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        collectionView.swipeDown()
        
        let button = element2.children(matching: .other).element(boundBy: 0).children(matching: .button).element(boundBy: 1)
        button.tap()
        button.tap()
        button.tap()
        button.tap()
        
    }
    
    func testForCreateStream(){
        let prediatForHittable = NSPredicate(format: "isHittable == 1")
        let prediatForExists   = NSPredicate(format: "exists == 1")

        
        let btnAdd = app.buttons["add icon home"]
        btnAdd.tap()
        
        let tablesQuery = app.tables
        let txtStreamName = tablesQuery.textFields["Stream Name"]

        
        let tvStreamCaption = app.tables.cells.containing(.staticText, identifier:"Stream Caption").children(matching: .textView).element

        let btnCameraForStream    =  tablesQuery.buttons["camera icon cover images"]
        
        let btnDone         =       tablesQuery.buttons["done button"]
        
        btnCameraForStream.tap()
        
        let btnGalleryPhoto = app.buttons["PHOTOS"]
        
        btnGalleryPhoto.tap()
        
        let secondCell = app.collectionViews.cells.element.children(matching: .any).element(boundBy: 1)
        secondCell.forceTapElement()
        
        let element = app.scrollViews.children(matching: .other).element.children(matching: .other).element(boundBy: 0)
        element.buttons["Done"].tap()
//                app.buttons["Done"].forceTapElement()
        
        expectation(for: prediatForHittable, evaluatedWith: txtStreamName, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        txtStreamName.tap()
        txtStreamName.typeText("Sourabh's Stream 102")
        
        tvStreamCaption.tap()
        tvStreamCaption.typeText("Sourabh's Stream is Awesome!\n")
        
        let switchMakePrivateStream = tablesQuery.switches["Make Private Stream"]
        let switchAddColab          = tablesQuery.switches["Add Collaborators"]
        let switchAnyOneCanEdit     = tablesQuery.switches["Any one can edit"]
        let switchAddContent        = tablesQuery.switches["Add Content"]
        let switchAddPeople         = tablesQuery.switches["Add People"]
        
        switchMakePrivateStream.tap()
        
        btnDone.tap()
        
        expectation(for: prediatForExists, evaluatedWith: btnAdd, handler: nil)
        waitForExpectations(timeout: 30, handler: nil)
        
        
    }
    
    func testStreamButtons(){
        
        sleep(5)
        let btnDownArrow = app.buttons["menu down arrow"]
        
        let predicate = NSPredicate.init(format:  "isHittable == 1")
        let existsPredicate = NSPredicate.init(format:  "exists == 1")

        expectation(for: predicate, evaluatedWith: btnDownArrow, handler: nil)
        waitForExpectations(timeout: 20, handler: nil)
        
        btnDownArrow.tap()
        
        let homeCollectionView = app.collectionViews["StreamCollectionView"]
        let bottomMenuCollectionView = app.collectionViews["BottomMenuCollectionView"]

        bottomMenuCollectionView.swipeRight()
        
        let secondCellForHomeCollectionView = homeCollectionView.cells.element(boundBy: 3)
        
        
        expectation(for: existsPredicate, evaluatedWith: secondCellForHomeCollectionView, handler: nil)
        waitForExpectations(timeout: 20, handler: nil)
        
        secondCellForHomeCollectionView.forceTapElement()
        
        let addContentCell = app.collectionViews.cells["StreamContentCellAddContent"]
        
        expectation(for: existsPredicate, evaluatedWith: addContentCell, handler: nil)
        waitForExpectations(timeout: 20, handler: nil)
        
        addContentCell.forceTapElement()
        
        sleep(2)
        let firstMyContentCell = app.collectionViews["MyStuffCollectionView"].cells.allElementsBoundByAccessibilityElement[0]
        
        expectation(for: existsPredicate, evaluatedWith: firstMyContentCell, handler: nil)
        waitForExpectations(timeout: 20, handler: nil)

        firstMyContentCell.forceTapElement()
        
        let btnNext = app.buttons["content next btn"]
        btnNext.tap()
        
        let btnDone = app.buttons["  Done"]
        btnDone.tap()
        
        let btnAddToStream = app.buttons["  Add to Stream"]
        btnAddToStream.tap()

        
    }
    
    func testMakePublicStream(){
        let prediatForHittable = NSPredicate(format: "isHittable == 1")
        let prediatForExists   = NSPredicate(format: "exists == 1")
        let strStreamTitle = "Sourabh's 3rd Public Stream!"
        
        let btnAdd = app.buttons["add icon home"]
        btnAdd.tap()
        
        let tablesQuery = app.tables
        let txtStreamName = tablesQuery.textFields["Stream Name"]
        
        
        let tvStreamCaption = app.tables.cells.containing(.staticText, identifier:"Stream Caption").children(matching: .textView).element
        
        let btnCameraForStream    =  tablesQuery.buttons["camera icon cover images"]
        
        let btnDone         =       tablesQuery.buttons["done button"]
        
        btnCameraForStream.tap()
        
        let btnGalleryPhoto = app.buttons["PHOTOS"]
        
        btnGalleryPhoto.tap()
        
        let secondCell = app.collectionViews.cells.element.children(matching: .any).element(boundBy: 1)
        secondCell.forceTapElement()
        
        let element = app.scrollViews.children(matching: .other).element.children(matching: .other).element(boundBy: 0)
        element.buttons["Done"].tap()
        //                app.buttons["Done"].forceTapElement()
        
        expectation(for: prediatForHittable, evaluatedWith: txtStreamName, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        txtStreamName.tap()
        txtStreamName.typeText(strStreamTitle)
        
        tvStreamCaption.tap()
        tvStreamCaption.typeText("Sourabh's Stream is Awesome!\n")
        
//        let switchMakePrivateStream = tablesQuery.switches["Make Private Stream"]
//        let switchAddColab          = tablesQuery.switches["Add Collaborators"]
//        let switchAnyOneCanEdit     = tablesQuery.switches["Any one can edit"]
//        let switchAddContent        = tablesQuery.switches["Add Content"]
//        let switchAddPeople         = tablesQuery.switches["Add People"]
//
//        switchMakePrivateStream.tap()
        
        btnDone.tap()
        
        expectation(for: prediatForExists, evaluatedWith: btnAdd, handler: nil)
        waitForExpectations(timeout: 30, handler: nil)
        
        sleep(3)
        
        XCTAssertTrue(app.collectionViews["StreamCollectionView"].cells[strStreamTitle].exists, "List not  updated for the new stream!")
    }
    
    func testMakePrivateStream(){
        
        let strStreamTitle = "Sourabh's 1st Private Stream!"
        let prediatForHittable = NSPredicate(format: "isHittable == 1")
        let prediatForExists   = NSPredicate(format: "exists == 1")
        
        
        let btnAdd = app.buttons["add icon home"]
        btnAdd.tap()
        
        let tablesQuery = app.tables
        let txtStreamName = tablesQuery.textFields["Stream Name"]
        
        
        let tvStreamCaption = app.tables.cells.containing(.staticText, identifier:"Stream Caption").children(matching: .textView).element
        
        let btnCameraForStream    =  tablesQuery.buttons["camera icon cover images"]
        
        let btnDone         =       tablesQuery.buttons["done button"]
        
        btnCameraForStream.tap()
        
        let btnGalleryPhoto = app.buttons["PHOTOS"]
        
        btnGalleryPhoto.tap()
        
        let secondCell = app.collectionViews.cells.element.children(matching: .any).element(boundBy: 1)
        secondCell.forceTapElement()
        
        let element = app.scrollViews.children(matching: .other).element.children(matching: .other).element(boundBy: 0)
        element.buttons["Done"].tap()
        //                app.buttons["Done"].forceTapElement()
        
        expectation(for: prediatForHittable, evaluatedWith: txtStreamName, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        txtStreamName.tap()
        txtStreamName.typeText(strStreamTitle)
        
        tvStreamCaption.tap()
        tvStreamCaption.typeText("Sourabh's Stream is Awesome!\n")
        
                let switchMakePrivateStream = tablesQuery.switches["Make Private Stream"]
        //        let switchAddColab          = tablesQuery.switches["Add Collaborators"]
        //        let switchAnyOneCanEdit     = tablesQuery.switches["Any one can edit"]
        //        let switchAddContent        = tablesQuery.switches["Add Content"]
        //        let switchAddPeople         = tablesQuery.switches["Add People"]
        //
                switchMakePrivateStream.tap()
        
        btnDone.tap()
        
        expectation(for: prediatForExists, evaluatedWith: btnAdd, handler: nil)
        waitForExpectations(timeout: 30, handler: nil)
        
        sleep(3)
        
        XCTAssertTrue(app.collectionViews["StreamCollectionView"].cells[strStreamTitle].exists, "List not  updated for the new stream!")
    }
    
    func testTRTR(){
        
        let bottomMenuCollectionView = app.collectionViews["BottomMenuCollectionView"]
        let middleCell = bottomMenuCollectionView.cells.allElementsBoundByAccessibilityElement[2]
        let start = middleCell.coordinate(withNormalizedOffset: CGVector.init(dx: 0, dy: 0))
        let finish = middleCell.coordinate(withNormalizedOffset: CGVector.init(dx: 6 , dy: 0))
        start.press(forDuration: 0, thenDragTo: finish)

        
    }
    
    func testMakeStream(){
        
        let btnAdd = app.buttons["add icon home"]
        sleep(2)
        btnAdd.tap()
        
        let tablesQuery = app.tables
        
        let switchAddColab          = tablesQuery.switches["Add Collaborators"]
        
        switchAddColab.tap()
        
        print(app.debugDescription)
        let cell = tablesQuery.cells.collectionViews.cells.element.children(matching: .any).element(boundBy: 1)
        
        cell.forceTapElement()//tablesQuery.cells.collectionViews.count
        
//        let popularCollectionView
        
        sleep(4)

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
    
    func testGall(){

        
        app.navigationBars["home icon active"].buttons["camera icon"].tap()
        
        let addGaleryButton = app.buttons["add galery"]
        addGaleryButton.tap()
        
        let collectionViewFirstCell = app.collectionViews.cells.allElementsBoundByAccessibilityElement[0]
        print(collectionViewFirstCell.exists)
        
        collectionViewFirstCell.forceTapElement()
        
        let btnDoneGallery = app.buttons["Done"]
        btnDoneGallery.tap()


        sleep(3)
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
        
        let galleryCollectionViewCell = app.collectionViews.cells.element.children(matching: .any).element(boundBy: 0)
        
        if galleryCollectionViewCell.exists {
            galleryCollectionViewCell.forceTapElement()
        }
        let btnDoneGallery = app.buttons["Done"]
        btnDoneGallery.tap()
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
        
        let galleryCollectionViewCell = app.collectionViews.cells.element.children(matching: .any).element(boundBy: 0)
        
        if galleryCollectionViewCell.exists {
            galleryCollectionViewCell.forceTapElement()
        }
        let btnDoneGallery = app.buttons["Done"]
        btnDoneGallery.tap()
        
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
        
        XCTAssertTrue(btnShare.exists, "btnShare is not present not in Camera view")
        
        sleep(2)
        
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
    
    func testCamera_Capture_Image_And_Edit_With_A_Color_Line_And_SaveToPhotoLibrary(){
        
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
    
    func testCamera_Capture_Live_Image_And_Save_And_Check_Description_And_Title(){
        
        let btnCamera        = app.navigationBars.buttons["camera icon"]
        let btnCaptureIcon   = app.buttons["capture icon"]
        let btnShare         = app.buttons["share button"]
        let btnBack          = app.buttons["back circle icon"]
        
        let prediate = NSPredicate(format: "isHittable == 1")
        expectation(for: prediate, evaluatedWith: btnCamera, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        btnCamera.tap()
        
        sleep(1)
        btnCaptureIcon.tap()
        
        expectation(for: prediate, evaluatedWith: btnShare, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        btnShare.tap()

        
        let titleYourImageTextField = app.textFields["Title your Image"]
        titleYourImageTextField.clearAndEnterText(text: "Sourabh")
        titleYourImageTextField.typeText("\n")
        
        let descriptionTextTextField = app.textFields["Description text"]
        descriptionTextTextField.clearAndEnterText(text: "Sourabh Desc")
        app.typeText("\n")
        
        let doneButton = app.buttons["  Done"]
        doneButton.tap()
        
        expectation(for: prediate, evaluatedWith: btnBack, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)

        
        btnBack.tap()
        
        sleep(1)
        
        btnShare.tap()
        
        XCTAssertEqual(titleYourImageTextField.value as! String, "Sourabh", "Title is not same as entered.")
        XCTAssertEqual(descriptionTextTextField.value as! String, "Sourabh Desc", "description is not same as entered.")
        
    }
    
    func testCameraWithTwoImagesWithTheirDistincness(){
        
        let btnCamera        = app.navigationBars.buttons["camera icon"]
        let btnCaptureIcon   = app.buttons["capture icon"]
        let btnShare         = app.buttons["share button"]
        let btnBack          = app.buttons["back circle icon"]
        
        let prediate = NSPredicate(format: "isHittable == 1")
        expectation(for: prediate, evaluatedWith: btnCamera, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        btnCamera.tap()
        
        sleep(1)
        btnCaptureIcon.tap()
        
        expectation(for: prediate, evaluatedWith: btnShare, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        btnShare.tap()
        
        
        let titleYourImageTextField = app.textFields["Title your Image"]
        titleYourImageTextField.clearAndEnterText(text: "Sourabh")
        titleYourImageTextField.typeText("\n")
        
        let descriptionTextTextField = app.textFields["Description text"]
        descriptionTextTextField.clearAndEnterText(text: "Sourabh Desc")
        app.typeText("\n")
        
        let doneButton = app.buttons["  Done"]
        doneButton.tap()
        
        expectation(for: prediate, evaluatedWith: btnBack, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        
        btnBack.tap()
        
        expectation(for: prediate, evaluatedWith: btnCaptureIcon, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        btnCaptureIcon.tap()
        
        expectation(for: prediate, evaluatedWith: btnShare, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        btnShare.tap()
        
        
        let collectionView = app.collectionViews.element.children(matching:.any)
        print(collectionView.allElementsBoundByAccessibilityElement)
        XCTAssertEqual(collectionView.allElementsBoundByAccessibilityElement.count, 2, "Should be 2 images in collection view")

        
        let firstPic    =   collectionView.allElementsBoundByAccessibilityElement.first
        firstPic?.forceTapElement()
        
        XCTAssertEqual(titleYourImageTextField.value as! String, "Title your Image" , "Title Should be not appear for Recently added image.")
        XCTAssertEqual(descriptionTextTextField.value as! String, "Description text" , "Description Should be not appear for Recently added image.")
        
        let secondPic = collectionView.allElementsBoundByAccessibilityElement.last
        
        secondPic?.forceTapElement()
        
        XCTAssertEqual(titleYourImageTextField.value as! String, "Sourabh", "Title is not same as entered.")
        XCTAssertEqual(descriptionTextTextField.value as! String, "Sourabh Desc", "description is not same as entered.")
        
        sleep(3)
        
    }
    
    func testForEmoji(){
        
        app.buttons["edit icon"].tap()
        
        let emojiIconButton = app.buttons["emoji icon"]
        emojiIconButton.tap()
        
        let collectionView = app.scrollViews.children(matching: .collectionView).element

        app?/*@START_MENU_TOKEN@*/.collectionViews.cells.staticTexts["😆"]/*[[".scrollViews.collectionViews",".cells.staticTexts[\"😆\"]",".staticTexts[\"😆\"]",".collectionViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,1]]@END_MENU_TOKEN@*/.swipeRight()
        collectionView.swipeLeft()
        app?/*@START_MENU_TOKEN@*/.collectionViews.cells.staticTexts["😃"]/*[[".scrollViews.collectionViews",".cells.staticTexts[\"😃\"]",".staticTexts[\"😃\"]",".collectionViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,1]]@END_MENU_TOKEN@*/.tap()
        XCUIDevice.shared.orientation = .faceUp
        
    }
    
    func testCamera_Capture_Live_Image_And_Save_It_With_Text(){
        
        let btnShare = app.buttons["share button"]
        let editIconButton = app.buttons["edit icon"]

        sleep(2)
        app.navigationBars.buttons["camera icon"].tap()
        app.buttons["capture icon"].tap()


        let predicateForShareButton = NSPredicate(format: "isHittable == 1")
        expectation(for: predicateForShareButton, evaluatedWith: btnShare, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        btnShare.tap()

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
    
    func scrollLeftToElement(element: XCUIElement) {
        while !element.visible() {
            //swipeUp()
            swipeLeft()
        }
    }
    
    func visible() -> Bool {
        guard self.exists && !self.frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
    }

}

