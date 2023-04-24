import SwiftUI
import CoreData

struct CalendarView: View {
    @State private var name: String = ""
    @State private var expDate: Date = Date()
    @State private var lastRefreshDate: Date = Date()
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Subs.exp_date, ascending: false)],
        animation: .default)
    private var subs: FetchedResults<Subs>

    var body: some View {
        NavigationView {
            Form {
                                Section(header: Text("Nowa subskrypcja")) {
                                    TextField("Nazwa", text: $name)
                                    
                                    DatePicker("Data wygaśnięcia", selection: $expDate, displayedComponents: [.date])
                }
                Section(header: Text("Lista subskrypcji")) {
                    List {
                        ForEach(subs) { sub in
                            HStack{
                                Text(sub.name ?? "")
                                Spacer()
                                Text(sub.exp_date!, formatter: dateFormatter)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete(perform: deleteSubs)
                    }
                }
            }

            .navigationBarTitle("Twoje subskrypcje")
            .toolbar {
                ToolbarItem {
                    Button(action: hideKeyboard) {
                        Label("Hide Keyboard", systemImage: "keyboard.chevron.compact.down")
                    }
                }
                ToolbarItem {
                    Button(action: addSub) {
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

    private func addSub() {
        if !name.isEmpty {
            withAnimation {
                let newSub = Subs(context: viewContext)
                newSub.exp_date = expDate
                newSub.name = name
                
                do {
                    try viewContext.save()
                    name = ""
                    expDate = Date()
                    
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }

    private func deleteSubs(offsets: IndexSet) {
        withAnimation {
            offsets.map { subs[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
                viewContext.refreshAllObjects()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    return formatter
}()

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

#if canImport(UIKit)
extension View{
    func hideKeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
