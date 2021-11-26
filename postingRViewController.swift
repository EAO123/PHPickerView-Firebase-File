//
//  postingRViewController.swift
//  _NoteBox_
//
//  Created by Ebun Oguntola on 9/7/21.
//

import UIKit
import PhotosUI
import Firebase
import FirebaseStorage

//PHPICKERAHHHH

class postingRViewController: UIViewController
{
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var pickVideoButton: UIButton!
    @IBOutlet var submitButton: UIButton!
    
    var uploadedYet = false
    let uid = Auth.auth().currentUser?.uid
    let fileID = UUID().uuidString
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        checkPermission()
        
        errorLabel.text = " "
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func pickVideo(_ sender: Any) { if !uploadedYet { presentPickerView() } }
    @IBAction func submitTapped(_ sender: Any)
    {
        if uploadedYet
        {
            let db = Firestore.firestore()
            let rPostNumRef = db.collection("globalCounts").document("globalCounts")
            
            db.collection("rPosts").addDocument(data: ["title" : globalPost.title!,
                                                       "album": globalPost.album!,
                                                       "inst": globalPost.inst!,
                                                       "genre": globalPost.genre!,
                                                       "cDocRef": globalPost.docID!,
                                                       "uid": uid!,
                                                       "username": "",
                                                       "composerName": "",
                                                       "composerUID": globalPost.uid!,
                                                       "date": getDate(full: false),
                                                       "videoFilename": fileID,
                                                       "pfpFilename": "MAKE SURE TO PUT PFP FILENAME HERE",
                                                       "rankValue": getDate(full: true)
            ])
            
            rPostNumRef.updateData([
                "rPosts" : FieldValue.increment(Int64(1))
            ])
            
            uploadedYet = false
            performSegue(withIdentifier: "unwindFromRPosting", sender: self)
        }
    }
    
    func presentPickerView()
    {
        var configuration: PHPickerConfiguration = PHPickerConfiguration()
        configuration.filter = PHPickerFilter.videos
        configuration.selectionLimit = 1
        
        let picker: PHPickerViewController = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func uploadVideo(videoURL: URL)
    {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let videoRef = storageRef.child("rPosts/\(uid!)/\(fileID).mov")
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        
        /*var videoData: Data = Data()
        
        do
        {
            videoData = try Data(contentsOf: videoURL)
        }
        catch
        {
            print(error.localizedDescription)
            return
        }*/
        
        /*videoRef.putData(videoData, metadata: metadata)
        { (metaData, error) in
            guard error == nil else
            {
                self.errorLabel.text = error!.localizedDescription
                return
            }
            
            print("greenchecktimeebabyyyy AHHHH")
        }*/
        
        
    }
    
    func getDate(full: Bool) -> String
    {
        let currDate = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        if full
        {
            formatter.dateFormat = "MM-dd-yyyy'T'HH:mm:ssZZZZZ"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
        }

        return formatter.string(from: currDate)
    }
    
    func checkPermission()
    {
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized
        {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in () })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized { }
        else { PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler) }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus)
    {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized
        { print("We have access to photos") }
        else
        { print("No access") }
    }
    
    func customizeButtons(button: UIButton)
    {
        button.backgroundColor = UIColor(red: 89/255, green: 16/255, blue: 124/255, alpha: 1.0)
        button.layer.cornerRadius = button.frame.height / 2
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
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

extension postingRViewController: PHPickerViewControllerDelegate
{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult])
    {
        dismiss(animated: true, completion: nil)
        guard let itemProvider = results.first?.itemProvider else { print("isbeingcalled"); return }
        
        //itemProvider.canLoadObject(ofClass: PHP)
        
        if itemProvider.hasItemConformingToTypeIdentifier("com.apple.quicktime-movie")
        {
            itemProvider.loadFileRepresentation(forTypeIdentifier: "com.apple.quicktime-movie")
            { (url, error) in
                guard error == nil else { print(error!.localizedDescription); return /**Alert**/ }
                
                DispatchQueue.main.async {
                    print(url!)
                }
            }
            
            /*itemProvider.loadItem(forTypeIdentifier: "com.apple.quicktime-movie", options: nil) { (videoFile, error) in
                guard error == nil else { print(error!.localizedDescription); return /**Alert**/ }
                
                DispatchQueue.main.async {
                    print(videoFile!)
                }
            }*/
        }
        
        /*itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier)
        { (url, error) in
            DispatchQueue.main.sync {
                guard error == nil else { print(error!); return /**Alert**/ }
                print(url!)
            }
        }*/
        
        
        
        
        /*itemProvider.loadFileRepresentation(forTypeIdentifier: "com.apple.quicktime-movie")
        { (videoURL, error) in
            guard error == nil else { return }
            print("isbeingcalled")
            
            DispatchQueue.main.async
            {
                let storageRef = Storage.storage().reference()
                
                let videoRef = storageRef.child("rPosts/\(self.uid!)/\(self.fileID).mov")
                let metadata = StorageMetadata()
                metadata.contentType = "video/quicktime"
                
                //self.uploadVideo(videoURL: videoURL!)
                
                print("run")
                
                videoRef.putFile(from: videoURL!, metadata: metadata)
                { (metaData, error) in
                    guard error == nil else
                    {
                        print(videoURL!)
                        print(videoRef.fullPath)
                        self.errorLabel.text = error!.localizedDescription
                        print(error!.localizedDescription)
                        return
                    }
                    
                    print("greenchecktimeebabyyyy AHHHH")
                }
            }
        
            self.uploadedYet = true
        }*/
        
        /*itemProvider.loadItem(forTypeIdentifier: "com.apple.quicktime-movie", options: nil)
        { (videoFile, error) in
            guard error == nil else { return }
            
            
        }*/
    }
}
