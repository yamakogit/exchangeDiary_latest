//
//  FirebaseClient.swift
//  exchangeDiary
//
//  Created by 山田航輝 on 2024/05/27.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import Kingfisher

class FirebaseClient {
    
    var userUid: String = ""
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    static let shared = FirebaseClient()
    
    //userUid取得 (Auth)
    func getUserUid() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            print("ログイン状態不明") //uuid取得失敗
            userUid = ""
            return userUid
        }
        userUid = user.uid //uuid取得成功の場合代入
        print("userUid取得成功: \(userUid)")
        return userUid
    }
    
    //userData取得 (Firestore)
    func getUserData(uid: String? = nil) async throws -> UserDataSet {
        //uuid取得
        userUid = try await getUserUid()
        
        var uid2 = uid
        
        if uid2 == "" {
            uid2 = userUid
        }
        
        let snapshot = try await db.collection("User").document(uid2 ?? userUid).getDocument()
        
        if let userData = try? snapshot.data(as: UserDataSet.self) {
            print("userData取得成功")
            return userData //取得成功
        } else {
            print("userData取得失敗")
            return UserDataSet(
                id: userUid,
                name: "",
                iconURL: "",
                groupUID: "", 
                latestDate: "",
                diary: []) //取得失敗->uuidのみreturn
        }
    }
    
    //groupData取得 (Firestore)
    func getGroupData() async throws -> GroupDataset {
        //uuid取得
        let userData = try await getUserData()
        
        do {
            let snapshot = try await db.collection("Group").document(userData.groupUID).getDocument()
            let groupData = try snapshot.data(as: GroupDataset.self)
            return groupData
        } catch {
            print("Error fetching spot data: \(error)")
            return GroupDataset()
        }
    }
    
    
    //WhereField 該当UIDのArray取得 相手のUID探し(サブ)
    //使わない
    func getMatchingUIDArray(groupUID: String, completion: @escaping ([String]?, Error?) -> Void) {
        var matchingUIDs: [String] = []
        db.collection("User").whereField("groupUID", isEqualTo: groupUID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("エラー: \(error)")
            } else {
                // 条件に合致するドキュメントが見つかった場合
                if let documents = querySnapshot?.documents {
                    for document in documents {
                        // ドキュメントID（UID）を取得して配列に追加
                        let uid = document.documentID
                        matchingUIDs.append(uid)
                    }
                    // 条件に合致するUIDが配列matchingUIDsに格納されました
                    print("条件に合致するUID: \(matchingUIDs)")
                    completion(matchingUIDs, nil)
                    
                } else {
                    print("条件に合致するドキュメントがありません。")
                    completion(nil, nil)
                }
            }
        }
    }
    
    //WhereField 該当UIDのArray取得 相手のUID探し(サブ)②
    //使わない
    func getMatchingUIDArrayAsync(groupUID: String) async throws -> [String] {
        return try await withCheckedThrowingContinuation { continuation in
            FirebaseClient().getMatchingUIDArray(groupUID: groupUID) { (uids, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let uids = uids {
                    continuation.resume(returning: uids)
                } else {
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    
    //getPartnerUIDの取得 <- こっちでやる！
    func getPartnerUID() async throws -> String {
        var partnerUID = ""

        let userData = try await getUserData()
        let userUid = userData.id
        let groupUid = userData.groupUID

        do {
            let uids = try await getMatchingUIDArrayAsync(groupUID: groupUid)
            print("条件に合致するUIDArray: \(uids)")
            
            for electedUid in uids {
                if electedUid != userUid {
                    partnerUID = electedUid
                    print("これです！")
                    print(partnerUID)
                    break
                }
            }
            
            // パートナーなしで自分のUIDを取得
            if partnerUID.isEmpty {
                partnerUID = userUid ?? "不明"
            }
            
        } catch {
            print("Error fetching spot data: \(error)")
            throw error
        }

        return partnerUID
    }
    
    
    //getLatestDiary
    func getLatestDiary(userData: UserDataSet) async throws -> DiaryData {
        let diaries = userData.diary
        let matchingDiary = diaries.last ?? [:]
        let matchingDiaryStruct = DiaryData(title: matchingDiary["title"] ?? "- - - -", photoURL: matchingDiary["photoURL"] ?? "", message: matchingDiary["message"] ?? "- - - -", date: matchingDiary["date"] ?? "- - - -")
        return matchingDiaryStruct
    }
    
    //URLよりStorageから写真の取得
    func getSpotImage(url: String, completion: @escaping (UIImage?) -> Void) {
        
        var url2 = url
        if url2 == "" {
            url2 = "https://firebasestorage.googleapis.com/v0/b/exchangediary-6acce.appspot.com/o/Host%2FRectangle%2012.png?alt=media&token=e05f31ec-77cf-40db-b527-1f6f36bb1dd9"
        }
        let imageURL: URL = URL(string:url2)!
        KingfisherManager.shared.downloader.downloadImage(with: imageURL) { result in
            switch result {
            case .success(let value):
                completion(value.image)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    //diaryの保存
    //userDataへMyDiary/latestDateの保存 (Firestore)
    func saveMyDiary(diary: DiaryData) async throws {
        
        var userData = try await getUserData()
        let oneDiaryData = ["title": diary.title, "photoURL": diary.photoURL, "message": diary.message, "date": diary.date]
        userData.diary.append(oneDiaryData)
        
        
        
        var date1 = ""
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.hour], from: now)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        if let hour = components.hour, hour >= 18 {
            //18時以降
            date1 = dateFormatter.string(from: Date())
        } else {
            //18時以前 -> -1日する
            let calendar = Calendar.current
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) {
                date1 = dateFormatter.string(from: yesterday)
            }
        }
        userData.latestDate = date1
        
        
        
        let docRef = db.collection("User").document(userUid)
        try docRef.setData(from: userData, merge: true) { error in
            if let error = error {
                print("Error updating document: \(error)") //失敗
            } else {
                print("Document successfully updated") //成功
            }
        }
        
        var groupData = try await getGroupData()
        groupData.latestDate = date1
        groupData.latestOpenedUUID = userData.id
        let docRef1 = db.collection("Group").document(userData.groupUID)
        try docRef1.setData(from: groupData, merge: true) { error in
            if let error = error {
                print("Error updating document: \(error)") //失敗
            } else {
                print("Document successfully updated") //成功
            }
        }
        
        
    }
    
    
    //Storageへ写真の保存 & URLのRETURN
    func saveDiaryImage(diaryImage: UIImage) async throws -> String {
        print("写真保存中")
        let storageRef = storage.reference()
        let imagesRef = storageRef.child("DiaryImage")
        let imageName = "\(Date().timeIntervalSince1970).jpg"
        let imageRef = imagesRef.child(imageName)
        
        if let imageData = diaryImage.jpegData(compressionQuality: 0.5) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            try await imageRef.putDataAsync(imageData, metadata: metadata)
            let url: URL = try await imageRef.downloadURL()
            let urlStr: String = url.absoluteString
            return urlStr
        } else {
            return "https://firebasestorage.googleapis.com/v0/b/exchangediary-6acce.appspot.com/o/Host%2FRectangle%2012.png?alt=media&token=e05f31ec-77cf-40db-b527-1f6f36bb1dd9"
        }
    }
    
    
    //initialDataのsave
    func saveNewData(userData: UserDataSet, groupData: GroupDataset? = nil) async throws {
        
        var userData2 = userData
        
        if groupData != nil {
            //groupへの追加
            let docRef1 = self.db.collection("Group")
            let createdgroupUID = docRef1.document().documentID
            print("createdgroupUID: \(createdgroupUID)")
            
            //group保存
            try docRef1.document(createdgroupUID).setData(from: groupData, merge: true) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document successfully updated")
                }
            }
            
            userData2.groupUID = createdgroupUID
        }
        
        //userData保存
        userUid = try await getUserUid()
        let docRef = db.collection("User").document(userUid)
        try docRef.setData(from: userData2, merge: true) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
        
    }
    
    
    //wherefieldで該当データ探す→gUid・groupData取得・returnする
    func searchGroup(groupID: String) async throws -> GroupDataset? {
        do {
            let querySnapshot = try await db.collection("Group").whereField("groupID", isEqualTo: groupID).getDocuments()
            guard let document = querySnapshot.documents.first else {
                // グループが見つからない場合はnilを返す
                return nil
            }
            // ドキュメントが見つかった場合、そのデータをGroupDatasetに変換して返す
            let groupData = try document.data(as: GroupDataset.self)
            
            
            //ここでgroupのメンバー数を確認し、すでに２人であった場合はnilに変更
            do {
                let uids = try await getMatchingUIDArrayAsync(groupUID: groupData.id!)
                print("条件に合致するUIDArray: \(uids)")
                
                if uids.count >= 2 {
                    return nil
                } else {
                    return groupData
                }
                
            } catch {
                print("Error fetching spot data: \(error)")
                throw error
            }
            
        } catch {
            print("Error getting documents: \(error)")
            throw error
        }
    }
    
    
    
    //DataSets
    struct UserDataSet: Codable {
        @DocumentID var id: String?
        var name: String
        var iconURL: String
        var groupUID: String
        var latestDate: String
        var diary: [[String:String]]
    }
    
    struct GroupDataset: Codable {
        @DocumentID var id: String?
        var groupID: String?
        var latestDate: String?
        var latestOpenedUUID: String?
    }
    
    struct DiaryData {
        var title: String
        var photoURL: String
        var message: String
        var date: String
    }
    
    
}
