import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager {
    // Singleton instance
    static let shared = FirebaseManager()
    
    // Firestore database reference
    let db = Firestore.firestore()
    
    // Private initializer for singleton
    private init() {
        // Configure Firebase settings if needed
        let settings = db.settings
        settings.isPersistenceEnabled = true
        db.settings = settings
    }
    
    // MARK: - Helper Methods for Firestore
    
    // Create a document with auto-generated ID
    func createDocument<T: Encodable>(in collection: String, data: T) async throws -> DocumentReference {
        let collectionRef = db.collection(collection)
        return try collectionRef.addDocument(from: data)
    }
    
    // Get a document by ID
    func getDocument<T: Decodable>(from collection: String, id: String, as type: T.Type) async throws -> T {
        let documentRef = db.collection(collection).document(id)
        let snapshot = try await documentRef.getDocument()
        
        guard snapshot.exists else {
            throw NSError(domain: "FirebaseManager", code: 404,
                         userInfo: [NSLocalizedDescriptionKey: "Document not found"])
        }
        
        return try snapshot.data(as: T.self)
    }
    
    // Update a document
    func updateDocument<T: Encodable>(in collection: String, id: String, data: T) async throws {
        let documentRef = db.collection(collection).document(id)
        try documentRef.setData(from: data, merge: true)
    }
    
    // Delete a document
    func deleteDocument(from collection: String, id: String) async throws {
        let documentRef = db.collection(collection).document(id)
        try await documentRef.delete()
    }
    
    // Fetch documents with a query
    func getDocuments<T: Decodable>(
        from collection: String,
        whereField field: String? = nil,
        isEqualTo value: Any? = nil,
        orderBy: String? = nil,
        descending: Bool = false,
        limit: Int? = nil,
        as type: T.Type
    ) async throws -> [T] {
        var query: Query = db.collection(collection)
        
        // Apply where clause if provided
        if let field = field, let value = value {
            query = query.whereField(field, isEqualTo: value)
        }
        
        // Apply ordering if provided
        if let orderBy = orderBy {
            query = query.order(by: orderBy, descending: descending)
        }
        
        // Apply limit if provided
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        // Execute query
        let querySnapshot = try await query.getDocuments()
        
        // Convert results to objects
        var results = [T]()
        for document in querySnapshot.documents {
            let data = try document.data(as: T.self)
            results.append(data)
        }
        
        return results
    }
    
    // Listen for real-time updates to a document
    func listenToDocument<T: Decodable>(
        in collection: String,
        id: String,
        as type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> ListenerRegistration {
        let documentRef = db.collection(collection).document(id)
        
        return documentRef.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                completion(.failure(NSError(domain: "FirebaseManager", code: 404,
                                          userInfo: [NSLocalizedDescriptionKey: "Document not found"])))
                return
            }
            
            do {
                let object = try snapshot.data(as: T.self)
                completion(.success(object))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
