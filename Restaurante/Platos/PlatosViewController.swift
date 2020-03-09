

import UIKit
import CoreData

class PlatosViewController: UIViewController, UITableViewDataSource, PlatoTableViewCellDelegate, NSFetchedResultsControllerDelegate, UISearchResultsUpdating  {
    
    
    
    @IBOutlet weak var tabla: UITableView!
    var frc : NSFetchedResultsController<Plato>!
    
    let searchController = UISearchController(searchResultsController: nil)
    let throttler = Throttler(minimumDelay: 0.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabla.dataSource = self
        //TODO: crear un NSFetchedResultsController
        let miDelegate = UIApplication.shared.delegate! as! AppDelegate
        let miContexto = miDelegate.persistentContainer.viewContext
        
        let consulta = NSFetchRequest<Plato>(entityName: "Plato")
        let sortDescriptors = [NSSortDescriptor(key:"tipo", ascending:true)]
        consulta.sortDescriptors = sortDescriptors
        
        self.frc = NSFetchedResultsController<Plato>(fetchRequest: consulta, managedObjectContext: miContexto, sectionNameKeyPath: "tipo", cacheName: "miCache")
        
        //ejecutamos el fetch
        try! self.frc.performFetch()
        
        self.frc.delegate = self;
        
        //ListaNotasController recibirá lo que se está escribiendo en la barra de búsqueda
        self.searchController.searchResultsUpdater = self
        //Configuramos el search controller
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Buscar texto"
        //Lo añadimos a la tabla
        self.searchController.searchBar.sizeToFit()
        self.tabla.tableHeaderView = searchController.searchBar
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TODO devolver el número de filas en la sección
        return self.frc.sections![section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //TODO: devolver el título de la sección
        return self.frc.sections![section].name
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //TODO: devolver el número de secciones
        return self.frc.sections!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celda = tableView.dequeueReusableCell(withIdentifier: "celdaPlato", for: indexPath) as! PlatoTableViewCell
        
        //Necesario para que funcione el botón "añadir"
        celda.delegate = self
        celda.index = indexPath
        
        //TODO: rellenar la celda con los datos del plato: nombre, precio y descripción
        //Para formato moneda puedes usar un NumberFormatter con estilo moneda
        let plato = self.frc.object(at: indexPath)
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        let formateado = fmt.string(from: NSNumber(value: plato.precio)) //€10.70
        
        celda.nombreLabel.text = plato.nombre
        celda.descripcionLabel.text = plato.descripcion
        celda.precioLabel.text = formateado
        
        return celda
    }
    
    //Se ha pulsado el botón "Añadir"
    func platoAñadido(indexPath: IndexPath) {
        //TODO: obtener el Plato en la posición elegida
        //let platoElegido : Plato! = nil
        let platoElegido : Plato! = self.frc.object(at: indexPath)        
        //Le pasamos el plato elegido al controller de la pantalla de pedido
        //Y saltamos a esa pantalla
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Tu Pedido") as! PedidoActualViewController
        
        //TODO: DESCOMENTAR ESTA LINEA!!!!!!!!!
        vc.platoElegido = platoElegido
        
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    func updateSearchResults(for searchController: UISearchController) {
        
        throttler.throttle {
            
            let texto = searchController.searchBar.text!
            NSFetchedResultsController<Plato>.deleteCache(withName: "miCache")
            if(texto != ""){
                let pred = NSPredicate(format: "nombre CONTAINS[cd] %@", argumentArray:[texto])
                self.frc.fetchRequest.predicate = pred
               // do{
                    try! self.frc.performFetch()
                    self.tabla.reloadData()
                /*}catch let error{
                    print("Error al actualizar el frc: \(error)")
                }*/
            }else{
                self.frc.fetchRequest.predicate = nil
               // do{
                    try! self.frc.performFetch()
                    self.tabla.reloadData()
               /* }catch let error{
                    print("Error al actualizar el frc: \(error)")
                }*/
            }
            
        }
    }
    

}
