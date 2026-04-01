

import StoreKit

class SubManager {

    static let shared = SubManager()
    private init() {}

    // MARK: - Load StoreKit Products
    func loadProducts(ids: [String]) async throws -> [Product] {
        return try await Product.products(for: ids)
    }

    // MARK: - Purchase Product
    func purchase(_ product: Product) async throws -> Transaction {

        do {
            let result = try await product.purchase()

            switch result {

            case .success(let verificationResult):
                // Verify Apple Receipt
                let transaction = try checkVerified(verificationResult)

                // Finish the transaction
                await transaction.finish()

                return transaction

            case .userCancelled:
                throw IAPError.message("Purchase cancelled by user.")

            case .pending:
                throw IAPError.message("Purchase pending. Please wait.")

            @unknown default:
                throw IAPError.message("Unknown purchase result.")
            }

        } catch {
            let nsError = error as NSError

            // MARK: - Sandbox Server Issues Handling
            if nsError.domain == "ASDErrorDomain"
                || nsError.domain == "AMSErrorDomain"
                || nsError.code == 500
                || nsError.code == 305 {

                throw IAPError.message(
                    "Apple Sandbox server timeout.\nPlease try again in a few seconds."
                )
            }

            // Other errors
            throw IAPError.message("Unable to complete the purchase. \(nsError.localizedDescription)")
        }
    }

    // MARK: - Verify Transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified(_, let error):
            throw IAPError.message("Unverified transaction: \(error.localizedDescription)")
        }
    }
}

// MARK: - Error Helper
enum IAPError: Error {
    case message(String)

    var localizedDescription: String {
        switch self {
        case .message(let text):
            return text
        }
    }
}
