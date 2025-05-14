import Foundation
import FirebaseFirestore
import Combine
import FirebaseAuth

class HomeViewModel: ObservableObject {
    // Published properties for UI updates
    @Published var business: Business?
    @Published var account: Account?
    @Published var recentTransactions: [Transaction] = []
    @Published var businessStats: BusinessStats?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Firebase references
    private var db = Firestore.firestore()
    private var auth = Auth.auth()
    private var listenerRegistration: ListenerRegistration?
    
    // Cancellables for Combine
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load data when initializing
        Task {
            await fetchData()
        }
    }
    
    @MainActor
    func fetchData() async {
        guard let userID = auth.currentUser?.uid else {
            print("User is not authenticated in HomeViewModel.")
            errorMessage = "Usuario no autenticado. Por favor, inicia sesión."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch business data for the current user using the Firebase manager
            let businesses = try await FirebaseManager.shared.getDocuments(
                from: "businesses",
                whereField: "userId",
                isEqualTo: userID,
                limit: 1,
                as: Business.self
            )
            
            if let business = businesses.first {
                self.business = business
                
                // If business found, fetch related account
                if let businessID = self.business?.id {
//                    await fetchAccount(for: businessID)
//                    await fetchBusinessStats(for: businessID)
                }
            } else {
                // Business not found, create a default one for demo purposes
                await createDefaultBusiness(for: userID)
            }
        } catch {
            print("Error fetching business data: \(error.localizedDescription)")
            errorMessage = "Error cargando datos: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    private func createDefaultBusiness(for userID: String) async {
        // Create a default business for demonstration
        let defaultBusiness = Business(
            name: "Abarrotes Leticia",
            type: "Retail",
            userId: userID,
            isFormalized: true,
            registrationDate: Date(),
            industry: "Retail",
            numberOfEmployees: 5
        )
        
        do {
            // Save to Firestore using our manager
            let businessRef = try await FirebaseManager.shared.createDocument(
                in: "businesses",
                data: defaultBusiness
            )
            
            // Update local state with the saved business (including the new Firestore ID)
            let newBusiness = try await FirebaseManager.shared.getDocument(
                from: "businesses",
                id: businessRef.documentID,
                as: Business.self
            )
            
            self.business = newBusiness
            
            // Create a default account for this business
            if let businessID = self.business?.id {
                await createDefaultAccount(for: businessID)
                await createDefaultStats(for: businessID)
            }
        } catch {
            print("Error creating default business: \(error.localizedDescription)")
            errorMessage = "Error creando negocio predeterminado: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    private func createDefaultAccount(for businessID: String) async {
        // Create a default account
        let defaultAccount = Account(
            businessId: businessID,
            accountNumberLastDigits: "5847",
            balance: 83459.25,
            currency: "MXN",
            accountType: "Checking"
        )
        
        do {
            // Save to Firestore using our manager
            let accountRef = try await FirebaseManager.shared.createDocument(
                in: "accounts",
                data: defaultAccount
            )
            
            // Update local state
            let newAccount = try await FirebaseManager.shared.getDocument(
                from: "accounts",
                id: accountRef.documentID,
                as: Account.self
            )
            
            self.account = newAccount
            
            // Create sample transactions
            if let accountID = self.account?.id {
                await createSampleTransactions(for: accountID)
            }
        } catch {
            print("Error creating default account: \(error.localizedDescription)")
            errorMessage = "Error creando cuenta predeterminada: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    private func createSampleTransactions(for accountID: String) async {
        // Create sample transactions
        let sampleTransactions = [
            Transaction(
                accountId: accountID,
                description: "Pago Terminal",
                amount: 1250.00,
                date: Calendar.current.date(byAdding: .day, value: 0, to: Date())!,
                type: .income,
                category: "Sales",
                paymentMethod: "Card"
            ),
            Transaction(
                accountId: accountID,
                description: "Pago Proveedor",
                amount: -3780.50,
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                type: .expense,
                category: "Supplies",
                paymentMethod: "Transfer"
            ),
            Transaction(
                accountId: accountID,
                description: "Cobro con tarjeta",
                amount: 475.00,
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                type: .income,
                category: "Sales",
                paymentMethod: "Card"
            )
        ]
        
        do {
            // Save each transaction using the manager
            for transaction in sampleTransactions {
                _ = try await FirebaseManager.shared.createDocument(
                    in: "transactions",
                    data: transaction
                )
            }
            
            // Update local state
            self.recentTransactions = sampleTransactions
        } catch {
            print("Error creating sample transactions: \(error.localizedDescription)")
            errorMessage = "Error creando transacciones de muestra: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    private func createDefaultStats(for businessID: String) async {
        // Create default business stats
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        let currentPeriod = dateFormatter.string(from: Date())
        
        let defaultStats = BusinessStats(
            businessId: businessID,
            period: currentPeriod,
            totalSales: 45762.00,
            totalExpenses: 16320.00,
            transactionCount: 87,
            averageTicketSize: 526.00
        )
        
        do {
            // Save to Firestore using our manager
            let statsRef = try await FirebaseManager.shared.createDocument(
                in: "businessStats",
                data: defaultStats
            )
            
            // Update local state
            let newStats = try await FirebaseManager.shared.getDocument(
                from: "businessStats",
                id: statsRef.documentID,
                as: BusinessStats.self
            )
            
            self.businessStats = newStats
        } catch {
            print("Error creating default stats: \(error.localizedDescription)")
            errorMessage = "Error creando estadísticas predeterminadas: \(error.localizedDescription)"
        }
    }
    
//    @MainActor
//    private func fetchAccount(for businessID: String) async {
//        do {
//            let accounts = try await FirebaseManager.shared.getDocuments(
//                from: "accounts",
//                whereField: "businessId",
//                isEqualTo: businessID,
//                limit: 1,
//                as: Account.self
//            )
//            
//            if let account = accounts.first {
//                self.account = account
//                
//                // If account found, fetch transactions
//                if let accountID = self.account?.id {
//                    await fetchTransactions(for: accountID)
//                    
//                    // Start listening for account balance changes
//                    startBalanceListener(for: accountID)
//                }
//            } else {
//                print("No account found for business ID: \(businessID)")
//                // Create a default account if none exists
//                await createDefaultAccount(for: businessID)
//            }
//        } catch {
//            print("Error fetching account: \(error.localizedDescription)")
//            errorMessage = "Error cargando cuenta: \(error.localizedDescription)"
//        }
//    }
    
//    @MainActor
//    private func fetchTransactions(for accountID: String) async {
//        do {
//            let transactions = try await FirebaseManager.shared.getDocuments(
//                from: "transactions",
//                whereField: "accountId",
//                isEqualTo: accountID,
//                orderBy: "date",
//                descending: true,
//                limit: 5,
//                as: Transaction.self
//            )
//            
//            self.recentTransactions = transactions
//            
//            if self.recentTransactions.isEmpty {
//                // If no transactions, create sample ones for demo
//                await createSampleTransactions(for: accountID)
//            }
//        } catch {
//            print("Error fetching transactions: \(error.localizedDescription)")
//            errorMessage = "Error cargando transacciones: \(error.localizedDescription)"
//        }
//    }
    
//    @MainActor
//    private func fetchBusinessStats(for businessID: String) async {
//        do {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM"
//            let currentPeriod = dateFormatter.string(from: Date())
//            
//            let stats = try await FirebaseManager.shared.getDocuments(
//                from: "businessStats",
//                whereField: "businessId",
//                isEqualTo: businessID,
//                orderBy: "period",
//                descending: true,
//                limit: 1,
//                as: BusinessStats.self
//            )
//            
//            if let latestStats = stats.first {
//                self.businessStats = latestStats
//            } else {
//                // Create default stats for demo
//                await createDefaultStats(for: businessID)
//            }
//        } catch {
//            print("Error fetching business stats: \(error.localizedDescription)")
//            errorMessage = "Error cargando estadísticas: \(error.localizedDescription)"
//        }
//    }
    
    func startBalanceListener(for accountID: String) {
        stopBalanceListener()
        
        listenerRegistration = FirebaseManager.shared.listenToDocument(
            in: "accounts",
            id: accountID,
            as: Account.self
        ) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedAccount):
                    self.account = updatedAccount
                    print("Balance updated via listener: \(updatedAccount.balance)")
                case .failure(let error):
                    print("Error listening for account updates: \(error.localizedDescription)")
                    self.errorMessage = "Error actualizando saldo: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func stopBalanceListener() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }
    
    deinit {
        stopBalanceListener()
    }
}
