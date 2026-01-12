# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased] - 2026-01-12

### Fixed
- **KSEF Token Authentication** - Fixed three critical bugs:
  - Fixed `usage` field handling - API returns array but code expected string
  - Fixed certificate type - now correctly searches for `KsefTokenEncryption` instead of `SymmetricKeyEncryption`
  - Fixed RSA-OAEP encryption to use SHA-256 instead of SHA-1 (default), as required by KSeF API
  - Fixed request body format - added missing `challenge` field and corrected `contextIdentifier` structure
  - Fixed timestamp handling - now uses `timestampMs` with fallback to `timestamp`
- **Encryption Key Handling** - Fixed RSA-OAEP encryption in `ClientBuilder`:
  - Fixed `usage` field handling for array support
  - Updated to use SHA-256 for RSA-OAEP encryption

## [1.1.0] - 2025-10-17

### Added - 100% API Coverage 🎉
- **Permissions Module** (17 endpoints) - Complete permissions management system
  - Grant permissions to persons, entities, authorizations, indirect, subunits, EU entities
  - Revoke grants (common, authorizations)
  - Query grants (personal, persons, subunits, entities roles, subordinate entities, authorizations, EU entities)
  - Operation status and attachments status
- **Limits Module** (2 endpoints) - System limits information
  - Context limits (sessions, invoices)
  - Subject limits (certificates, tokens)
- **PEPPOL Module** (1 endpoint) - PEPPOL network integration
  - Query PEPPOL data
- **Extended Testdata Module** (6 new endpoints)
  - Permissions grant/revoke
  - Attachment grant/revoke
  - Limits configuration (context session, subject certificate)

### Changed
- Updated `HttpClient#post` and `HttpClient#put` to support params in POST/PUT requests
- Enhanced documentation with English translations
- Improved README with comprehensive API overview and usage examples

### Documentation
- Added `PERMISSIONS.md` - Complete permissions API guide
- Added `LIMITS.md` - System limits documentation
- Added `PEPPOL.md` - PEPPOL integration guide
- Added `COMPLETE_API_COVERAGE.md` - Full endpoint coverage list
- Updated README with 100% coverage information

### Technical
- 26 new request handlers implemented
- 3 new resource classes (Permissions, Limits, Peppol)
- Extended Testdata resource with 6 new methods
- 11 comprehensive test files added (100% passing)
- Total test count: 482 examples

**Total API Coverage: 68/68 endpoints (100%)** ✨

## [1.0.0] - 2025-10-17

### 🎉 Initial Release - FULLY FUNCTIONAL

#### Added
- ✅ Complete XAdES-BES digital signature implementation
- ✅ RSA-SHA256 and ECDSA-SHA256 support
- ✅ Exclusive canonicalization (C14N)
- ✅ Full authentication flow with KSeF API v2
- ✅ Certificate generation tool (`bin/generate_test_cert.rb`)
- ✅ Self-signed certificate support for test environment
- ✅ HTTP client with Faraday
- ✅ Automatic token management (access + refresh)
- ✅ Session management
- ✅ Builder pattern for client configuration
- ✅ Value objects (NIP, PESEL, tokens, etc.)
- ✅ Error handling
- ✅ Logger integration
- ✅ API resources:
  - Auth (challenge, status, redeem, refresh, revoke, sessions)
  - Invoices (send, status, get, query)
  - Taxpayer
  - Sessions
  - Common
- ✅ Comprehensive documentation (EN + CZ)
- ✅ Quick start guide
- ✅ Examples

#### Fixed
- 🐛 HTTP headers - Added explicit Accept and Content-Type headers
- 🐛 Response parsing - Fixed nested response structure (`status["status"]["code"]`)
- 🐛 AuthenticationToken extraction - Fixed token extraction from nested object
- 🐛 XAdES transforms - Added exclusive canonicalization transforms
- 🐛 ECDSA signatures - Added DER to Raw conversion

#### Technical Details
- **XAdES Signing**: Complete XAdES-BES with proper transforms and canonicalization
- **Authentication**: Works with self-signed certificates + random NIP in test environment
- **HTTP Client**: Faraday-based with proper header management
- **Certificate Generation**: Supports RSA 2048-bit and EC P-256 keys

#### Documentation
- README.md - Complete documentation
- QUICK_START.md - Quick start guide (5 minutes)
- ARCHITECTURE.md - System architecture
- INVOICE_SCHEMA.md - FA(2) XML schema guide
- STATUS.md - Technical status (100% functional)
- FILES_OVERVIEW.md - File structure overview
- CHANGELOG.md - Version history

All documentation moved to `docs/` directory

#### Examples
- `examples/simple_authentication.rb` - Simple authentication example

#### Tools
- `bin/generate_test_cert.rb` - Certificate generation CLI tool

### Dependencies
- Ruby >= 3.0
- Nokogiri >= 1.15
- Faraday >= 2.0
- OpenSSL >= 3.0

### Tested With
- Ruby 3.x
- KSeF Test Environment (https://ksef-test.mf.gov.pl/api/v2)
- Self-signed certificates
- Random NIP numbers

### Notes
- ✅ Fully functional in test environment
- ✅ Ready for production with qualified certificates
- ✅ Supports self-signed certificates in test environment
- ✅ Works with any NIP in test environment (with verifyCertificateChain=false)

---

## Development Notes

### Key Discoveries
1. **HTTP Headers are Critical**: Accept and Content-Type must be explicitly set
2. **Response Structure is Nested**: status["status"]["code"] not status["statusCode"]
3. **Exclusive Canonicalization**: Required for both document and SignedProperties references
4. **Self-signed Certs Work**: With verifyCertificateChain=false in test environment

### Comparison with C# Client
- ✅ Same authentication flow
- ✅ Same XAdES structure
- ✅ Same API endpoints
- ✅ Works with random NIPs (like C# client)

---

**Status**: 🟢 Production Ready
**License**: MIT
**Made with ❤️ in Czech Republic**
