//
//  YourNotesController.swift
//  LandmarkRemark
//
//  Created by NguyenPhuongkhoa on 25/02/2024.
//

import UIKit
import RealmSwift
import CoreLocation

class YourNotesController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate {
  
    @IBOutlet weak var tbl_content: UITableView!
    var notes: Results<Comment>!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbl_content.delegate = self
        tbl_content.dataSource = self
        tbl_content.isHidden = false
        tbl_content.backgroundColor = UIColor.white
        tbl_content.register(CustomTableNotesViewCell.self, forCellReuseIdentifier: "YourCellIdentifier")
        loadNotes()
    }
    
    func loadNotes()
    {
        notes = realm.objects(Comment.self)
        tbl_content.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YourCellIdentifier", for: indexPath) as! CustomTableNotesViewCell
        let note = notes[indexPath.row]
        cell.config(comment: note)
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 80
       }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
         
            do {
                try realm.write {
                    realm.delete(notes[indexPath.row])
                }
            
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Error deleting item from Realm: \(error)")
            }
        }
    }
}
class CustomTableNotesViewCell: UITableViewCell {
    public var titleLbl : UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.black
        lbl.numberOfLines = 1
        return lbl
    }()
    public var descLbl : UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.black
        lbl.numberOfLines = 1
        return lbl
    }()
    
    private var img_icon : UIImageView = {
        let icon = UIImageView()
        return icon
    }()
    
    private var img_icon_desc : UIImageView = {
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
        contentView.addSubview(descLbl)
        contentView.addSubview(img_icon_desc)
        img_icon.image = UIImage(named: "map")
        img_icon_desc.image = UIImage(named: "description.png")
        titleLbl.text = comment.title
        descLbl.text = comment.desc
        print("Tittle here: " + comment.title)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLbl.frame = CGRect(x: 30, y: 20, width: contentView.bounds.width - 20, height: 15)
        img_icon.frame = CGRect(x: 10, y: 20, width: 15, height: 15)
        descLbl.frame = CGRect(x: 30, y: 45, width: contentView.bounds.width - 20, height: 15)
        img_icon_desc.frame = CGRect(x: 10, y: 45, width: 15, height: 15)
       
    }
}
