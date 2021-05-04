//
//  AuthenticatedView.swift
//  BoxApp
//
//  Created by hai on 4/5/21.
//  Copyright © 2021 biorithm. All rights reserved.
//

import SwiftUI
import BoxSDK

struct AuthenticatedView : View {
    let boxClient : BoxClient
    @EnvironmentObject var box: BoxSupport
    var body: some View {
        NavigationView{
            List(self.box.folderItems){item in
                self.buildItemView(boxFolderItem: item)
            }
            .navigationBarTitle(Text("Box Application"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.box.getFolderItems(client: self.boxClient)
            }){
                Text("Load")
                    .foregroundColor(Color.white)
            })
            .background(NavigationConfigurator { nc in
                nc.navigationBar.barTintColor = .blue
                nc.navigationBar.titleTextAttributes =  [.foregroundColor : UIColor.white]
            })
        }
          .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func buildItemView(boxFolderItem: BoxFolderItem) -> AnyView {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd,yyyy at HH:mm a"
            return formatter
        }()
        
        var icon: String
        var modifiedAt: String
        if case let .file(file) = boxFolderItem.folderItem {
            switch file.extension {
            case "boxnote":
                icon = "boxnote"
            case "jpg",
                 "jpeg",
                 "png",
                 "tiff",
                 "tif",
                 "gif",
                 "bmp",
                 "BMPf",
                 "ico",
                 "cur",
                 "xbm":
                icon = "image"
            case "pdf":
                icon = "pdf"
            case "docx":
                icon = "word"
            case "pptx":
                icon = "powerpoint"
            case "xlsx":
                icon = "excel"
            case "zip":
                icon = "zip"
            default:
                icon = "generic"
            }
            modifiedAt = String(format: "Date Modified %@", dateFormatter.string(from: file.modifiedAt ?? Date()))
            return AnyView(HStack{
                Image(icon)
                VStack(alignment: .leading){
                    Text("\(file.name ?? "")")
                        .lineLimit(1)
                        .font(.headline)
                    Text("\(modifiedAt)")
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "ellipsis")
            });
        }
            
        else if case let .folder(folder) = boxFolderItem.folderItem {
            modifiedAt = String(format: "Date Modified %@", dateFormatter.string(from: folder.modifiedAt ?? Date()))
            return AnyView(
                Button(action: {
                    print("choose a item")
                }) {
                    HStack{
                        Image("folder")
                            .foregroundColor(Color("folder"))
                        VStack(alignment: .leading){
                            Text("\(folder.name ?? "")")
                                .lineLimit(1)
                                .font(.headline)
                            Text("\(modifiedAt)")
                                .font(.system(size: 12))
                                .foregroundColor(Color.gray)
                                .lineLimit(1)
                        }
                        Spacer()
                        Button(action: {
                            print("share this folder")
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(Color.gray)
                        }
                    }
                }
            );
        }
        return AnyView(Text("Item Unknown"));
    }
}

