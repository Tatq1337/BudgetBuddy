import SwiftUI
import CoreData
import SwiftUICharts

struct BudgetView: View {
    @State private var item: String = ""
    @State private var price: String = ""
    @State private var lastRefreshDate: Date = Date()
    @Environment(\.managedObjectContext) private var viewContext
    let expenses = ["Jedzenie", "Mieszkanie", "Zdrowie", "Chemia", "Relaks", "Ubrania", "Transport", "Online", "Inne"]
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    var body: some View {
        NavigationView {
            Form {
                LineChartView(data: fetchDataForChart(), title: "Ten miesiac", form: ChartForm.large, rateValue: calculatePriceDifference())
                Section(header: Text("Nowy wydatek")) {
                    Picker("Wydatek", selection: $item) {
                        Text("").tag("")
                        ForEach(expenses, id: \.self) {
                            Text($0)
                        }
                    }
                    TextField("Cena", text: $price).keyboardType(.decimalPad)
                }
                Section(header: Text("Lista wydatkow")) {
                    List {
                        ForEach(items) { item in
                            
                            VStack(alignment: .leading) {
                                Text(item.item ?? "")
                                HStack {
                                    Text((item.price ?? "") + " zł")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(item.timestamp!, formatter: itemFormatter)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
            }
            
            .navigationBarTitle("Twoje wydatki")
            .toolbar {
                ToolbarItem {
                    Button(action: hideKeyboard) {
                        Label("Hide Keyboard", systemImage: "keyboard.chevron.compact.down")
                    }
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
        .onAppear {
            // refresh the fetch request every 5 seconds
            let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                lastRefreshDate = Date()
                viewContext.refreshAllObjects()
            }
            timer.fire()
        }
    }
    
    private func addItem() {
        if !price.isEmpty && !item.isEmpty {
            withAnimation {
                let newItem = Item(context: viewContext)
                newItem.timestamp = Date()
                newItem.item = item
                newItem.price = price
                
                do {
                    try viewContext.save()
                    price = ""
                    item = ""
                    
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
    
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
                viewContext.refreshAllObjects()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func fetchDataForChart() -> [Double] {
        var prices: [Double] = []
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        
        for item in items {
            if let itemPrice = Double(item.price ?? ""),
               let timestampDate = item.timestamp,
               timestampDate > oneMonthAgo {
                
                prices.insert(itemPrice, at: 0)
            }
        }
        
        return prices
    }
    
    private func calculatePriceDifference() -> Int? {
        var prices: [Double] = []
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        var firstHalf: [Double] = []
        var secondHalf: [Double] = []
        
        for item in items {
            if let itemPrice = Double(item.price ?? ""),
               let timestampDate = item.timestamp,
               timestampDate > oneMonthAgo {
                
                prices.insert(itemPrice, at: 0)
            }
        }
        
        let halfIndex = prices.count / 2
        
        if halfIndex > 0 {
            firstHalf = Array(prices.prefix(upTo: halfIndex))
            secondHalf = Array(prices.suffix(from: halfIndex))
        }
        
        guard !firstHalf.isEmpty, !secondHalf.isEmpty else {
            return nil
        }
        
        let averageFirstHalf = Int(firstHalf.reduce(0, +) / Double(firstHalf.count))
        let averageSecondHalf = Int(secondHalf.reduce(0, +) / Double(secondHalf.count))
        
        return averageSecondHalf - averageFirstHalf
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    return formatter
}()

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

