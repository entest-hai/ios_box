//
//  ContentView.swift
//  BoxApp
//
//  Created by hai on 29/4/21.
//  Copyright © 2021 biorithm. All rights reserved.
//

import SwiftUI
import BoxSDK

class BoxClient {
    let client = BoxSDK.getClient(token: "M5HMaIAd2S05sQywAVmPmlBbTjUXO8fg")
    
    init() {
        authenticate()
    }
    
    func authenticate() {
        self.client.users.getCurrent(){result in
            switch result {
            case let .failure(error):
                print("Error: \(error)")
            case let .success(user):
                print("user: \(user.name ?? "") and email: \(user.login ?? "")")
            }
        }
    }
}

struct ContentView: View {
    let box = BoxClient()
    
    
    init() {
    }
    
    var body: some View {
        Button("Authenticate"){
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
