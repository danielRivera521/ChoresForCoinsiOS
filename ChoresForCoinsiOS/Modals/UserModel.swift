//
//  UserModel.swift
//  ChoresForCoinsiOS
//
//  Created by Daniel Rivera on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import Foundation


class UserModel{
    
    var id: String?
    var generatedID: String?
    var userName: String?
    var isParent: String?
    var coinTotal: Int?
    
    init(mID: String?, mGeneratedID: String?, mUserName: String?, mIsParent: String?, mCoinTotal: Int?){
        id = mID
        generatedID = mGeneratedID
        userName = mUserName
        isParent = mIsParent
        coinTotal = mCoinTotal
    }
}
