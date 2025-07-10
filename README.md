# 🛠️ SysHelper

[![Version](https://img.shields.io/badge/version-2.5-blue.svg)](https://github.com/MeXenon/syshelper)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Ubuntu-orange.svg)](https://ubuntu.com)

[🇮🇷 فارسی](README_FA.md) | 🇺🇸 English

**SysHelper** is a comprehensive system management tool designed for Ubuntu servers with Iranian mirror optimization, network management, and automated panel installation capabilities.

## ✨ Features

- 📊 **System Overview**: Real-time CPU, RAM, uptime, and load monitoring
- 🌐 **Network Information**: IP detection, DNS configuration, and ISP details
- 🔧 **Network Management**: IPv6 toggle and ping response control
- 🚀 **Mirror Speed Test**: Automatic ranking of 18+ Iranian Ubuntu mirrors
- ⚡ **Auto Configuration**: One-click mirror switching for optimal package downloads
- 📦 **3X-UI Panel**: Multi-version installation (v2.6.0 & v2.6.2)
- 🔐 **ACME.sh Integration**: SSL certificate manager installation
- 🎨 **Modern Interface**: Clean, colorful terminal UI with ASCII art and progress bars

## 🔧 Installation

### Option 1: Direct from GitHub
```bash
wget -qO- https://raw.githubusercontent.com/MeXenon/syshelper/main/xenonnet.sh | bash
```

### Option 2: Download and Run
```bash
wget https://raw.githubusercontent.com/MeXenon/syshelper/main/xenonnet.sh
chmod +x xenonnet.sh
./xenonnet.sh
```

### ✅️ Option 3: Alternative Source (Fallback) ( Iranian Source - Recommended for Iranian VPS )
```bash
wget -O syshelper2.5.tar.gz https://uploadkon.ir/uploads/302608_25syshelper2-5-tar.gz && tar -xzvf syshelper2.5.tar.gz && chmod +x xenonnet.sh && ./xenonnet.sh
```

## 📋 Prerequisites

The script automatically checks for required dependencies:
- `curl` - For network operations
- `wget` - For file downloads
- `bc` - For mathematical calculations
- `tar` - For archive extraction
- `iptables` - For network management (optional)

If missing, install with:
```bash
sudo apt-get update
sudo apt-get install curl wget bc tar iptables-persistent
```

## 🚀 Usage

1. **Run the script** using any installation method above
2. **View system information** displayed automatically
3. **Choose from menu options**:
   - `1` - Test and apply best mirror
   - `2` - Install 3X-UI panel
   - `3` - Install ACME.sh
   - `4` - Network management
   - `5` - Refresh system information
   - `6` - Exit

### Mirror Testing Process
- Tests 18+ Iranian Ubuntu mirrors
- Parallel speed testing for faster results
- Checks mirror freshness and release dates
- Ranks by performance and reliability
- Applies fastest mirror automatically
- Updates package index

### 3X-UI Installation
- Choose between v2.6.0 (Legacy) and v2.6.2 (Latest)
- Smart archive extraction with nested support
- Automated extraction and setup
- Localized installation resources
- Perfect for Iranian datacenters

### Network Management
- **IPv6 Control**: Enable/disable IPv6 (temporary or permanent)
- **Ping Response**: Block/allow ping responses via iptables
- **Real-time Status**: Live monitoring of network configurations
- **System Integration**: Persistent settings across reboots

### ACME.sh Integration
- Automated SSL certificate manager installation
- Latest version with smart extraction
- Ready-to-use certificate automation
- Perfect for web server setups

## 📊 System Information Display

The tool provides a comprehensive overview including:

| Category | Information |
|----------|-------------|
| **CPU** | Model, cores, usage percentage, load average |
| **Memory** | Used/Total RAM with percentage |
| **Network** | Public IP, location, ISP, DNS servers |
| **System** | Uptime, Ubuntu version, current APT mirror |
| **Network Status** | IPv6 status, ping response configuration |

## 🌍 Mirror List

Enhanced Iranian mirror database (18+ mirrors):
- archive.ubuntu.mirrors.zagrio.net
- mirror.iranserver.com
- ubuntu-mirror.kimiahost.com
- ubuntu.avinahost.com
- ubuntu.mobinhost.com
- ubuntu.pishgaman.net
- ir.ubuntu.sindad.cloud
- mirror.aminidc.com
- mirror.arvancloud.ir
- mirrors.pardisco.co
- archive.ubuntu.petiak.ir
- linuxmirrors.ir
- ubuntu.pars.host
- ubuntu.parsvds.com
- mirror.faraso.org
- mirrors.ubuntu.dimit.cloud
- repo.iut.ac.ir
- ir.archive.ubuntu.com

## 🛡️ Security & Permissions

- **Root detection**: Shows current user privilege level
- **Safe operations**: No destructive commands without confirmation
- **Backup friendly**: Original configurations preserved
- **Minimal footprint**: Temporary files cleaned automatically
- **Network security**: Safe iptables and sysctl modifications

## 🔍 Troubleshooting

### Common Issues

**Script won't run:**
```bash
chmod +x xenonnet.sh
```

**Missing dependencies:**
```bash
sudo apt-get install curl wget bc tar
```

**Network timeout:**
- Check internet connection
- Try alternative installation method

**Permission denied:**
- Run with appropriate privileges
- Use `sudo` for system-wide changes

**IPv6/Ping management not working:**
- Ensure iptables is installed
- Check root privileges for network changes

## 📝 Version History

### v2.5 (Current)
- **New**: Network management panel with IPv6/ping control
- **New**: ACME.sh SSL certificate manager installation
- **New**: Multi-version 3X-UI support (v2.6.0 & v2.6.2)
- **Enhanced**: 18+ Iranian mirror database
- **Improved**: Parallel mirror testing for faster results
- **Improved**: Smart archive extraction with nested support
- **Improved**: ASCII art header and professional UI design
- **Improved**: Release date verification for mirrors
- **Improved**: Better error handling and diagnostics

### v2.0
- Complete UI redesign
- Enhanced mirror testing algorithm
- Improved progress indicators
- Added 3X-UI installation
- Better error handling

### v1.x
- Basic system information
- Simple mirror testing

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/MeXenon/syshelper/issues)
- 💬 **Telegram**: [@XenonNet](https://t.me/XenonNet)
- 📧 **Developer**: [@XenonNet](https://t.me/XenonNet)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⭐ Show Your Support

If this project helped you, please consider giving it a ⭐ on GitHub!

---

**Made with ❤️ by [@XenonNet](https://github.com/MeXenon)**
