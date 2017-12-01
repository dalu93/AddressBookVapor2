//
//  Contact.swift
//  App
//
//  Created by D'Alberti, Luca on 10/1/17.
//

import Vapor
import FluentProvider
import HTTP

protocol ContactRepresentable {
    var contact: Contact { get }
}

final class Contact: Model {
    let storage = Storage()

    // MARK: Properties and database keys

    var email: String
    var userId: Identifier
    var firstName: String
    var lastName: String?
    var phoneNumber: String?


    static let idKey = "id"
    static let userIdKey = "userId"
    static let emailKey = "email"
    static let firstNameKey = "firstName"
    static let lastNameKey = "lastName"
    static let phoneNumberKey = "phoneNumber"

    /// Creates a new Post
    init(email: String, userId: Identifier, firstName: String, lastName: String? = nil, phoneNumber: String? = nil) {
        self.email = email
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
    }

    // MARK: Fluent Serialization

    /// Initializes the Contact from the
    /// database row
    init(row: Row) throws {
        email = try row.get(Contact.emailKey)
        userId = try row.get(Contact.userIdKey)
        firstName = try row.get(Contact.firstNameKey)
        lastName = try row.get(Contact.lastNameKey)
        phoneNumber = try row.get(Contact.phoneNumberKey)
    }

    // Serializes the Contact to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Contact.emailKey, email)
        try row.set(Contact.userIdKey, userId)
        try row.set(Contact.firstNameKey, firstName)
        try row.set(Contact.lastNameKey, lastName)
        try row.set(Contact.phoneNumberKey, phoneNumber)
        return row
    }
}

// MARK: Fluent Preparation

extension Contact: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Contact
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Contact.emailKey, optional: false)
            builder.int(Contact.userIdKey, optional: false)
            builder.string(Contact.firstNameKey, optional: false)
            builder.string(Contact.lastNameKey, optional: true)
            builder.string(Contact.phoneNumberKey, optional: true)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension Contact: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            email: json.get(Contact.emailKey),
            userId: json.get(Contact.userIdKey),
            firstName: json.get(Contact.firstNameKey),
            lastName: json.get(Contact.lastNameKey),
            phoneNumber: json.get(Contact.phoneNumberKey)
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Contact.emailKey, email)
        try json.set(Contact.firstNameKey, firstName)
        if let lastName = lastName {
            try json.set(Contact.lastNameKey, lastName)
        }

        if let phoneNumber = phoneNumber {
            try json.set(Contact.phoneNumberKey, phoneNumber)
        }
        return json
    }
}

// MARK: HTTP

// This allows Contact models to be returned
// directly in route closures
extension Contact: ResponseRepresentable { }

// MARK: Update

// This allows the Contact model to be updated
// dynamically by the request.
extension Contact: Updateable {
    // Updateable keys are called when `contact.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Contact>] {
        return [
            UpdateableKey(Contact.emailKey, String.self) { contact, newEmail in
                contact.email = newEmail
            },
            UpdateableKey(Contact.firstNameKey, String.self) { contact, newFirstName in
                contact.firstName = newFirstName
            },
            UpdateableKey(Contact.lastNameKey, String.self) { contact, newLastName in
                contact.lastName = newLastName
            },
            UpdateableKey(Contact.phoneNumberKey, String.self) { contact, newPhoneNumber in
                contact.phoneNumber = newPhoneNumber
            }
        ]
    }
}

// MARK: - API
extension Contact {
    static func allForUser(with id: Identifier) throws -> [Contact] {
        return try Contact
            .makeQuery()
            .filter(Contact.userIdKey, id)
            .all()
    }

    static func contact(for userId: Identifier, and contactId: Identifier) throws -> Contact {
        let foundContact = try Contact
            .makeQuery()
            .filter(Contact.userIdKey, userId)
            .filter(Contact.idKey, contactId)
            .all()

        guard foundContact.count > 0 else {
            throw Abort.notFound
        }

        guard foundContact.count == 1 else {
            throw Abort.serverError
        }

        return foundContact.first!
    }
}
