import Vapor
import HTTP

final class ContactController {

    func getAll(for request: Request) throws -> ResponseRepresentable {
        let userId = try request.getUserId()
        let contacts = try Contact.allForUser(with: userId)
        return try JSON(node: ["contacts": contacts])
    }

    func getContact(for request: Request, contactId: Identifier) throws -> Contact {
        let userId = try request.getUserId()
        return try Contact.contact(for: userId, and: contactId)
    }

    func create(using body: ContactCreationBody) throws -> Contact {
        let contact = body.contact
        try contact.save()
        return contact
    }
}

