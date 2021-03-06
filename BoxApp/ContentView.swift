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

enum AuthState {
    case authenticatedsuccess(boxClient: BoxClient)
    case authenticatedfailed
    case login 
}

struct BoxFolderItem :Identifiable {
    let id = UUID()
    var folderItem: FolderItem
}

class BoxSupport : NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @Published var authState : AuthState = AuthState.login
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
        self.sdk.getOAuth2Client(tokenStore: KeychainTokenStore(), context: self) { [weak self] result in
            switch result {
            case let .success(client):
                DispatchQueue.main.async {
                    self?.authState = AuthState.authenticatedsuccess(boxClient: client)
                }
            case let .failure(error):
                print("error in getOAuth2Client: \(error)")
                print(error)
                DispatchQueue.main.async {
                    self?.authState = AuthState.authenticatedfailed
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


struct BoxAppView : View {
    @ObservedObject var box = BoxSupport()
    var body: some View {
        switch self.box.authState {
        case AuthState.login:
            return AnyView(LoginView().environmentObject(box))
        case AuthState.authenticatedsuccess(let boxClient):
            return AnyView(AuthenticatedView(boxClient: boxClient).environmentObject(box))
        case AuthState.authenticatedfailed:
            return AnyView(LoginView().environmentObject(box))
        }
    }
}

