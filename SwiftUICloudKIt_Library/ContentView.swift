//
//  ContentView.swift
//  SwiftUICloudKit.swift
//
//  Created by Jan Hovland on 06/11/2019.
//

// MARK: - notes
// please refer to this playlist when you have questions about the layout
// https://www.youtube.com/watch?v=zucwLZoCs8w&list=PL_csAAO9PQ8Z1pbr-u6dSmDQTLZzDgcaP ////

import SwiftUI
import Combine

struct ContentView: View {
    
    @EnvironmentObject var listElements: ListElements
    @EnvironmentObject var userElements: UserElements
    
    @State private var newItem = ListElement(text: "", description: "")
    @State private var showEditTextField = false
    @State private var editedItem = ListElement(text: "", description: "")

    @State private var newItem1 = UserElement(name: "")

    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    VStack(spacing: 15) {
                        TextField("Add New Item", text: $newItem.text)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Add description", text: $newItem.description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Add username", text: $newItem1.name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Add") {
                            if !self.newItem.text.isEmpty {
                                let newItem = ListElement(text: self.newItem.text, description: self.newItem.description)
                                // MARK: - saving to CloudKit
                                CloudKitHelper.save(item: newItem) { (result) in
                                    switch result {
                                    case .success(let newItem):
                                        self.listElements.items.insert(newItem, at: 0)
                                        print("Successfully added item")
                                    case .failure(let err):
                                        print(err.localizedDescription)
                                    }
                                }
                                self.newItem = ListElement(text: "", description: "")
                            }
                             
                            if !self.newItem1.name.isEmpty {
                                let newItem1 = UserElement(name: self.newItem1.name)
                                // MARK: - saving to CloudKit
                                CloudKitUser.saveUser(item: newItem1) { (result) in
                                    switch result {
                                    case .success(let newItem1):
                                        self.userElements.user.insert(newItem1, at: 0)
                                        print("Successfully added user")
                                    case .failure(let err):
                                        print(err.localizedDescription)
                                    }
                                }
                                self.newItem1 = UserElement(name: "")
                            }
                            
                            
                        }
                    }
                    HStack(spacing: 15) {
                        TextField("Edit Item", text: self.$editedItem.text)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("Done") {
                            // MARK: - modify in CloudKit
                            CloudKitHelper.modify(item: self.editedItem) { (result) in
                                switch result {
                                case .success(let item):
                                    for i in 0..<self.listElements.items.count {
                                        let currentItem = self.listElements.items[i]
                                        if currentItem.recordID == item.recordID {
                                            self.listElements.items[i] = item
                                        }
                                    }
                                    self.showEditTextField = false
                                    print("Successfully modified item")
                                case .failure(let err):
                                    print(err.localizedDescription)
                                }
                            }
                        }
                    }
                    .frame(height: showEditTextField ? 60 : 0)
                    .opacity(showEditTextField ? 1 : 0)
                    .animation(.easeInOut)
                }
                .padding()
                Text("Double Tap to Edit. Log Press to Delete.")
                    .frame(height: showEditTextField ? 0 : 40)
                    .opacity(showEditTextField ? 0 : 1)
                    .animation(.easeInOut)
                
                List (listElements.items) { item in
                    VStack(spacing: 15) {
                        // Both item.text and item.description are not optional and cannat be nil
                        Text(item.text)
                        Text(item.description)
                    }
                    .onTapGesture(count: 2, perform: {
                        if !self.showEditTextField {
                            self.showEditTextField = true
                            self.editedItem = item
                        }
                    })
                    .onLongPressGesture {
                        if !self.showEditTextField {
                            guard let recordID = item.recordID else { return }
                            // MARK: - delete from CloudKit
                            CloudKitHelper.delete(recordID: recordID) { (result) in
                                switch result {
                                case .success(let recordID):
                                    self.listElements.items.removeAll { (listElement) -> Bool in
                                        return listElement.recordID == recordID
                                    }
                                    print("Successfully deleted item")
                                case .failure(let err):
                                    print(err.localizedDescription)
                                }
                            }
                            
                        }
                    }
                }
                .animation(.easeInOut)
                
                List (userElements.user) { item in
                    VStack (spacing: 15) {
                        // item.name is not optional and cannat be nil
                        Text(item.name)
                    }
                }
                .animation(.easeInOut)
                
            }
            .navigationBarTitle(Text("SwiftUI with CloudKit"))
        }
        .onAppear {
            // MARK: - fetch from CloudKit
            CloudKitHelper.fetch { (result) in
                switch result {
                case .success(let newItem):
                    self.listElements.items.append(newItem)
                    print("Successfully fetched item")
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
            
            CloudKitUser.fetchUser { (result) in
                switch result {
                   case .success(let newItem):
                       self.userElements.user.append(newItem)
                       print("Successfully fetched user's name")
                   case .failure(let err):
                       print(err.localizedDescription)
                 }
            }
            
       }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


