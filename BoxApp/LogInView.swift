//
//  LogInView.swift
//  BoxApp
//
//  Created by hai on 4/5/21.
//  Copyright © 2021 biorithm. All rights reserved.
//

import SwiftUI

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}

struct LoginView : View {
    @EnvironmentObject var box: BoxSupport
    var body: some View {
        NavigationView{
            Button(action: {
                self.box.authenticate()
            }){
                Text("Login")
            }
            .navigationBarTitle(Text("Box Application"), displayMode: .inline)
            .background(NavigationConfigurator { nc in
                nc.navigationBar.barTintColor = .blue
                nc.navigationBar.titleTextAttributes =  [.foregroundColor : UIColor.white]
            })
        }
    .navigationViewStyle(StackNavigationViewStyle())
    }
}
