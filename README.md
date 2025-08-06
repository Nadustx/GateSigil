# GateSigil 🚪✨

**Decentralized NFT-Based Access Control System**

GateSigil is a sophisticated smart contract platform built on the Stacks blockchain that revolutionizes digital access management through NFT-powered authentication. Transform any digital space into a token-gated environment with granular control, seamless user experience, and enterprise-grade security.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Stacks](https://img.shields.io/badge/Stacks-Blockchain-purple.svg)](https://stacks.co)
[![Clarity](https://img.shields.io/badge/Language-Clarity-blue.svg)](https://clarity-lang.org)

## 🌟 Features

### Core Functionality
- **NFT-Based Access Control**: Secure, blockchain-verified access using SIP-009 compliant NFTs
- **Realm Management**: Create and manage distinct access domains with custom permissions
- **Time-Based Expiration**: Set automatic expiration dates for temporary access rights
- **Batch Operations**: Efficiently mint multiple access tokens in a single transaction
- **Transfer & Delegation**: Seamless ownership transfer with maintained access rights
- **Granular Permissions**: Fine-tuned control over who can create, mint, and revoke access

### Security Features
- **Input Validation**: Comprehensive validation of all user inputs and parameters
- **Authorization Checks**: Multi-layer permission system with role-based access control
- **Revocation System**: Instant access revocation without requiring token burns
- **Safe Operations**: Atomic transactions with proper error handling and rollback mechanisms

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

### Read-Only Functions

#### `check-access`
Verifies if a user has valid access to a realm.

**Parameters:**
- `user` (principal): User to check
- `realm` (string-ascii 64): Realm to verify access for

**Returns:** `(response bool uint)`

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
│   └── contract-uri (string-utf8 256)
├── Data Maps
│   ├── tokens (token metadata)
│   ├── realms (realm configuration)
│   └── user-access (access mappings)
└── Functions
    ├── Public (user interactions)
    ├── Read-Only (queries)
    └── Private (internal logic)
```

### Access Control Flow

1. **Realm Creation**: Authorized users create access domains
2. **NFT Minting**: Realm creators mint access tokens for users
3. **Access Verification**: Applications query user access status
4. **Token Management**: Transfer, revoke, or expire access as needed

### Security Model

- **Multi-layer Validation**: Input sanitization, business logic checks, and blockchain verification
- **Role-based Permissions**: Distinct roles for contract owners, realm creators, and token holders
- **Fail-safe Design**: All operations fail securely with clear error messages
- **Gas Optimization**: Efficient storage patterns and minimal computational overhead

## 🛠️ Integration Guide

### Web3 Frontend Integration

```javascript
import { StacksApiSocketClient } from '@stacks/blockchain-api-client';
import { ContractCallRegularOptions, makeContractCall } from '@stacks/transactions';

// Check user access
async function checkUserAccess(userAddress, realm) {
  const contractAddress = 'SP...'; // Your deployed contract
  const contractName = 'gate-sigil';
  
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

### Backend API Integration

```python
import requests
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
    name: "Can create realm and mint access NFT",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const user = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
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
        
        assertEquals(block.receipts.length, 2);
        assertEquals(block.receipts[0].result.expectOk(), true);
        assertEquals(block.receipts[1].result.expectOk(), types.uint(1));
    }
});
```

## 📊 Gas Costs

| Function | Estimated Gas | Notes |
|----------|---------------|-------|
| create-realm | ~2,000 | One-time setup cost |
| mint-access-nft | ~5,000 | Per token minting |
| transfer | ~3,000 | Standard NFT transfer |
| check-access | ~500 | Read-only operation |
| batch-mint (50) | ~150,000 | Bulk minting optimization |

## 🔐 Security Considerations

### Best Practices
- Always validate expiration times before minting
- Use multi-signature wallets for high-value realms
- Implement rate limiting for public minting functions
- Monitor for unusual access patterns

### Known Limitations
- Maximum realm name length: 64 characters
- Maximum metadata URI length: 256 characters
- Batch mint limit: 50 tokens per transaction
- No built-in refund mechanism for revoked tokens

### Security Auditing
- Input validation on all user-supplied data
- Safe arithmetic operations with overflow protection
- Proper access control enforcement
- Comprehensive error handling

## 🗺️ Roadmap

### Phase 1: Core Infrastructure (Q3 2025)
* **QR Code Integration**: Generate and validate QR codes for offline access verification and event check-ins
* **Discord/Telegram Bots**: Automated bot integration for seamless token-gated server access and role management
* **Analytics Dashboard**: Real-time usage analytics, access patterns, and holder insights for gate owners

### Phase 2: Advanced Features (Q4 2025)
* **Subscription Model**: Recurring payment system with automatic NFT renewal and subscription tiers
* **Delegation System**: Allow NFT holders to temporarily delegate access rights to other users without transferring ownership
* **Dynamic Access Levels**: Smart contracts that automatically adjust access levels based on user behavior, loyalty, or staking

### Phase 3: Enterprise & Integration (Q1 2026)
* **Cross-Chain Bridge**: Enable access verification across multiple blockchains (Ethereum, Polygon, etc.) for broader compatibility
* **Multi-Signature Gates**: Require multiple NFT ownerships or signatures for high-security access points
* **Mobile SDK**: Native mobile SDKs for iOS and Android with biometric authentication and offline caching

### Phase 4: Marketplace & Economy (Q2 2026)
* **Marketplace Integration**: Secondary market for access passes with automatic royalty distribution to creators
* **Advanced Analytics**: Machine learning-powered insights for access optimization and user behavior prediction
* **Enterprise API**: RESTful API with SLA guarantees for enterprise integrations

### Future Enhancements
- Layer 2 scaling solutions for reduced transaction costs
- Zero-knowledge proof integration for privacy-preserving access
- DAO governance for protocol upgrades and parameter changes
- Integration with major identity providers (OAuth, SAML, etc.)

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
- Thanks to the Stacks community for ongoing support and feedback

## 📞 Support

- **Documentation**: [docs.gatesigil.com](https://docs.gatesigil.com)
- **Discord**: [Join our community](https://discord.gg/gatesigil)
- **Email**: support@gatesigil.com
- **GitHub Issues**: [Report bugs and request features](https://github.com/your-org/gate-sigil/issues)

---

**Built with ❤️ for the decentralized web**