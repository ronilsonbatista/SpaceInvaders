//
//  ScoresDataManager.swift
//  SpaceInvaders
//
//  Created by maciosdev on 24/09/2018.
//  Copyright © 2018 Ronilson Batista. All rights reserved.
//

import Foundation
import RealmSwift

final class ScoresDataManager {
    
    func saveScores(score: Int, date: String) {
    
        let realm = try! Realm()
    
        try! realm.write {
            let database = ScoresModel()
            
            database.score = score
            database.date = date
            realm.add(database)
        }
    }

}
