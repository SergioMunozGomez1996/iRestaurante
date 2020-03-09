
import UIKit
import CoreData

class PedidosViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource {
   
    
    var frc : NSFetchedResultsController<Pedido>!
    
    
    @IBOutlet weak var tabla: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let miDelegate = UIApplication.shared.delegate! as! AppDelegate
        let miContexto = miDelegate.persistentContainer.viewContext
        
        let consulta = NSFetchRequest<Pedido>(entityName: "Pedido")
        let sortDescriptors = [NSSortDescriptor(key:"fecha", ascending:false)]
        consulta.sortDescriptors = sortDescriptors
        
        self.frc = NSFetchedResultsController<Pedido>(fetchRequest: consulta, managedObjectContext: miContexto, sectionNameKeyPath: nil, cacheName: "miCache")
        
        //ejecutamos el fetch
        try! self.frc.performFetch()
        
        self.frc.delegate = self;
        
        if(self.frc.fetchedObjects != nil) {
            for pedido in self.frc.fetchedObjects!{
                print(pedido)
                print(pedido.total)
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd hh:mm:ss"
                if pedido.fecha != nil {
                    let now = df.string(from: pedido.fecha!)
                    print(now)
                    }
                }
            self.tabla.reloadData()
            }
    }
    
        
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return self.frc.sections![section].numberOfObjects
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           
           let celda = tableView.dequeueReusableCell(withIdentifier: "celdaHistorico", for: indexPath)
           
           let pedido = self.frc.object(at: indexPath)
           
           let df = DateFormatter()
           df.dateFormat = "yyyy-MM-dd hh:mm:ss"
           if pedido.fecha != nil {
               let now = df.string(from: pedido.fecha!)
           
            celda.textLabel?.text = now
            celda.detailTextLabel?.text = String(pedido.total)
        }
        return celda
       }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

