//
//  ScoresModel.swift
//  SpaceInvaders
//
//  Created by maciosdev on 24/09/2018.
//  Copyright © 2018 Ronilson Batista. All rights reserved.
//

import UIKit
import RealmSwift

class ScoresModel: Object {
    
    @objc dynamic var score = 0

}

//class Foo: Object {
//    let integerList = List<IntObject>() // Workaround
//}
//
//class IntObject: Object {
//    dynamic var value = 0
//}
