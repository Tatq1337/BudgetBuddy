//
//  SettingsView.swift
//  budget-tracker
//
//  Created by Kamil Glac on 23/04/2023.
//

import SwiftUI

struct SettingsView: View {
    @State private var Zarobek: String = "4500"
    @State private var Oszczednosci: String = "1000"
    
    var body: some View {

        NavigationView{
            
            Form{
                Section("Twoj przychod"){
                    TextField("Twoj przychod", text:$Zarobek)
                        .keyboardType(.decimalPad)
                }
                Section("Miesieczna oszczednosc"){

                    TextField("Miesieczna oszczednosc", text:$Oszczednosci)
                        .keyboardType(.decimalPad)
                    

                }
            }
            .navigationTitle("Ustawienia")
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    Button{
                        
                    }
                    label: {
                        Text("Zmien")
                            .padding(.top, 95)
                            
                        }
                }
                
            }

        }
        .accentColor(.red)
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
