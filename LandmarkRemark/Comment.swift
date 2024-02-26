//
//  Comment.swift
//  LandmarkRemark
//
//  Created by NguyenPhuongkhoa on 24/02/2024.
//

import UIKit
import RealmSwift

class Comment: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var desc: String = ""
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
}
