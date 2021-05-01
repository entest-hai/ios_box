//
//  ContentView.swift
//  box-ios-app
//
//  Created by hai on 30/4/21.
//  Copyright © 2021 biorithm. All rights reserved.
//

import AuthenticationServices
import SwiftUI
import BoxSDK

struct BoxFolderItem :Identifiable {
    let id = UUID()
    var folderItem: FolderItem
}

class Box : NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding{
    @Published var names = [String]()
    @Published var folderItems = [BoxFolderItem]()
    let sdk = BoxSDK(clientId: Constants.clientId,
                     clientSecret: Constants.clientSecret)
    override init() {
        super.init()
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    func authenticate() {
        print("box authenticate")
        if #available(iOS 13, *) {
            self.sdk.getOAuth2Client(tokenStore: KeychainTokenStore(), context: self) { [weak self] result in
                switch result {
                case let .success(client):
                    self?.getFolderItems(client: client)
                case let .failure(error):
                    print("error in getOAuth2Client: \(error)")
                }
            }
        }
    }
    
    func getFolderItems(client : BoxClient){
        print("get folder items")
        client.folders.listItems(
            folderId: BoxSDK.Constants.rootFolder,
            usemarker: true,
            fields: ["modified_at", "name", "extension"]
        ){ [weak self] result in
            guard let self = self else {return}

            switch result {
            case let .success(items):
                for i in 1...100 {
                    print ("Request Item #\(String(format: "%03d", i)) |")
                    items.next { result in
                        switch result {
                        case let .success(item):
                            print ("    Got Item #\(String(format: "%03d", i)) | \(item.debugDescription))")
                            DispatchQueue.main.async {
                                self.folderItems.append(BoxFolderItem(folderItem: item))
                            }
                        case let .failure(error):
                            print ("     No Item #\(String(format: "%03d", i)) | \(error.message)")
                            return
                        }
                    }
                }
            case let .failure(error):
                print(error)
            }
        }
    }
    
    
    
    
}

struct ContentView: View {
    @ObservedObject var box = Box()
    var body: some View {
        NavigationView {
            List(self.box.folderItems){item in
                self.buildItemView(boxFolderItem: item)
            }
                .navigationBarTitle("Box", displayMode: .inline)
                .navigationBarItems(trailing: Button("Login") {
                    self.box.authenticate()
                })
        }
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
                Image(systemName: "person")
            });
        }

        else if case let .folder(folder) = boxFolderItem.folderItem {
            modifiedAt = String(format: "Date Modified %@", dateFormatter.string(from: folder.modifiedAt ?? Date()))
            return AnyView(HStack{
                Image("folder")
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
                Image(systemName: "person")
            });
        }
        return AnyView(Text("Item Unknown"));
    }
    
}
