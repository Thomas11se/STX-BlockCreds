

# STACKS-BlockCreds- Credential Verification Smart Contract

## Overview

This smart contract manages the issuance, verification, and revocation of educational credentials on the Stacks blockchain. It enables authorized educational institutions to register, verify their identity, define credential categories, and issue verifiable credentials to students. Students and third parties can verify credential validity and status, including revocation and expiration.

---

## Features

* **Educational Institution Management**
  Institutions can register themselves and get verified by the contract owner.

* **Credential Category Management**
  Contract owner can define supported credential categories along with validity periods.

* **Credential Issuance**
  Verified institutions can issue credentials to students with metadata and cryptographic proof (document hash).

* **Credential Revocation**
  Institutions can revoke issued credentials to prevent misuse.

* **Credential Status Verification**
  Anyone can query the credential status (valid, revoked, expired).

* **Ownership Transfer**
  The contract owner can transfer ownership to another principal.

---

## Error Codes

| Error Code                               | Description                         |
| ---------------------------------------- | ----------------------------------- |
| `ERR-NOT-AUTHORIZED (u100)`              | Caller not authorized               |
| `ERR-DUPLICATE-INSTITUTION (u101)`       | Institution already registered      |
| `ERR-RECORD-NOT-FOUND (u102)`            | Record not found                    |
| `ERR-UNSUPPORTED-CREDENTIAL-TYPE (u103)` | Credential category unsupported     |
| `ERR-CREDENTIAL-STATUS-REVOKED (u104)`   | Credential has been revoked         |
| `ERR-CREDENTIAL-STATUS-EXPIRED (u105)`   | Credential has expired              |
| `ERR-INVALID-INPUT (u106)`               | Invalid input provided              |
| `ERR-ZERO-ADDRESS (u107)`                | Invalid or zero principal address   |
| `ERR-INVALID-PERIOD (u108)`              | Invalid validity period             |
| `ERR-DUPLICATE-CREDENTIAL (u109)`        | Credential with UUID already exists |
| `ERR-INVALID-HASH (u110)`                | Invalid or empty credential hash    |

---

## Data Structures

* **Authorized Educational Institutions**
  Maps institution principal to institution profile:

  * `education-provider-name` (string)
  * `education-provider-url` (string)
  * `education-provider-verification-status` (bool)

* **Credential Records**
  Maps `{credential-uuid, student-address}` to credential details:

  * `education-provider-address`
  * `issuance-block-height`
  * `expiration-block-height`
  * `credential-type-identifier`
  * `credential-document-hash` (buffer 32 bytes)
  * `additional-credential-info`
  * `revocation-status` (bool)

* **Supported Credential Categories**
  Maps category ID string to:

  * `credential-category-description`
  * `credential-validity-period` (uint, in blocks)

---

## Contract Owner

* The deployer of the contract is set as the owner by default.
* Only the owner can:

  * Transfer ownership.
  * Verify educational institutions.
  * Register credential categories.

---

## Public Functions

### `transfer-ownership(new-owner-address)`

* Transfers contract ownership to `new-owner-address`.
* Only callable by current owner.

### `register-education-provider(education-provider-name, education-provider-url)`

* Registers a new educational institution.
* Verification status is initially false.
* Fails if institution is already registered.

### `verify-education-provider(provider-address)`

* Marks an institution as verified.
* Only callable by contract owner.

### `register-credential-category(category-id, category-description, validity-period-blocks)`

* Adds a new credential category with a validity period.
* Only callable by contract owner.

### `issue-credential(credential-uuid, student-address, credential-type-identifier, credential-document-hash, additional-credential-info)`

* Issues a credential to a student.
* Only callable by a verified institution.
* Validates all inputs and ensures no duplicate credentials.

### `revoke-credential(credential-uuid, student-address)`

* Revokes an issued credential.
* Only callable by the institution that issued the credential.

---

## Read-only Functions

### `get-credential-record(credential-uuid, student-address)`

* Returns credential record details if available.

### `verify-credential-status(credential-uuid, student-address)`

* Checks if the credential is valid, revoked, or expired.
* Returns error codes if revoked or expired.

### `get-education-provider-profile(provider-address)`

* Retrieves the profile of a registered educational institution.

### `get-credential-category-details(category-id)`

* Returns details about a registered credential category.

---

## Validation Functions

* Principal addresses are validated to avoid zero or contract addresses.
* Strings are validated to ensure they are not empty.
* Buffers are validated for correct length and non-empty content.
* Validity periods must be greater than zero.

---

## Deployment and Usage

1. Deploy the contract to the Stacks blockchain.
2. Register educational institutions using `register-education-provider`.
3. Contract owner verifies institutions using `verify-education-provider`.
4. Owner registers credential categories with validity periods.
5. Verified institutions issue credentials with document hashes.
6. Credentials can be revoked by issuing institutions.
7. Credential status can be checked anytime by anyone.

---

## Security Considerations

* Only the contract owner can verify institutions and register credential categories.
* Credential issuance and revocation are restricted to verified institutions.
* Hash validation ensures document authenticity.

---

## License

Specify your preferred license here.

---
