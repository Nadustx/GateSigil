# GateSigil 🔑

> Unlock Realms with NFT Passes of Power

GateSigil transforms NFTs into powerful access passes for private content, services, and communities. Built on the Stacks blockchain using Clarity smart contracts, it provides a secure and decentralized way to manage access control through NFT ownership.

## 🌟 Features

- **NFT-Based Access Control**: Use wallet-based NFT ownership to grant access to exclusive content
- **Expirable Access**: Create time-limited NFTs for temporary access control
- **Realm Management**: Organize access permissions into logical "realms"
- **Batch Operations**: Efficiently mint multiple NFTs for events or large communities
- **Secure Transfers**: Built-in transfer functionality with access management
- **Revocation System**: Realm creators can revoke access when needed

## 🎯 Use Cases

- **Exclusive Clubs**: Private member communities with NFT membership cards
- **Paywalled Applications**: Premium app features unlocked by NFT ownership  
- **Event Check-ins**: Time-limited access passes for conferences or events
- **Content Platforms**: Creator-controlled access to premium content
- **Discord/Telegram Integration**: Token-gated community access

## 🛠 Technical Stack

- **Blockchain**: Stacks Layer 1
- **Smart Contract Language**: Clarity
- **NFT Standard**: SIP-009 compliant
- **Development Framework**: Clarinet

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for testing

### Installation

```bash
git clone <repository-url>
cd gatesigil
clarinet check
```

### Usage

1. **Create a Realm**:
   ```clarity
   (contract-call? .gatesigil create-realm "vip-club" "Exclusive VIP member access")
   ```

2. **Mint Access NFT**:
   ```clarity
   (contract-call? .gatesigil mint-access-nft 
     'SP1234...ABCD 
     "vip-club" 
     (some u144000) 
     "ipfs://metadata-uri")
   ```

3. **Check Access**:
   ```clarity
   (contract-call? .gatesigil check-access 'SP1234...ABCD "vip-club")
   ```

## 📋 Contract Functions

### Read-Only Functions
- `get-token-info`: Retrieve NFT metadata and status
- `get-realm-info`: Get realm configuration details
- `check-access`: Verify user access to a specific realm
- `is-token-expired`: Check if an NFT has expired

### Public Functions  
- `create-realm`: Set up a new access-controlled area
- `mint-access-nft`: Create NFT access passes
- `transfer`: Move NFTs between wallets
- `revoke-token`: Disable access for specific NFTs
- `batch-mint`: Create multiple NFTs efficiently

## 🔐 Security Features

- Comprehensive input validation
- Proper error handling with descriptive error codes
- Owner-only administrative functions
- Expiration validation to prevent backdated tokens
- Secure transfer mechanisms with access updates

## 🧪 Testing

Run the test suite with:
```bash
clarinet test
```

## 📖 Documentation

For detailed API documentation and integration guides, see the `/docs` directory.

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests for any improvements.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔮 Future Roadmap

See our [Future Features](#future-features) section for planned enhancements and upgrade ideas.

