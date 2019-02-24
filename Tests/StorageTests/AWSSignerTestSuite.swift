/**
 All tests are based off of Amazon's Signature Test Suite
 See: http://docs.aws.amazon.com/general/latest/gr/signature-v4-test-suite.html

 They also include the [`x-amz-content-sha256` header](http://docs.aws.amazon.com/AmazonS3/latest/API/bucket-policy-s3-sigv4-conditions.html).
 */

import XCTest

import HTTP
import Foundation

@testable import Storage

class AWSSignerTestSuite: XCTestCase {
    static var allTests = [
        ("testGetUnreserved", testGetUnreserved),
        ("testGetUTF8", testGetUTF8),
        ("testGetVanilla", testGetVanilla),
        ("testGetVanillaQuery", testGetVanillaQuery),
        ("testGetVanillaEmptyQueryKey", testGetVanillaEmptyQueryKey),
        ("testGetVanillaQueryUnreserved", testGetVanillaQueryUnreserved),
        ("testGetVanillaQueryUTF8", testGetVanillaQueryUTF8),
        ("testPostVanilla", testPostVanilla),
        ("testPostVanillaQuery", testPostVanillaQuery),
        ("testPostVanillaQueryNonunreserved", testPostVanillaQueryNonunreserved)
    ]

    static let dateFormatter: DateFormatter  = {
        let _dateFormatter = DateFormatter()
        _dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        _dateFormatter.dateFormat = "YYYYMMdd'T'HHmmss'Z'"
        return _dateFormatter
    }()

    func testGetUnreserved() {
        let expectedCanonicalRequest = "GET\n/-._~0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz\n\nhost:example.amazonaws.com\nx-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855\nx-amz-date:20150830T123600Z\n\nhost;x-amz-content-sha256;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"

        let expectedCanonicalHeaders: [String : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=feae8f2b49f6807d4ca43941e2d6c7aacaca499df09935d14e97eed7647da5dc"
        ]

        let result = sign(
            method: .get,
            path: "/-._~0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        )
        result.expect(
            canonicalRequest: expectedCanonicalRequest,
            credentialScope: expectedCredentialScope,
            canonicalHeaders: expectedCanonicalHeaders
        )
    }

    func testGetUTF8() {
        let expectedCanonicalRequest = "GET\n/%E1%88%B4\n\nhost:example.amazonaws.com\nx-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855\nx-amz-date:20150830T123600Z\n\nhost;x-amz-content-sha256;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"

        let expectedCanonicalHeaders: [String : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=29d69532444b4f32a4c1b19af2afc116589685058ece54d8e43f0be05aeff6c0"
        ]

        let result = sign(method: .get, path: "/ሴ")
        result.expect(
            canonicalRequest: expectedCanonicalRequest,
            credentialScope: expectedCredentialScope,
            canonicalHeaders: expectedCanonicalHeaders
        )
    }

    func testGetVanilla() {
        let expectedCanonicalRequest = "GET\n/\n\nhost:example.amazonaws.com\nx-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855\nx-amz-date:20150830T123600Z\n\nhost;x-amz-content-sha256;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"

        let expectedCanonicalHeaders: [String : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=726c5c4879a6b4ccbbd3b24edbd6b8826d34f87450fbbf4e85546fc7ba9c1642"
        ]

        let result = sign(method: .get, path: "/")
        result.expect(
            canonicalRequest: expectedCanonicalRequest,
            credentialScope: expectedCredentialScope,
            canonicalHeaders: expectedCanonicalHeaders
        )
    }

    //duplicate as `testGetVanilla`, but is in Amazon Test Suite
    //will keep until I figure out why there's a duplicate test
    func testGetVanillaQuery() {
        let expectedCanonicalRequest = "GET\n/\n\nhost:example.amazonaws.com\nx-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855\nx-amz-date:20150830T123600Z\n\nhost;x-amz-content-sha256;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"

        let expectedCanonicalHeaders: [String : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=726c5c4879a6b4ccbbd3b24edbd6b8826d34f87450fbbf4e85546fc7ba9c1642"
        ]

        let result = sign(method: .get, path: "/")
        result.expect(
            canonicalRequest: expectedCanonicalRequest,
            credentialScope: expectedCredentialScope,
            canonicalHeaders: expectedCanonicalHeaders
        )
    }

    func testGetVanillaEmptyQueryKey() {
        let expectedCanonicalRequest = "GET\n/\nParam1=value1\nhost:example.amazonaws.com\nx-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855\nx-amz-date:20150830T123600Z\n\nhost;x-amz-content-sha256;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"

        let expectedCanonicalHeaders: [String : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=2287c0f96af21b7ccf3ee4a2905bcbb2d6f9a94c68d0849f3d1715ef003f2a05"
        ]

        let result = sign(method: .get, path: "/", query: "Param1=value1")
        result.expect(
            canonicalRequest: expectedCanonicalRequest,
            credentialScope: expectedCredentialScope,
            canonicalHeaders: expectedCanonicalHeaders
        )
    }

    func testGetVanillaQueryUnreserved() {
        let expectedCanonicalRequest = "GET\n/\n-._~0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz=-._~0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz\nhost:example.amazonaws.com\nx-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855\nx-amz-date:20150830T123600Z\n\nhost;x-amz-content-sha256;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"

        let expectedCanonicalHeaders: [String : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=e86fe49a4c0dda9163bed3b1b40d530d872eb612e2c366de300bfefdf356fd6a"
        ]

        let result = sign(
            method: .get,
            path: "/",
            query:"-._~0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz=-._~0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        )
        result.expect(
            canonicalRequest: expectedCanonicalRequest,
            credentialScope: expectedCredentialScope,
            canonicalHeaders: expectedCanonicalHeaders
        )
    }

    func testGetVanillaQueryUTF8() {
        let expectedCanonicalRequest = "GET\n/\n%E1%88%B4=bar\nhost:example.amazonaws.com\nx-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855\nx-amz-date:20150830T123600Z\n\nhost;x-amz-content-sha256;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"

        let expectedCanonicalHeaders: [String : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=6753d65781ac8f6964cb6fb90445ee138d65d9663df21f28f478bd09add64fd8"
        ]

        let result = sign(method: .get, path: "/", query: "ሴ=bar")
        result.expect(
            canonicalRequest: expectedCanonicalRequest,
            credentialScope: expectedCredentialScope,
            canonicalHeaders: expectedCanonicalHeaders
        )
    }

    func testPostVanilla() {
        let expectedCanonicalRequest = "POST\n/\n\nhost:example.amazonaws.com\nx-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855\nx-amz-date:20150830T123600Z\n\nhost;x-amz-content-sha256;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"

        let expectedCanonicalHeaders: [String : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=3ad5e249949a59b862eedd9f1bf1ece4693c3042bf860ef5e3351b8925316f98"
        ]

        let result = sign(method: .post, path: "/")
        result.expect(
            canonicalRequest: expectedCanonicalRequest,
            credentialScope: expectedCredentialScope,
            canonicalHeaders: expectedCanonicalHeaders
        )
    }

    func testPostVanillaQuery() {
        let expectedCanonicalRequest = "POST\n/\nParam1=value1\nhost:example.amazonaws.com\nx-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855\nx-amz-date:20150830T123600Z\n\nhost;x-amz-content-sha256;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"

        let expectedCanonicalHeaders: [String : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=d43fd95e1dfefe02247ce8858649e1a063f9dd10f25f170f7ebda6ee3e9b6fbc"
        ]

        let result = sign(method: .post, path: "/", query: "Param1=value1")
        result.expect(
            canonicalRequest: expectedCanonicalRequest,
            credentialScope: expectedCredentialScope,
            canonicalHeaders: expectedCanonicalHeaders
        )
    }

    /**
     This test isn't based on the test suite, but tracks handling of special characters.
     */
    func testPostVanillaQueryNonunreserved() {
        let expectedCanonicalRequest = "POST\n/\n%40%23%24%25%5E&%2B=%2F%2C%3F%3E%3C%60%22%3B%3A%5C%7C%5D%5B%7B%7D\nhost:example.amazonaws.com\nx-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855\nx-amz-date:20150830T123600Z\n\nhost;x-amz-content-sha256;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

        let expectedCredentialScope = "20150830/us-east-1/service/aws4_request"

        let expectedCanonicalHeaders: [String : String] = [
            "X-Amz-Date": "20150830T123600Z",
            "Authorization": "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=3db24d76713a5ccb9afe4a26acb83ae4cfa3e67d9e10f165bdf99bda199c625d"
        ]

        let result = sign(method: .post, path: "/", query: "@#$%^&+=/,?><`\";:\\|][{}")
        result.expect(
            canonicalRequest: expectedCanonicalRequest,
            credentialScope: expectedCredentialScope,
            canonicalHeaders: expectedCanonicalHeaders
        )

    }
}

extension AWSSignerTestSuite {
    var testDate: Date {
        return AWSSignerTestSuite.dateFormatter.date(from: "20150830T123600Z")!
    }


    /**
     Preparation of data to sign a canonical request.

     Intended to handle the preparation in the AWSSignatureV4's `sign` function

     - returns:
     Hash value and multiple versions of headers

     - parameters:
     - auth: Signature struct to use for calculations
     - host: Hostname to sign for
     */
    func prepCanonicalRequest(auth: AWSSignatureV4, host: String) -> (String, String, String) {
        let payloadHash = try! Payload.none.hashed()
        var headers = [String:String]()
        auth.generateHeadersToSign(headers: &headers, host: host, hash: payloadHash)

        let sortedHeaders = auth.alphabetize(headers)
        let signedHeaders = sortedHeaders.map { $0.key.lowercased() }.joined(separator: ";")
        let canonicalHeaders = auth.createCanonicalHeaders(sortedHeaders)
        return (payloadHash, signedHeaders, canonicalHeaders)
    }

    func sign(
        method: AWSSignatureV4.Method,
        path: String,
        query: String = ""
    ) -> SignerResult {
        let host = "example.amazonaws.com"
        var auth = AWSSignatureV4(
            service: "service",
            host: host,
            region: Region.usEast1.rawValue,
            accessKey: "AKIDEXAMPLE",
            secretKey: "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"
        )

        auth.unitTestDate = testDate
        let (payloadHash, signedHeaders, preppedCanonicalHeaders) = prepCanonicalRequest(auth: auth, host: host)
        let canonicalRequest = try! auth.getCanonicalRequest(payloadHash: payloadHash, method: method, path: path, query: query, canonicalHeaders: preppedCanonicalHeaders, signedHeaders: signedHeaders)


        let credentialScope = auth.getCredentialScope()

        //FIXME(Brett): handle throwing
        let canonicalHeaders = try! auth.sign(
            payload: .none,
            method: method,
            path: path,
            query: query
        )

        return SignerResult(
            canonicalRequest: canonicalRequest,
            credentialScope: credentialScope,
            canonicalHeaders: canonicalHeaders
        )
    }
}

struct SignerResult {
    let canonicalRequest: String
    let credentialScope: String
    let canonicalHeaders: [String: String]
}

extension SignerResult {
    func expect(
        canonicalRequest: String,
        credentialScope: String,
        canonicalHeaders: [String: String],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(self.canonicalRequest, canonicalRequest, file: file, line: line)
        XCTAssertEqual(self.credentialScope, credentialScope, file: file, line: line)

        canonicalHeaders.forEach {
            if $0.key == "Authorization" {
                for (givenLine, expectedLine) in zip(self.canonicalHeaders[$0.key]!.components(separatedBy: " "), $0.value.components(separatedBy: " ")) {
                    XCTAssertEqual(givenLine, expectedLine)
                }
            } else {
                XCTAssertEqual(self.canonicalHeaders[$0.key], $0.value, file: file, line: line)
            }
        }
    }
}
