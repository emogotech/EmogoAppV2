//
//  EmogoStreamListVCTests.swift
//  EmogoTests
//
//  Created by Sourabh on 21/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import XCTest
@testable import Emogo


class EmogoStreamListVCTests: XCTestCase {
    
    
    let storyboard              =   UIStoryboard(name: "Main", bundle: Bundle.main)
    var vc                      :   StreamListViewController!
    
    override func setUp() {
        super.setUp()
        vc                      =   storyboard.instantiateViewController(withIdentifier: kStoryboardID_StreamListView) as! StreamListViewController
        vc.loadViewIfNeeded()
    }
    
    override func tearDown() {
        super.tearDown()
        vc                      =   nil
    }
    
    func testSLVC_Should_Set_CollectionViewDelegate() {
        XCTAssertNotNil(self.vc.streamCollectionView.delegate, "StreamListVC is not set to Collectoin view Delegate!")
    }
    
    func testSLVC_Should_Set_CollectionViewDataSource(){
        XCTAssertNotNil(self.vc.streamCollectionView.dataSource, "StreamListVC is not set to collection view DataSource")
    }
    
    func testSLVC_Should_Conform_To_CollectionViewDataSource(){
        XCTAssert(self.vc.conforms(to: UICollectionViewDataSource.self))
        XCTAssertTrue(self.vc.responds(to: #selector(self.vc.collectionView(_:numberOfItemsInSection:))), "StreamListVC is not calling numberOfItemsInSection")
        XCTAssertTrue(self.vc.responds(to: #selector(self.vc.collectionView(_:cellForItemAt:))), "StreamListVC isn not calling cellForItemAt")
    }
    
    func testSLVC_Should_Conform_To_CollectionViewDelegateFlowLayout() {
        XCTAssert(self.vc.conforms(to: UICollectionViewDelegateFlowLayout.self))
        XCTAssertTrue(self.vc.responds(to: #selector(self.vc.collectionView(_:viewForSupplementaryElementOfKind:at:))), "")
        XCTAssertTrue(self.vc.responds(to: #selector(self.vc.collectionView(_:layout:sizeForItemAt:))), "")
    }
    
    func testSLVC_Should_Conform_To_CollectionViewDelegate(){
        XCTAssert(self.vc.conforms(to: UICollectionViewDelegate.self))
        //XCTAssertTrue(self.vc.responds(to: #selector(self.vc.collectionView(_:didSelectItemAt:))), "StreamListVC isn not calling didSelectItemAt")
    }

}
