# 🚀 Linux DNS Optimizer

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

An advanced Linux tool that tests system DNS configuration, finds the fastest DNS servers, and automatically configures them.

## ✨ Features

- **⚡ Real DNS Speed Test**: Measures actual DNS query times using `dig` command
- **📈 Detailed Statistics**: Advanced metrics including standard deviation, min/max latency, success rate, and packet loss
- **🛡️ Security Tests**: DNS leak detection and DNSSEC validation test
- **🌐 IPv4 & IPv6 Support**: Separate testing options for both IP versions
- **🎯 Mode Selection**: Test modes for security/privacy, speed/performance, or all DNS servers
- **🇹🇷 Turkey DNS Support**: Turkey-specific DNS servers like TTNET, Superonline, and Vodafone
- **🔄 Auto Test**: Automatic DNS testing at specified intervals
- **💾 Backup & Restore**: Automatic configuration backup and easy restoration
- **📋 History Records**: View previous test results
- **⚙️ Configuration File**: Persistent storage of user preferences

## 📋 Table of Contents

- [Requirements](#requirements)
- [Usage](#usage)
- [Features](#features)
- [Supported DNS Servers](#supported-dns-servers)
- [License](#license)

## Requirements

- Bash
- dig command (from dnsutils package)
- sudo access
- root privileges (to run the script)

## Usage

### Quick Start
```bash
sudo bash dns.sh
```

### Download and Run
```bash
wget https://raw.githubusercontent.com/cenktekin/better-dns-optimizer/main/dns.sh
chmod +x dns.sh
sudo ./dns.sh
```

## Features

### 1. Test Modes
- **Security/Privacy**: Tests ad-blocking and privacy-focused DNS servers
- **Speed/Performance**: Tests the fastest DNS servers
- **All**: Comprehensive test of all DNS servers

### 2. IP Version Selection
- **IPv4 & IPv6**: Test for both versions
- **IPv4 Only**: Test only IPv4 DNS servers
- **IPv6 Only**: Test only IPv6 DNS servers

### 3. Auto Test Mode
- Automatic testing at specified intervals
- Results saved to log file
- Ideal for long-term monitoring

### 4. Security Tests
- DNS leak detection
- DNSSEC validation test
- Checks security of DNS configuration

### 5. Backup & Restore
- Automatic configuration backup
- Easy restoration process
- Safe recovery in case of misconfiguration

## Supported DNS Servers

### Security & Privacy
- **AdGuard DNS**: Ad and tracker blocking
- **Quad9**: Malware protection
- **Mullvad**: Zero logging policy
- **CleanBrowsing**: Security filter

### Speed & Performance
- **Cloudflare**: 1.1.1.1, 1.0.0.1
- **Google Public DNS**: 8.8.8.8, 8.8.4.4
- **Control D**: High speed
- **OpenDNS**: Cisco

### Regional
- **TTNET** (Turkey): 213.161.192.12, 213.161.193.13
- **Superonline** (Turkey): 193.192.97.146, 193.192.98.146
- **Vodafone** (Turkey): 195.175.50.50, 195.175.51.51
- **HKBN** (Hong Kong): 203.80.96.10, 203.80.96.9
- **HiNet** (Taiwan): 168.95.1.1
- **KT DNS** (South Korea): 168.126.63.1

## Contributing

We welcome all kinds of contributions! Feel free to submit pull requests for improvements, bug fixes, or new DNS server suggestions.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.