//
//  ViewController.swift
//  LandmarkRemark
//
//  Created by NguyenPhuongkhoa on 22/02/2024.
//

import UIKit
import MapKit
import RealmSwift

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var txt_Description: UITextField!
    @IBOutlet weak var txt_Location: UITextField!
    @IBOutlet weak var txt_Longtidude: UITextField!
    @IBOutlet weak var txt_Latitude: UITextField!
    @IBOutlet weak var btn_ok: UIButton!
    @IBOutlet weak var btn_cancel: UIButton!
    @IBOutlet weak var btn_current_position: UIButton!
    @IBOutlet weak var view_alert: UIView!
    @IBOutlet weak var search_bar: UISearchBar!
    @IBOutlet weak var tbl_content: UITableView!
    @IBOutlet weak var view_yourNotes: UIView!
    @IBOutlet weak var btn_notes: UIButton!
    @IBOutlet weak var view_current_positon: UIView!
    @IBOutlet weak var img_location: UIImageView!
    
    let locationManager = CLLocationManager()
    var tappedCoordinate: CLLocationCoordinate2D?
    var notes: Results<Comment>!
    let realm = try! Realm()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        loadNotesFromRealm()
        mapView.delegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        loadNotes()
        loadNotesFromRealm()
        ConfigView()
        
        btn_cancel.addTarget(self, action: #selector(btnCancelTapped), for: .touchUpInside)
        btn_ok.addTarget(self, action: #selector(btnOkTapped), for: .touchUpInside)
        btn_notes.addTarget(self, action: #selector(NavigateToNote), for: .touchUpInside)
        btn_current_position.addTarget(self, action: #selector(focusOnUserLocation), for: .touchUpInside)
    }
    
    func ConfigView()
    {
        locationManager.delegate = self
        mapView.delegate = self
        search_bar.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        mapView.mapType = .hybridFlyover
        
        tbl_content.delegate = self
        tbl_content.dataSource = self
        tbl_content.backgroundColor = UIColor.white
        
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        tbl_content.register(CustomTableViewCell.self, forCellReuseIdentifier: "YourCellIdentifier")
        view_alert.addGestureRecognizer(tapGesture)
        view_alert.layer.cornerRadius = 15
        btn_cancel.layer.cornerRadius = 15
        search_bar.layer.cornerRadius = 15
        view_yourNotes.layer.cornerRadius = 15
        btn_notes.layer.cornerRadius = 15
        view_current_positon.layer.cornerRadius = 30
        tbl_content.layer.cornerRadius = 10
        search_bar.layer.masksToBounds = true
        tbl_content.isHidden = true
        mapView.resignFirstResponder()
        self.mapView.endEditing(true)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        img_location.image = UIImage(named: "location")

    }
    
    @objc func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText.isEmpty{
            tbl_content.isHidden = false
            loadNotes()
        }
        else
        {      tbl_content.isHidden = false
            notes  = realm.objects(Comment.self).filter("title CONTAINS[cd] %@", searchText)
            tbl_content.reloadData()
        }
    }

    
    @IBAction func NavigateToNote(_ sender: Any) {
        if let yourNotesVC = storyboard?.instantiateViewController(withIdentifier: "YourNotesController") as? YourNotesController {
           present(yourNotesVC, animated: true)
        }
        }
    
    func loadNotes()
    {
        notes = realm.objects(Comment.self)
        if(search_bar.text == "")
        {
            tbl_content.isHidden = true
        }
        tbl_content.reloadData()
    }
    
    
    @objc func dismissKeyboard() {
        view_alert.resignFirstResponder()
        txt_Description.resignFirstResponder()
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            let locationInView = gestureRecognizer.location(in: mapView)
            tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
            mapView.setCenter(tappedCoordinate!, animated: true)
            view_alert.isHidden = false;
            
            btn_ok.addTarget(self, action: #selector(btnOkTapped), for: .touchUpInside)
            btn_cancel.addTarget(self, action: #selector(btnOkTapped), for: .touchUpInside)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YourCellIdentifier", for: indexPath) as! CustomTableViewCell
        let note = notes[indexPath.row]
        cell.config(comment: note)
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
          let coordinate = CLLocationCoordinate2D(latitude: note.latitude, longitude: note.longitude)
          focusOnLocation(coordinate)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
      }
  

    
   public func focusOnLocation(_ coordinate: CLLocationCoordinate2D) {
         let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
         mapView.setRegion(region, animated: true)
        tbl_content.isHidden = true
     }
    
    @objc func focusOnUserLocation() {
           guard let userLocation = mapView.userLocation.location else {
               return
           }
           let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
           mapView.setRegion(region, animated: true)
        
        
        loadNotes();
        loadNotesFromRealm()
       }
    
    
    @objc func btnOkTapped() {
        if let noteToUpdate = realm.objects(Comment.self).filter("title == %@", "Note title").first {
            do {
                try realm.write {
                    noteToUpdate.title = txt_Description.text ?? ""
                }
                print("Note updated successfully")
            } catch {
                print("Error updating note: \(error.localizedDescription)")
            }
        } else {
            print("Note not found")
        }
        view_alert.isHidden = true
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
    }
    
    @objc func btnCancelTapped() {
        view_alert.isHidden = true
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
//        mapView.setRegion(region, animated: true)
//        
//    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
          if status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled() {
              // Handle authorization status
              print("Location services are not enabled")
          } else {
              // Start updating location
              locationManager.startUpdatingLocation()
          }
      }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView!.canShowCallout = true
            let detailButton = UIButton(type: .detailDisclosure)
            annotationView!.rightCalloutAccessoryView = detailButton
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        var latitude = Double()
        var longitude = Double()
        if let annotation = view.annotation {
            latitude = annotation.coordinate.latitude
            longitude = annotation.coordinate.longitude
        }
        view_alert.isHidden = false
        if control == view.rightCalloutAccessoryView {
          
            let notesWithMatchingLatitude = realm.objects(Comment.self).filter("latitude == %@", latitude)

            if let note = notesWithMatchingLatitude.first {
                mapView.resignFirstResponder()
                self.mapView.endEditing(true)
                view_alert.resignFirstResponder()
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                txt_Description.text = note.desc
                txt_Location.text = note.title
                var latitudeString = String(format: "%.2f", note.latitude)
                var longitudeString = String(format: "%.2f", note.longitude)
                txt_Latitude.text = latitudeString
                txt_Longtidude.text = longitudeString
            } else {
                txt_Description.text = ""
                txt_Latitude.text = ""
                txt_Location.text = ""
            }
        }
    }
    
  
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            let alertController = UIAlertController(title: "Add Note", message: "Enter your note", preferredStyle: .alert)
            alertController.addTextField { (textField) in
                textField.placeholder = "Address"
            }
            alertController.addTextField { (textField) in
                textField.placeholder = "Description"
            }
            
            let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
                if let noteText = alertController.textFields?.first?.text,
                   let descText = alertController.textFields?.last?.text {
                    self.saveNoteWithCoordinate(noteText: noteText, descText: descText, coordinate: coordinate)
                    self.addAnnotationToMap(coordinate: coordinate, title: noteText)
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }

    func saveNoteWithCoordinate(noteText: String,descText: String, coordinate: CLLocationCoordinate2D) {
        let note = Comment()
        note.title = noteText
        note.desc = descText
        note.latitude = coordinate.latitude
        note.longitude = coordinate.longitude
        
        do {
            try realm.write{
                realm.add(note)
            }
            let alertController = UIAlertController(title: "Notice ", message: "Your Note have been saved", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
               
            }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
        }
        catch{
            print("Error saving note: \(error.localizedDescription)")
        }
    }
    
    // Add annotation to the map view
    func addAnnotationToMap(coordinate: CLLocationCoordinate2D, title: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    
    func loadNotesFromRealm()
    {
        let notes = realm.objects(Comment.self)
        for note in notes  {
            let coordinate = CLLocationCoordinate2D(latitude: note.latitude, longitude: note.longitude)
            addAnnotationToMap(coordinate: coordinate, title: note.title)
        }
    }
    
    
}
class CustomTableViewCell: UITableViewCell {
    
    public var titleLbl : UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.black
        lbl.numberOfLines = 1
        return lbl
    }()
    
    private var img_icon : UIImageView = {
        let icon = UIImageView()
        return icon
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    internal func config(comment : Comment){
        contentView.addSubview(titleLbl)
        contentView.addSubview(img_icon)
        img_icon.image = UIImage(named: "map")

        titleLbl.text = comment.title
        print("Tittle here: " + comment.title)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLbl.frame = CGRect(x: 30, y: 15, width: contentView.bounds.width - 20, height: contentView.bounds.height - 20)
        img_icon.frame = CGRect(x: 10, y: 23, width: 15, height: 15)
        
    }
}
