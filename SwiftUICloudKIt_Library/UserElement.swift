//
//  UserElement.swift
//  SwiftUICloudKIt_Library
//
//  Created by Jan Hovland on 09/11/2019.
//  Copyright © 2019 Jan Hovland. All rights reserved.
//

//
//  UserElement.swift
//  SwiftUICloudKitDemo
//
//  Created by Jan Hovland on 07/11/2019.
//  Copyright © 2019 Alex Nagy. All rights reserved.
//

import SwiftUI
import CloudKit

struct UserElement: Identifiable {
    var id = UUID()
    var recordID: CKRecord.ID?
    var name: String
}
