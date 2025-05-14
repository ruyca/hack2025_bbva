import Foundation
import FirebaseFirestore

// MARK: - Business Model
struct Business: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var type: String
    var userId: String
    var isFormalized: Bool
    var registrationDate: Date?
    var industry: String?
    var numberOfEmployees: Int?
    
    // Add Firebase timestamp support
    enum CodingKeys: String, CodingKey {
        case id, name, type, userId, isFormalized, industry, numberOfEmployees
        case registrationDate
    }
    
    init(id: String? = nil, name: String, type: String, userId: String, isFormalized: Bool = false,
         registrationDate: Date? = nil, industry: String? = nil, numberOfEmployees: Int? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.userId = userId
        self.isFormalized = isFormalized
        self.registrationDate = registrationDate
        self.industry = industry
        self.numberOfEmployees = numberOfEmployees
    }
}

// MARK: - Account Model
struct Account: Identifiable, Codable {
    @DocumentID var id: String?
    var businessId: String
    var accountNumberLastDigits: String
    var balance: Double
    var currency: String
    var accountType: String
    
    init(id: String? = nil, businessId: String, accountNumberLastDigits: String,
         balance: Double = 0.0, currency: String = "MXN", accountType: String = "Checking") {
        self.id = id
        self.businessId = businessId
        self.accountNumberLastDigits = accountNumberLastDigits
        self.balance = balance
        self.currency = currency
        self.accountType = accountType
    }
}

// MARK: - Transaction Model
struct Transaction: Identifiable, Codable {
    @DocumentID var id: String?
    var accountId: String
    var description: String
    var amount: Double
    var date: Date
    var type: TransactionType
    var category: String?
    var paymentMethod: String?
    
    init(id: String? = nil, accountId: String, description: String, amount: Double,
         date: Date = Date(), type: TransactionType, category: String? = nil, paymentMethod: String? = nil) {
        self.id = id
        self.accountId = accountId
        self.description = description
        self.amount = amount
        self.date = date
        self.type = type
        self.category = category
        self.paymentMethod = paymentMethod
    }
}

// MARK: - Transaction Type Enum
enum TransactionType: String, Codable {
    case income
    case expense
}

// MARK: - BusinessStats Model
struct BusinessStats: Identifiable, Codable {
    @DocumentID var id: String?
    var businessId: String
    var period: String // Format: "YYYY-MM"
    var totalSales: Double
    var totalExpenses: Double
    var transactionCount: Int
    var averageTicketSize: Double?
    
    init(id: String? = nil, businessId: String, period: String, totalSales: Double = 0.0,
         totalExpenses: Double = 0.0, transactionCount: Int = 0, averageTicketSize: Double? = nil) {
        self.id = id
        self.businessId = businessId
        self.period = period
        self.totalSales = totalSales
        self.totalExpenses = totalExpenses
        self.transactionCount = transactionCount
        self.averageTicketSize = averageTicketSize
    }
}
