

import UIKit
import CoreData

class PedidoActualViewController: UIViewController, UITableViewDataSource, LineaPedidoTableViewCellDelegate {

    @IBOutlet weak var tabla: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBAction func realizarPedidoPulsado(_ sender: Any) {
        guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let miContexto = miDelegate.persistentContainer.viewContext
        
        StateSingleton.shared.pedidoActual.fecha = Date()
        StateSingleton.shared.pedidoActual.total = Double(totalLabel.text!)!
        /*let pedidoActual = Pedido(context: miContexto)
        pedidoActual.fecha = Date()
        pedidoActual.lineasPedido = StateSingleton.shared.pedidoActual.lineasPedido
        pedidoActual.total = Double(totalLabel.text!)!*/
        
        do{
            try miContexto.save()
            let pedidoActual = Pedido(context: miContexto)
            StateSingleton.shared.pedidoActual = pedidoActual
        }catch let error{
            print("Error al guardar el contexto: \(error)")
        }
        print("Pedido realizado")
        let alerta = UIAlertController(title: "Éxito", message: "Pedido realizado", preferredStyle: .alert)
        let cancelar = UIAlertAction(title: "OK", style: .destructive, handler: nil)
        alerta.addAction(cancelar)
        present(alerta, animated: true, completion: nil)
        self.tabla.reloadData()
        self.totalLabel.text =  "0€"
    }
    
    
    @IBAction func cancelarPedidoPulsado(_ sender: Any) {
        print("Pedido cancelado")
        guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let miContexto = miDelegate.persistentContainer.viewContext
        miContexto.delete(StateSingleton.shared.pedidoActual)
        do{
            let pedidoActual = Pedido(context: miContexto)
            StateSingleton.shared.pedidoActual = pedidoActual
            try miContexto.save()
        }catch let error{
            print("Error al guardar el contexto: \(error)")
        }
        self.tabla.reloadData()
        self.totalLabel.text =  "0€"
    }
    
    //TODO: descomentar esta línea!!!!
    var platoElegido : Plato!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabla.dataSource = self
        //TODO:
        // - crear el pedido actual si no existe
        guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let miContexto = miDelegate.persistentContainer.viewContext
        
        if StateSingleton.shared.pedidoActual==nil{
            let pedidoActual = Pedido(context: miContexto)
            StateSingleton.shared.pedidoActual = pedidoActual
            
            do{
                try miContexto.save()
            }catch let error{
                print("Error al guardar el contexto: \(error)")
            }
        }
        // - crear la linea de pedido y asociarla al plato y al pedido actual
        if platoElegido != nil{
            let lineaPedido = LineaPedido(context: miContexto)
            lineaPedido.cantidad = 1
            lineaPedido.plato = platoElegido
            lineaPedido.subtotal = platoElegido.precio
            StateSingleton.shared.pedidoActual.addToLineasPedido(lineaPedido)
        }
            
        
        do{
            try miContexto.save()
        }catch let error{
            print("Error al guardar el contexto: \(error)")
        }
        
        var subtotal = 0.0
        for item in StateSingleton.shared.pedidoActual.lineasPedido!{
            let lineaPedidoActual = item as! LineaPedido
            subtotal = subtotal + lineaPedidoActual.subtotal
        }
        self.totalLabel.text = String(subtotal)
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabla.reloadData()
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TODO: devolver el número real de filas de la tabla
        return  StateSingleton.shared.pedidoActual.lineasPedido!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celdaLinea", for: indexPath) as! LineaPedidoTableViewCell
        //Necesario para que funcione el delegate
        celda.pos = indexPath.row
        celda.delegate = self
        
        //TODO: rellenar los datos de la celda
        let lineaPedido = StateSingleton.shared.pedidoActual.lineasPedido?.object(at:indexPath.row) as! LineaPedido
        celda.nombreLabel.text = lineaPedido.plato?.nombre
        celda.cantidadLabel.text = String(lineaPedido.cantidad)
        
        return celda
    }
    
    func cantidadCambiada(posLinea: Int, cantidad: Int) {
        //TODO: actualizar la cantidad de la línea de pedido correspondiente
        guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let miContexto = miDelegate.persistentContainer.viewContext
        
        let lineaPedidoActual = StateSingleton.shared.pedidoActual.lineasPedido?.object(at: posLinea) as! LineaPedido
        print(lineaPedidoActual.subtotal)
        print(cantidad)
        lineaPedidoActual.cantidad = Int16(cantidad)
        lineaPedidoActual.subtotal = lineaPedidoActual.plato!.precio * Double(cantidad)
        
        do{
            try miContexto.save()
        }catch let error{
            print("Error al guardar el contexto: \(error)")
        }
        var subtotal = 0.0
        for item in StateSingleton.shared.pedidoActual.lineasPedido!{
            let lineaPedidoActual = item as! LineaPedido
            subtotal = subtotal + lineaPedidoActual.subtotal
            print( lineaPedidoActual.subtotal)
            
        }
        self.totalLabel.text = String(subtotal)
 
    }
    
    
}
