# GateSigil

**Decentralized NFT-Based Access Control System with QR Code Integration**

GateSigil is a sophisticated smart contract platform built on the Stacks blockchain that revolutionizes digital access management through NFT-powered authentication. Transform any digital space into a token-gated environment with granular control, seamless user experience, enterprise-grade security, and now featuring **QR Code Integration** for offline access verification and event check-ins.

## 🌟 Features

### Core Functionality
- **NFT-Based Access Control**: Secure, blockchain-verified access using SIP-009 compliant NFTs
- **Realm Management**: Create and manage distinct access domains with custom permissions
- **Time-Based Expiration**: Set automatic expiration dates for temporary access rights
- **Batch Operations**: Efficiently mint multiple access tokens in a single transaction
- **Transfer & Delegation**: Seamless ownership transfer with maintained access rights
- **Granular Permissions**: Fine-tuned control over who can create, mint, and revoke access

### 🆕 QR Code Integration
- **QR Code Generation**: Generate unique QR codes for each access token for offline verification
- **Time-Limited Validity**: QR codes expire automatically (configurable, default 24 hours)
- **One-Time Use**: Each QR code can only be used once to prevent replay attacks
- **Event Check-ins**: Perfect for offline events, conferences, and physical venue access
- **Cross-Platform Compatibility**: Works with any QR code scanner or custom applications
- **Usage Analytics**: Track QR code generation and usage statistics per token

### Security Features
- **Input Validation**: Comprehensive validation of all user inputs and parameters
- **Authorization Checks**: Multi-layer permission system with role-based access control
- **Revocation System**: Instant access revocation without requiring token burns
- **Safe Operations**: Atomic transactions with proper error handling and rollback mechanisms
- **QR Code Security**: Cryptographically secure QR codes with expiration and usage tracking

### Developer Experience
- **SIP-009 Compliant**: Full compatibility with Stacks NFT ecosystem
- **Clean API**: Intuitive function interfaces for easy integration
- **Extensive Documentation**: Complete function reference with usage examples
- **Gas Optimized**: Efficient contract design minimizing transaction costs

## 🚀 Quick Start

### Prerequisites
- [Stacks CLI](https://docs.stacks.co/docs/build/cli) installed
- [Clarinet](https://github.com/hirosystems/clarinet) for testing and deployment
- STX tokens for contract deployment and transactions

### Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/your-org/gate-sigil.git
   cd gate-sigil
   ```

2. **Initialize Clarinet Project**
   ```bash
   clarinet new gate-sigil-project
   cd gate-sigil-project
   ```

3. **Add Contract**
   Copy the GateSigil contract to `contracts/gate-sigil.clar`

4. **Deploy Contract**
   ```bash
   clarinet deploy --testnet
   ```

### Basic Usage

#### Creating a Realm
```clarity
(contract-call? .gate-sigil create-realm "premium-content" "Access to premium content area")
```

#### Minting Access NFT
```clarity
(contract-call? .gate-sigil mint-access-nft 
    'SP1HTBVD3JG9C05J7HDJKDYR94D9730GSN5PS.user
    "premium-content"
    (some u1000000)  ;; Expires at block 1,000,000
    "https://example.com/metadata.json")
```

#### Generating QR Code
```clarity
(contract-call? .gate-sigil generate-qr-code 
    u1  ;; token-id
    0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef)  ;; 32-byte hash
```

#### Verifying QR Code Access
```clarity
(contract-call? .gate-sigil verify-and-use-qr-code 
    0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef  ;; QR hash
    "premium-content")  ;; realm
```

#### Checking Access
```clarity
(contract-call? .gate-sigil check-access 
    'SP1HTBVD3JG9C05J7HDJKDYR94D9730GSN5PS.user
    "premium-content")
```

## 📖 API Reference

### Public Functions

#### `create-realm`
Creates a new access realm with custom parameters.

**Parameters:**
- `realm` (string-ascii 64): Unique realm identifier
- `description` (string-utf8 256): Human-readable description

**Returns:** `(response bool uint)`

**Example:**
```clarity
(create-realm "vip-lounge" "Exclusive VIP member area")
```

#### `mint-access-nft`
Mints a new access NFT for a specific realm.

**Parameters:**
- `to` (principal): Recipient address
- `realm` (string-ascii 64): Target realm
- `expiration` (optional uint): Optional expiration block
- `metadata-uri` (string-utf8 256): NFT metadata URI

**Returns:** `(response uint uint)`

#### `generate-qr-code`
Generates a time-limited QR code for offline access verification.

**Parameters:**
- `token-id` (uint): NFT identifier
- `qr-hash` (buff 32): 32-byte hash representing the QR code

**Returns:** `(response uint uint)` - Returns QR code expiration block

**Example:**
```clarity
(generate-qr-code u1 0x1234...abcd)  ;; Returns expiration block
```

#### `verify-and-use-qr-code`
Verifies and marks a QR code as used for access control.

**Parameters:**
- `qr-hash` (buff 32): QR code hash to verify
- `realm` (string-ascii 64): Realm to verify access for

**Returns:** `(response uint uint)` - Returns token-id if valid

#### `transfer`
Transfers an access NFT between users.

**Parameters:**
- `token-id` (uint): NFT identifier
- `sender` (principal): Current owner
- `recipient` (principal): New owner

**Returns:** `(response bool uint)`

#### `revoke-token`
Revokes access for a specific NFT (admin only).

**Parameters:**
- `token-id` (uint): NFT to revoke

**Returns:** `(response bool uint)`

#### `batch-mint`
Mints multiple NFTs in a single transaction.

**Parameters:**
- `recipients` (list 50 principal): List of recipient addresses
- `realm` (string-ascii 64): Target realm
- `expiration` (optional uint): Optional expiration block
- `base-uri` (string-utf8 256): Base metadata URI

**Returns:** `(response (list 50 uint) uint)`

#### `set-qr-validity-period`
Sets the QR code validity period (admin only).

**Parameters:**
- `blocks` (uint): Number of blocks QR codes remain valid (max 4320 = ~30 days)

**Returns:** `(response bool uint)`

### Read-Only Functions

#### `check-access`
Verifies if a user has valid access to a realm.

**Parameters:**
- `user` (principal): User to check
- `realm` (string-ascii 64): Realm to verify access for

**Returns:** `(response bool uint)`

#### `validate-qr-code`
Checks if a QR code is valid without marking it as used.

**Parameters:**
- `qr-hash` (buff 32): QR code hash to validate

**Returns:** `(response bool uint)`

#### `get-qr-code-info`
Retrieves detailed information about a QR code.

**Parameters:**
- `qr-hash` (buff 32): QR code hash

**Returns:** `(optional { token-id: uint, created-at: uint, expires-at: uint, used: bool, realm: (string-ascii 64), creator: principal })`

#### `get-token-qr-stats`
Gets QR code usage statistics for a token.

**Parameters:**
- `token-id` (uint): Token identifier

**Returns:** `(optional { total-generated: uint, last-generated: uint })`

#### `get-qr-validity-period`
Returns the current QR code validity period in blocks.

**Returns:** `(response uint uint)`

#### `get-token-info`
Retrieves complete information about a token.

**Parameters:**
- `token-id` (uint): Token identifier

**Returns:** `(optional { owner: principal, expiration: (optional uint), realm: (string-ascii 64), metadata-uri: (string-utf8 256), active: bool })`

#### `get-realm-info`
Gets detailed information about a realm.

**Parameters:**
- `realm` (string-ascii 64): Realm identifier

**Returns:** `(optional { creator: principal, description: (string-utf8 256), access-required: uint, created-at: uint })`

## 🏗️ Architecture

### Contract Structure

```
GateSigil Contract
├── Data Variables
│   ├── last-token-id (uint)
│   ├── contract-uri (string-utf8 256)
│   └── qr-code-validity-period (uint)
├── Data Maps
│   ├── tokens (token metadata)
│   ├── realms (realm configuration)
│   ├── user-access (access mappings)
│   ├── qr-codes (QR code data)
│   └── token-qr-usage (QR statistics)
└── Functions
    ├── Public (user interactions)
    ├── Read-Only (queries)
    └── Private (internal logic)
```

### QR Code Flow

1. **QR Generation**: Token holders generate time-limited QR codes for their access NFTs
2. **Offline Verification**: QR codes can be scanned and verified without internet connection
3. **Online Validation**: Final verification happens on-chain when QR code is used
4. **Single Use**: Each QR code can only be used once to prevent replay attacks
5. **Expiration**: QR codes automatically expire after configurable time period

### Access Control Flow

1. **Realm Creation**: Authorized users create access domains
2. **NFT Minting**: Realm creators mint access tokens for users
3. **QR Generation**: Token holders generate QR codes for offline access
4. **Access Verification**: Applications query user access status or verify QR codes
5. **Token Management**: Transfer, revoke, or expire access as needed

### Security Model

- **Multi-layer Validation**: Input sanitization, business logic checks, and blockchain verification
- **Role-based Permissions**: Distinct roles for contract owners, realm creators, and token holders
- **QR Code Security**: Cryptographically secure hashes with time expiration and single-use enforcement
- **Fail-safe Design**: All operations fail securely with clear error messages
- **Gas Optimization**: Efficient storage patterns and minimal computational overhead

## 🛠️ Integration Guide

### Web3 Frontend Integration

```javascript
import { StacksApiSocketClient } from '@stacks/blockchain-api-client';
import { ContractCallRegularOptions, makeContractCall } from '@stacks/transactions';
import { bufferCV, stringAsciiCV, uintCV } from '@stacks/transactions';

// Generate QR Code
async function generateQRCode(tokenId, qrHash) {
  const contractAddress = 'SP...'; // Your deployed contract
  const contractName = 'gate-sigil';
  
  const options = {
    contractAddress,
    contractName,
    functionName: 'generate-qr-code',
    functionArgs: [
      uintCV(tokenId),
      bufferCV(qrHash)
    ],
    senderKey: privateKey,
    network,
  };
  
  const transaction = await makeContractCall(options);
  return broadcastTransaction(transaction, network);
}

// Verify QR Code
async function verifyQRCode(qrHash, realm) {
  const options = {
    contractAddress,
    contractName,
    functionName: 'verify-and-use-qr-code',
    functionArgs: [
      bufferCV(qrHash),
      stringAsciiCV(realm)
    ],
    senderKey: privateKey,
    network,
  };
  
  const transaction = await makeContractCall(options);
  return broadcastTransaction(transaction, network);
}

// Check user access
async function checkUserAccess(userAddress, realm) {
  const options = {
    contractAddress,
    contractName,
    functionName: 'check-access',
    functionArgs: [
      standardPrincipalCV(userAddress),
      stringAsciiCV(realm)
    ],
    senderKey: privateKey,
    network,
  };
  
  const transaction = await makeContractCall(options);
  return broadcastTransaction(transaction, network);
}
```

### QR Code Mobile Integration

```javascript
// Generate QR Code Data
function generateQRCodeData(tokenId, realm, timestamp) {
  const data = {
    tokenId,
    realm,
    timestamp,
    contract: 'SP...gate-sigil'
  };
  
  // Create hash for blockchain verification
  const hash = crypto.createHash('sha256')
    .update(JSON.stringify(data))
    .digest();
  
  return {
    qrData: JSON.stringify(data),
    hash: hash
  };
}

// QR Code Scanner Integration
import { BarCodeScanner } from 'expo-barcode-scanner';

function QRScanner({ onScan }) {
  const handleBarCodeScanned = ({ data }) => {
    try {
      const qrData = JSON.parse(data);
      // Verify QR code on blockchain
      verifyQRCode(qrData.hash, qrData.realm)
        .then(result => onScan(result));
    } catch (error) {
      console.error('Invalid QR code:', error);
    }
  };

  return (
    <BarCodeScanner
      onBarCodeScanned={handleBarCodeScanned}
      style={{ flex: 1 }}
    />
  );
}
```

### Backend API Integration

```python
import requests
import hashlib
import json
from stacks_api import StacksApiClient

class GateSigilClient:
    def __init__(self, contract_address, api_url="https://stacks-node-api.mainnet.stacks.co"):
        self.contract = contract_address
        self.client = StacksApiClient(api_url)
    
    def verify_access(self, user_address, realm):
        """Verify if user has access to specified realm"""
        result = self.client.call_read_only_function(
            contract_address=self.contract,
            contract_name="gate-sigil",
            function_name="check-access",
            function_args=[user_address, realm]
        )
        return result.get('okay', False)
    
    def generate_qr_code(self, token_id, realm, user_address):
        """Generate QR code hash for token"""
        data = {
            'token_id': token_id,
            'realm': realm,
            'user': user_address,
            'timestamp': int(time.time())
        }
        
        qr_hash = hashlib.sha256(
            json.dumps(data, sort_keys=True).encode()
        ).hexdigest()
        
        return {
            'qr_data': json.dumps(data),
            'hash': qr_hash
        }
    
    def verify_qr_code(self, qr_hash, realm):
        """Verify QR code on blockchain"""
        result = self.client.call_function(
            contract_address=self.contract,
            contract_name="gate-sigil",
            function_name="verify-and-use-qr-code",
            function_args=[qr_hash, realm]
        )
        return result.get('okay', False)
```

## 🧪 Testing

### Unit Tests

```bash
# Run all tests
clarinet test

# Run specific test file
clarinet test tests/gate-sigil-test.ts

# Run with coverage
clarinet test --coverage
```

### Integration Tests

```typescript
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Can create realm, mint NFT, and generate QR code",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const user = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            // Create realm
            Tx.contractCall('gate-sigil', 'create-realm', [
                types.ascii("test-realm"),
                types.utf8("Test realm description")
            ], deployer.address),
            
            // Mint access NFT
            Tx.contractCall('gate-sigil', 'mint-access-nft', [
                types.principal(user.address),
                types.ascii("test-realm"),
                types.none(),
                types.utf8("https://example.com/metadata.json")
            ], deployer.address)
        ]);
        
        assertEquals(block.receipts.length, 2);
        assertEquals(block.receipts[0].result.expectOk(), true);
        assertEquals(block.receipts[1].result.expectOk(), types.uint(1));
        
        // Generate QR code
        let qrHash = new Uint8Array(32);
        crypto.getRandomValues(qrHash);
        
        let qrBlock = chain.mineBlock([
            Tx.contractCall('gate-sigil', 'generate-qr-code', [
                types.uint(1),
                types.buff(qrHash)
            ], user.address)
        ]);
        
        qrBlock.receipts[0].result.expectOk();
        
        // Verify QR code
        let verifyBlock = chain.mineBlock([
            Tx.contractCall('gate-sigil', 'verify-and-use-qr-code', [
                types.buff(qrHash),
                types.ascii("test-realm")
            ], deployer.address)
        ]);
        
        assertEquals(verifyBlock.receipts[0].result.expectOk(), types.uint(1));
    }
});

Clarinet.test({
    name: "QR code expires after validity period",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const user = accounts.get('wallet_1')!;
        
        // Setup realm and NFT (previous test setup)
        let setupBlock = chain.mineBlock([
            Tx.contractCall('gate-sigil', 'create-realm', [
                types.ascii("test-realm"),
                types.utf8("Test realm description")
            ], deployer.address),
            Tx.contractCall('gate-sigil', 'mint-access-nft', [
                types.principal(user.address),
                types.ascii("test-realm"),
                types.none(),
                types.utf8("https://example.com/metadata.json")
            ], deployer.address)
        ]);
        
        // Set short validity period
        chain.mineBlock([
            Tx.contractCall('gate-sigil', 'set-qr-validity-period', [
                types.uint(1)  // 1 block validity
            ], deployer.address)
        ]);
        
        // Generate QR code
        let qrHash = new Uint8Array(32);
        crypto.getRandomValues(qrHash);
        
        chain.mineBlock([
            Tx.contractCall('gate-sigil', 'generate-qr-code', [
                types.uint(1),
                types.buff(qrHash)
            ], user.address)
        ]);
        
        // Mine enough blocks to expire QR code
        chain.mineEmptyBlock(2);
        
        // Try to verify expired QR code
        let verifyBlock = chain.mineBlock([
            Tx.contractCall('gate-sigil', 'verify-and-use-qr-code', [
                types.buff(qrHash),
                types.ascii("test-realm")
            ], deployer.address)
        ]);
        
        verifyBlock.receipts[0].result.expectErr(types.uint(110)); // ERR_QR_CODE_EXPIRED
    }
});
```

## 📊 Gas Costs

| Function | Estimated Gas | Notes |
|----------|---------------|-------|
| create-realm | ~2,000 | One-time setup cost |
| mint-access-nft | ~5,500 | Per token minting (includes QR stats init) |
| generate-qr-code | ~3,000 | Per QR code generation |
| verify-and-use-qr-code | ~2,500 | QR code verification and usage |
| transfer | ~3,200 | Standard NFT transfer |
| check-access | ~500 | Read-only operation |
| validate-qr-code | ~400 | Read-only QR validation |
| batch-mint (50) | ~200,000 | Bulk minting optimization |

## 🔐 Security Considerations

### Best Practices
- Always validate expiration times before minting
- Use cryptographically secure random values for QR code hashes
- Implement rate limiting for QR code generation to prevent spam
- Monitor QR code usage patterns for suspicious activity
- Use multi-signature wallets for high-value realms

### QR Code Security
- QR codes are time-limited with configurable expiration (default 24 hours)
- Each QR code can only be used once (single-use enforcement)
- QR codes are tied to specific realms to prevent cross-realm attacks
- Cryptographic hashing ensures QR code integrity

### Known Limitations
- Maximum realm name length: 64 characters
- Maximum metadata URI length: 256 characters
- Batch mint limit: 50 tokens per transaction
- QR code validity period: Maximum 4,320 blocks (~30 days)
- QR code hash must be exactly 32 bytes
- No built-in refund mechanism for revoked tokens

### Security Auditing
- Input validation on all user-supplied data
- Safe arithmetic operations with overflow protection
- Proper access control enforcement
- Comprehensive error handling
- QR code replay attack prevention

## 🗺️ Roadmap

### Phase 1: QR Code Integration ✅ (Q3 2025)
* **QR Code Generation**: Generate time-limited QR codes for offline access verification
* **Event Check-ins**: Perfect for conferences, events, and physical venue access
* **Single-Use Security**: Each QR code can only be used once to prevent replay attacks
* **Configurable Expiration**: Admins can set QR code validity periods (1 block to 30 days)

### Phase 2: Enhanced QR Features (Q4 2025)
* **Batch QR Generation**: Generate multiple QR codes for events with hundreds of attendees
* **QR Code Analytics**: Detailed usage statistics, location tracking, and access patterns
* **Custom QR Designs**: Branded QR codes with custom logos and styling options

### Phase 3: Integration Ecosystem (Q1 2026)
* **Discord/Telegram Bots**: Automated bot integration for seamless token-gated server access
* **Mobile SDK**: Native mobile SDKs with built-in QR scanning and offline verification
* **Event Management**: Complete event platform with ticketing, check-ins, and analytics

### Phase 4: Advanced Features (Q2 2026)
* **Cross-Chain Bridge**: Enable access verification across multiple blockchains
* **Multi-Signature Gates**: Require multiple NFT ownerships for high-security access
* **Subscription Model**: Recurring payment system with automatic NFT renewal

### Future Enhancements
- Zero-knowledge proof integration for privacy-preserving QR codes
- Biometric authentication combined with QR code verification
- Machine learning-powered fraud detection for unusual access patterns
- Integration with major identity providers and SSO systems

## 🤝 Contributing

We welcome contributions from the community! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting pull requests.

### Development Setup
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and add tests
4. Ensure all tests pass: `clarinet test`
5. Submit a pull request

### Code Style
- Follow Clarity best practices and naming conventions
- Include comprehensive inline documentation
- Add unit tests for all new functionality
- Update README for any API changes

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built on the [Stacks blockchain](https://stacks.co) for Bitcoin-secured smart contracts
- Inspired by the need for decentralized access control in Web3
- QR code integration enables seamless offline-to-online access verification
- Thanks to the Stacks community for ongoing support and feedback

**Built with ❤️ for the decentralized web**
