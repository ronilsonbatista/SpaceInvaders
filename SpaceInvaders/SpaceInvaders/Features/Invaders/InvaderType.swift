//
//  InvaderType.swift
//  SpaceInvaders
//
//  Created by Ronilson Batista on 16/09/2018.
//  Copyright © 2018 Ronilson Batista. All rights reserved.
//

import Foundation
import UIKit

enum InvaderType {
    case invaderA
    case invaderB
    case invaderC
    
    static var size: CGSize {
        return CGSize(width: 24, height: 16)
    }
    
    static var name: String {
        return "invader"
    }
}
