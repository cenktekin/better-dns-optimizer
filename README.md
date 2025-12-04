# 🚀 Linux DNS Optimizer

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Sistem DNS yapılandırmasını test eden, en hızlı DNS sunucularını bulan ve otomatik yapılandıran gelişmiş bir Linux aracıdır.

## ✨ Özellikler

- **⚡ Gerçek DNS Hız Testi**: `dig` komutu ile gerçek DNS sorgu sürelerini ölçer
- **📈 Detaylı İstatistikler**: Standart sapma, minimum/maksimum gecikme, başarı oranı ve paket kaybı gibi gelişmiş metrikler
- **🛡️ Güvenlik Testleri**: DNS sızıntısı ve DNSSEC doğrulama testi
- **🌐 IPv4 & IPv6 Desteği**: Her iki IP versiyonu için ayrı ayrı test seçeneği
- **🎯 Mod Seçimi**: Güvenlik/privacy, hız/performans veya tüm DNS sunucuları için test modları
- **🇹🇷 Türkiye DNS Desteği**: TTNET, Superonline ve Vodafone gibi Türkiye'ye özel DNS sunucuları
- **🔄 Otomatik Test**: Belirli aralıklarla otomatik DNS testi yapma
- **💾 Yedekleme & Geri Yükleme**: Yapılandırmaları otomatik yedekleme ve kolay geri yükleme
- **📋 Geçmiş Kayıtlar**: Daha önceki test sonuçlarını görüntüleme
- **⚙️ Yapılandırma Dosyası**: Kullanıcı tercihlerini kalıcı olarak saklama

## 📋 İçindekiler

- [Gereksinimler](#gereksinimler)
- [Kullanım](#kullanım)
- [Özellikler](#özellikler)
- [Desteklenen DNS Sunucuları](#desteklenen-dns-sunucuları)
- [Lisans](#lisans)

## Gereksinimler

- Bash
- dig komutu (dnsutils paketi)
- sudo erişimi
- root yetkisi (scripti çalıştırmak için)

## Kullanım

### Hızlı Kurulum
```bash
sudo bash dns.sh
```

### İndirme ve Çalıştırma
```bash
wget https://raw.githubusercontent.com/cenktekin/better-dns-optimizer/main/dns.sh
chmod +x dns.sh
sudo ./dns.sh
```

## Özellikler

### 1. Test Modları
- **Güvenlik/Privacy**: Reklam engelleyen ve gizlilik odaklı DNS sunucuları testi
- **Hız/Performans**: En hızlı DNS sunucuları testi
- **Tümü**: Tüm DNS sunucuları için kapsamlı test

### 2. IP Versiyon Seçimi
- **IPv4 & IPv6**: Her iki versiyon için test
- **Sadece IPv4**: Sadece IPv4 DNS sunucuları için test
- **Sadece IPv6**: Sadece IPv6 DNS sunucuları için test

### 3. Otomatik Test Modu
- Belirli aralıklarla otomatik test yapar
- Sonuçları log dosyasına kaydeder
- Uzun süreli izleme için idealdir

### 4. Güvenlik Testleri
- DNS sızıntısı kontrolü
- DNSSEC doğrulama testi
- DNS yapılandırmasının güvenliğini kontrol eder

### 5. Yedekleme & Geri Yükleme
- Yapılandırmalar otomatik yedeklenir
- Kolay geri yükleme işlemi
- Hatalı yapılandırma durumunda güvenli geri dönüş

## Desteklenen DNS Sunucuları

### Güvenlik & Privacy
- **AdGuard DNS**: Reklam ve izleyici engelleme
- **Quad9**: Kötü amaçlı yazılım koruması
- **Mullvad**: Sıfır kayıt politikası
- **CleanBrowsing**: Güvenlik filtresi

### Hız & Performans
- **Cloudflare**: 1.1.1.1, 1.0.0.1
- **Google Public DNS**: 8.8.8.8, 8.8.4.4
- **Control D**: Yüksek hız
- **OpenDNS**: Cisco

### Bölgeye Özel
- **TTNET** (Türkiye): 213.161.192.12, 213.161.193.13
- **Superonline** (Türkiye): 193.192.97.146, 193.192.98.146
- **Vodafone** (Türkiye): 195.175.50.50, 195.175.51.51
- **HKBN** (Hong Kong): 203.80.96.10, 203.80.96.9
- **HiNet** (Tayvan): 168.95.1.1
- **KT DNS** (Güney Kore): 168.126.63.1

## Katkıda Bulunma

Her türlü katkıya açığız! Geliştirmeler, hata düzeltmeleri veya yeni DNS sunucuları önerileri için pull request göndermekten çekinmeyin.

## Lisans

Bu proje, orijinal Linux DNS Optimizer projesinin bir türevidir. Orijinal script [EmersonLopez2005](https://github.com/EmersonLopez2005/Linux-DNS-Optimizer) tarafından geliştirilmiştir.

Bu proje MIT Lisansı ile lisanslanmıştır - detaylar için [LICENSE](LICENSE) dosyasına bakın.

### Orijinal Proje
- **Yazar**: EmersonLopez2005
- **Kaynak**: https://github.com/EmersonLopez2005/Linux-DNS-Optimizer
- **Lisans**: MIT

### Bu Türev Proje
- **Geliştirici**: cenktekin
- **Kaynak**: https://github.com/cenktekin/better-dns-optimizer
- **Lisans**: MIT

Bu proje, orijinal projenin geliştirilmiş ve genişletilmiş bir sürümüdür. Orijinal yazarın çalışmasına saygı duyulmakta ve katkılarından dolayı teşekkür edilmektedir.

---

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

This project is a derivative of the original Linux DNS Optimizer project. The original script was developed by [EmersonLopez2005](https://github.com/EmersonLopez2005/Linux-DNS-Optimizer).

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Original Project
- **Author**: EmersonLopez2005
- **Source**: https://github.com/EmersonLopez2005/Linux-DNS-Optimizer
- **License**: MIT

### This Derivative Project
- **Developer**: cenktekin
- **Source**: https://github.com/cenktekin/better-dns-optimizer
- **License**: MIT

This project is an enhanced and extended version of the original project. Respect is shown to the original author's work and gratitude is expressed for their contributions.