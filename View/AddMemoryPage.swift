//
//  AddMemoryPage.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 11/03/26.
//

import SwiftUI
import PhotosUI

struct AddMemoryPage: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var date = Date()
    @State private var description = ""
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        Form {
            Section{
                VStack {
                    Text("Title")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bold()
                        .font(.title3)
                    TextField("Title of your story", text:.constant(""))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }.padding(.top, 20)
                
                VStack {
                    Text("Location")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bold()
                        .font(.title3)
                    TextField("What's the place's name?", text:.constant(""))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
                
                VStack {
                    Text("Description")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bold()
                        .font(.title3)
                    TextEditor(text: $description)
                        .frame(height: 120)
                        .padding(4)
                }.padding(.bottom, 20)
            }
            
            Section{
                DatePicker(
                    selection: .constant(Date()),
                    displayedComponents: [.date],
                    label: {
                        Text("Date")
                            .bold()
                            .font(.title3)
                    }
                )
            }
            
            Section{
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Add Photo", systemImage: "photo.badge.plus")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 10)
            }
            
            Button(action: {}) {
                Text("Save")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

#Preview {
    AddMemoryPage()
}
