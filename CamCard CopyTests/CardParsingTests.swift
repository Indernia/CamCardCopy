import XCTest

@testable import CamCard_Copy

final class CardParsingTests: XCTestCase {
    private let parser = CardFieldParser()

    func testT07StandardFieldsAreParsed() {
        let fields = parser.parse(
            """
            Northwind Trading Ltd
            Avery Chen
            Regional Sales Manager
            Mobile: +1 (555) 010-2000
            Tel: +1 (555) 010-3000
            Email: avery.chen@northwind.example
            Website: northwind.example
            742 Evergreen Terrace, Springfield, IL 62704
            """
        )

        XCTAssertEqual(fields.name, "Avery Chen")
        XCTAssertEqual(fields.company, "Northwind Trading Ltd")
        XCTAssertEqual(fields.jobTitle, "Regional Sales Manager")
        XCTAssertEqual(fields.mobile, "+1 (555) 010-2000")
        XCTAssertEqual(fields.phone, "+1 (555) 010-3000")
        XCTAssertEqual(fields.email, "avery.chen@northwind.example")
        XCTAssertEqual(fields.website, "northwind.example")
        XCTAssertEqual(fields.address, "742 Evergreen Terrace, Springfield, IL 62704")
        XCTAssertTrue(fields.extraPhones.isEmpty)
        XCTAssertTrue(fields.extraEmails.isEmpty)
    }

    func testT07UnlabelledPhonesUseMobileThenPhone() {
        let fields = parser.parse(
            """
            Lighthouse Labs
            Casey Brooks
            Operations Manager
            +1 (555) 010-9000
            +1 (555) 011-1000
            casey.brooks@lighthouse.example
            lighthouse.example
            """
        )

        XCTAssertEqual(fields.mobile, "+1 (555) 010-9000")
        XCTAssertEqual(fields.phone, "+1 (555) 011-1000")
    }

    func testT08LabelledValuesWinOverGuesses() {
        let fields = parser.parse(
            """
            Acme Widgets
            Jordan Ellis
            Account Executive
            M +1 (555) 010-4000
            T +1 (555) 010-5000
            E jordan.ellis@acme.example
            W acme.example
            """
        )

        XCTAssertEqual(fields.mobile, "+1 (555) 010-4000")
        XCTAssertEqual(fields.phone, "+1 (555) 010-5000")
        XCTAssertEqual(fields.email, "jordan.ellis@acme.example")
        XCTAssertEqual(fields.website, "acme.example")
    }

    func testT09AbsentFieldsStayNilAndAreNeverDerived() {
        let fields = parser.parse(
            """
            Jordan Ellis
            Account Executive
            jordan.ellis@acme.example
            """
        )

        XCTAssertEqual(fields.name, "Jordan Ellis")
        XCTAssertEqual(fields.jobTitle, "Account Executive")
        XCTAssertEqual(fields.email, "jordan.ellis@acme.example")
        XCTAssertNil(fields.company)
        XCTAssertNil(fields.website, "the email domain must not become a website")
        XCTAssertNil(fields.phone)
        XCTAssertNil(fields.mobile)
        XCTAssertNil(fields.address)
    }

    func testT10MultipleEmailsAreKeptAndFaxIsExcluded() {
        let fields = parser.parse(
            """
            Blue Harbour Consulting
            Morgan Tate
            Principal Consultant
            Mobile: +1 (555) 010-6000
            Office: +1 (555) 010-7000
            Fax: +1 (555) 010-8000
            Email: morgan.tate@blueharbour.example
            orders@blueharbour.example
            Web: blueharbour.example
            """
        )

        XCTAssertEqual(fields.mobile, "+1 (555) 010-6000")
        XCTAssertEqual(fields.phone, "+1 (555) 010-7000")
        XCTAssertEqual(fields.email, "morgan.tate@blueharbour.example")
        XCTAssertEqual(fields.extraEmails, ["orders@blueharbour.example"])
        XCTAssertEqual(fields.website, "blueharbour.example")
        XCTAssertFalse(fields.mobile?.contains("010-8000") ?? false)
        XCTAssertFalse(fields.phone?.contains("010-8000") ?? false)
        XCTAssertFalse(fields.extraPhones.contains(where: { $0.contains("010-8000") }))
    }
}
