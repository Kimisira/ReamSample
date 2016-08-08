//
//  MemoDB.swift
//  RealmSample2
//
//  Created by Kimisira on 2016/05/22.
//  Copyright © 2016年 Kimisira. All rights reserved.
//

import Foundation
import RealmSwift


class MemoDB:Object {
    static  let realm: Realm? = try! Realm()
    
    dynamic var id = 0
    dynamic var naiyou = ""
    dynamic var kategori = ""
    dynamic var nauTime = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func lastId()-> Int{
        if let usermemo = realm!.objects(MemoDB).last{
            return usermemo.id + 1
        }else{
            return 1
        }
    }
    
    static func loadAll()-> [MemoDB] {
        let users = realm!.objects(MemoDB).sorted("nauTime",ascending: true)
        var ret:[MemoDB] = []
        for user in users {
            ret.append(user)
        }
        return ret
    }
    
    func add(){
        try! MemoDB.realm?.write(){
            MemoDB.realm?.add(self)
        }
    }
}