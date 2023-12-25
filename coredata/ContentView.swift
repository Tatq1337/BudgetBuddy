//
//  ContentView.swift
//  budget-tracker
//
//  Created by Kamil Glac on 23/04/2023.
//

import SwiftUI
struct ContentView: View {
    @State private var selectedTab = 2
    var body: some View {

            TabView(selection:$selectedTab){
                CalendarView()
                    .tabItem {
                        Image(systemName: "calendar")
                    }.tag(1)
                
                BudgetView()
                    .tabItem {
                        Image(systemName: "house")
                    }.tag(2)
                
                PromotionsView()
                    .tabItem {
                        Image(systemName: "list.dash")
                    }.tag(3)


            }.accentColor(.red)
        }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

