//
//  CutomClass.swift
//  RealmSample2
//
//  Created by Kimisira on 2016/05/22.
//  Copyright © 2016年 Kimisira. All rights reserved.
//

import Foundation
import UIKit


class CutomClass:NSObject,UIActivityItemSource{
    
    var NaiyouString:String!
    
    init(NaiyouString:String) {
        self.NaiyouString = NaiyouString
        super.init()
    }
    //返り値が各Activityが共有できるかの判定をするときに用いられます。
    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
        return String()
    }
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        if activityType == UIActivityTypePostToTwitter{
            return  NaiyouString + " #Memo"
        }
        return NaiyouString
    }
}