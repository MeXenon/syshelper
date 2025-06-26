# 🛠️ SysHelper

[![Version](https://img.shields.io/badge/version-2.0-blue.svg)](https://github.com/MeXenon/syshelper)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Ubuntu-orange.svg)](https://ubuntu.com)

[🇮🇷 فارسی](README_FA.md) | 🇺🇸 English

**SysHelper** is a comprehensive system management tool designed for Ubuntu servers with Iranian mirror optimization and automated panel installation capabilities.

## ✨ Features

- 📊 **System Overview**: Real-time CPU, RAM, uptime, and load monitoring
- 🌐 **Network Information**: IP detection, DNS configuration, and ISP details
- 🚀 **Mirror Speed Test**: Automatic ranking of fastest Iranian Ubuntu mirrors
- ⚡ **Auto Configuration**: One-click mirror switching for optimal package downloads
- 📦 **3X-UI Panel**: Automated installation with localized resources
- 🎨 **Modern Interface**: Clean, colorful terminal UI with progress bars

## 🔧 Installation

### Option 1: Direct from GitHub (Recommended)
```bash
wget -qO- https://raw.githubusercontent.com/MeXenon/syshelper/main/xenonnet.sh | bash
```

### Option 2: Download and Run
```bash
wget https://raw.githubusercontent.com/MeXenon/syshelper/main/xenonnet.sh
chmod +x xenonnet.sh
./xenonnet.sh
```

### Option 3: Alternative Source (Fallback)
```bash
wget -qO- https://uploadkon.ir/uploads/d20726_25syshelper-tar.gz | tar -xz && find . -type f -name "*.sh" -exec chmod +x {} \; && ./xenonnet.sh
```

## 📋 Prerequisites

The script automatically checks for required dependencies:
- `curl` - For network operations
- `wget` - For file downloads
- `bc` - For mathematical calculations

If missing, install with:
```bash
sudo apt-get update
sudo apt-get install curl wget bc
```

## 🚀 Usage

1. **Run the script** using any installation method above
2. **View system information** displayed automatically
3. **Choose from menu options**:
   - `1` - Test and apply best mirror
   - `2` - Install 3X-UI panel
   - `3` - Refresh system information
   - `4` - Exit

### Mirror Testing Process
- Tests 10+ Iranian Ubuntu mirrors
- Measures download speeds
- Ranks by performance
- Applies fastest mirror automatically
- Updates package index

### 3X-UI Installation
- Downloads latest 3X-UI panel (v2.6.0)
- Automated extraction and setup
- Localized installation resources
- Perfect for Iranian datacenters

## 📊 System Information Display

The tool provides a comprehensive overview including:

| Category | Information |
|----------|-------------|
| **CPU** | Model, cores, usage percentage, load average |
| **Memory** | Used/Total RAM with percentage |
| **Network** | Public IP, location, ISP, DNS servers |
| **System** | Uptime, Ubuntu version, current APT mirror |

## 🌍 Mirror List

Tested Iranian mirrors include:
- ubuntu.pishgaman.net
- mirror.aminidc.com
- ubuntu.pars.host
- ir.ubuntu.sindad.cloud
- ubuntu.shatel.ir
- ubuntu.mobinhost.com
- mirror.iranserver.com
- mirror.arvancloud.ir
- And more...

## 🛡️ Security & Permissions

- **Root detection**: Shows current user privilege level
- **Safe operations**: No destructive commands without confirmation
- **Backup friendly**: Original configurations preserved
- **Minimal footprint**: Temporary files cleaned automatically

## 🔍 Troubleshooting

### Common Issues

**Script won't run:**
```bash
chmod +x xenonnet.sh
```

**Missing dependencies:**
```bash
sudo apt-get install curl wget bc
```

**Network timeout:**
- Check internet connection
- Try alternative installation method

**Permission denied:**
- Run with appropriate privileges
- Use `sudo` for system-wide changes

## 📝 Version History

### v2.0 (Current)
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
- 💬 **Telegram**: [@XenonNet_support](https://t.me/XenonNet_support)
- 📧 **Developer**: [@XenonNet](https://t.me/XenonNet)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⭐ Show Your Support

If this project helped you, please consider giving it a ⭐ on GitHub!

---

**Made with ❤️ by [@XenonNet](https://github.com/MeXenon)**
