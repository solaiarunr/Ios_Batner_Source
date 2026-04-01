import StoreKit

class IAPManager {
    static let shared = IAPManager()
    private init() {}

    // Fetch products
    func loadProducts(ids: [String]) async throws -> [Product] {
        return try await Product.products(for: ids)
    }

    // Purchase product
    func purchase(_ product: Product) async throws -> Transaction {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            return transaction
        case .userCancelled, .pending:
            throw NSError(domain: "IAP", code: 1, userInfo: [NSLocalizedDescriptionKey: "Purchase cancelled"])
        @unknown default:
            throw NSError(domain: "IAP", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw NSError(domain: "IAP", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unverified transaction"])
        case .verified(let safe):
            return safe
        }
    }
}



