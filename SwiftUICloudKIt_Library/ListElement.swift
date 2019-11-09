//
//  ListElement.swift
//  SwiftUICloudKIt_Library
//
//  Created by Jan Hovland on 09/11/2019.
//  Copyright © 2019 Jan Hovland. All rights reserved.
//

//
//  ListElement.swift
//  SwiftUICloudKit.swift
//
//  Created by Jan Hovland on 06/11/2019.
//


import SwiftUI
import CloudKit

struct ListElement: Identifiable {
    var id = UUID()
    var recordID: CKRecord.ID?
    var text: String
    var description: String
}
