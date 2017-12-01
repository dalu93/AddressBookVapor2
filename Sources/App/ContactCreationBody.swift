//
//  ContactCreationBody.swift
//  App
//
//  Created by D'Alberti, Luca on 10/8/17.
//

import Vapor
import Validation

// MARK: - ContactCreationBody declaration
struct ContactCreationBody: ValidBody {
    let email: String
    let firstName: String
    let userId: Identifier
    let lastName: String?
    let phoneNumber: String?

    init(request: Request) throws {
        // Getting the userId
        userId = try request.getUserId()

        // Getting the request parameters
        let reqEmail: String = try request.data.get("email")
        let reqFirstName: String = try request.data.get("firstName")
        let reqLastName: String? = try? request.data.get("lastName")
        let reqPhoneNumber: String? = try? request.data.get("phoneNumber")

        // Validating email
        do {
            try reqEmail.validated(by: EmailValidator())
            email = reqEmail
        } catch {
            // log error
            throw Abort.badRequest
        }

        // Validating firstName
        do {
            try reqFirstName.validated(by: Count.min(3))
            try reqFirstName.validated(by: Count.max(32))
            firstName = reqFirstName
        } catch {
            // log error
            throw Abort.badRequest
        }

        // Validating lastName if needed
        if let reqLastName = reqLastName {
            do {
                try reqLastName.validated(by: Count.max(32))
                lastName = reqLastName
            } catch {
                // log error
                throw Abort.badRequest
            }
        } else {
            lastName = nil
        }

        // Validating phoneNumber if needed
        phoneNumber = reqPhoneNumber
    }
}

// MARK: - ContactRepresentable
extension ContactCreationBody: ContactRepresentable {
    var contact: Contact {
        return Contact(
            email: email,
            userId: userId,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber
        )
    }
}
