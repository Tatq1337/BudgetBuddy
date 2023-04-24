//
//  PromotionsView.swift
//  budget-tracker
//
//  Created by Kamil Glac on 23/04/2023.
//

import SwiftUI
import Foundation

struct Promotion: Codable{
    var affiliatelink: String
    var discount: String
    var enddate: String
    var img: String
    var name: String
    var price: String
    var ratting: Double
    var startdate: String
}


struct PromotionsView: View {
    @State private var promotions = [Promotion]()
    var body: some View {
        NavigationView{
            List(promotions, id: \.affiliatelink){ promotion in
                HStack{
                    Link(destination: URL(string: promotion.affiliatelink)!) {
                        Image(systemName: "link")
                            .frame(width: 32, height: 32)
                            .background(Color.red)
                            .mask(Circle())
                            .foregroundColor(.white)
                    }

                    Spacer().frame(width: 30)
                    
                    VStack(alignment: .leading){
                        Text(promotion.name)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)
                        Spacer().frame(height: 5)
                        HStack{
                            Text(promotion.discount)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer().frame(width:95)
                            Text(promotion.price)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                
                        }
                    }
                    
                }
                 
                }.navigationTitle("Promocje")
                 .task {
                       await fetchData()
                    }
            }
        
        }
    func fetchData() async {
        let headers = [
            "content-type": "application/octet-stream",
            "X-RapidAPI-Key": "d43a791ad5msh6a04f16c0515c07p12987fjsn6b5840ab179c",
            "X-RapidAPI-Host": "recash1.p.rapidapi.com"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://recash1.p.rapidapi.com/allproducts")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if let error = error {
                print(error)
            } else {
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode([Promotion].self, from: data)
                        self.promotions = response
                    } catch {
                        print(error)
                    }
                } else {
                    print("No data received")
                }
            }
        }

        dataTask.resume()
    }
    }

struct PromotionsView_Previews: PreviewProvider {
    static var previews: some View {
        PromotionsView()
    }
}







