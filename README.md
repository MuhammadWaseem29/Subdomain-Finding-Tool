# FINDER - Professional Edition

**Enterprise-Grade Subdomain Enumeration Framework**

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/MuhammadWaseem29/subfinder)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Author](https://img.shields.io/badge/author-MuhammadWaseem29-orange.svg)](https://github.com/MuhammadWaseem29)

FINDER is a comprehensive enterprise-grade subdomain enumeration framework that integrates 7 powerful reconnaissance tools with automated installation, intelligent path detection, and professional reporting capabilities.

## 🌟 Features

- **Multi-Tool Integration**: Combines 7 industry-leading subdomain discovery tools
- **Automated Installation**: One-command setup for all dependencies
- **Intelligent Path Detection**: Automatically finds and configures tool paths
- **Professional Reporting**: Detailed analytics and performance metrics
- **Batch Processing**: Support for single domains and domain lists
- **Real-time Analytics**: Live performance dashboard during enumeration
- **Flexible Output**: Display results on screen or save to file
- **Error Handling**: Robust error handling and cleanup mechanisms

## 🔧 Integrated Tools

FINDER integrates the following subdomain enumeration tools:

1. **subfinder** - Fast passive subdomain discovery (ProjectDiscovery)
2. **subdominator** - Advanced subdomain enumeration (RevoltSecurities)
3. **assetfinder** - Find domains and subdomains related to a given domain
4. **chaos** - ProjectDiscovery's subdomain discovery service
5. **findomain** - Cross-platform subdomain enumerator
6. **sublist3r** - Python-based subdomain discovery tool
7. **subscraper** - DNS brute force + certificate transparency

## 📋 Requirements

- **Operating System**: Linux (Ubuntu/Debian recommended)
- **Permissions**: Root access for installation (`sudo`)
- **Internet Connection**: Required for tool installation and enumeration
- **Dependencies**: 
  - Go (1.22+)
  - Python 3
  - Git
  - curl/wget

## 🚀 Installation

### Quick Install

Run the automated installation script (requires root privileges):

```bash
sudo ./Subdomains.sh --install
```

This will:
- Update system packages
- Install Go and Python dependencies
- Install all 7 integrated tools
- Configure PATH variables
- Set up Chaos API key (pre-configured)

### Manual Installation

If you prefer manual installation, ensure the following tools are installed and accessible:

- [subfinder](https://github.com/projectdiscovery/subfinder)
- [subdominator](https://github.com/RevoltSecurities/Subdominator)
- [assetfinder](https://github.com/tomnomnom/assetfinder)
- [chaos](https://github.com/projectdiscovery/chaos-client)
- [findomain](https://github.com/findomain/findomain)
- [sublist3r](https://github.com/aboul3la/Sublist3r)
- [subscraper](https://github.com/m8sec/subscraper)

## 📖 Usage

### Basic Usage

**Single Domain Enumeration:**
```bash
./Subdomains.sh -d example.com
```

**Multiple Domains from File:**
```bash
./Subdomains.sh -dL domains.txt
```

**Save Results to File:**
```bash
./Subdomains.sh -d example.com -o results.txt
```

**Generate Detailed Report:**
```bash
./Subdomains.sh -d example.com -r security_audit
```

### Command-Line Options

| Option | Description |
|--------|-------------|
| `-d <domain>` | Target domain to enumerate |
| `-dL <file>` | File containing list of domains (one per line) |
| `-o <output_file>` | Custom output file (default: display on screen only) |
| `-r <report_name>` | Generate detailed HTML report |
| `--install` | Install all required tools |
| `--check` | Check tool availability |
| `--setup-chaos` | Configure Chaos API key interactively |
| `--debug` | Show PATH and binary location debug info |
| `--update` | Update all tools to latest versions |
| `--version` | Show version information |
| `--help` | Show help message |

### Examples

**Basic enumeration:**
```bash
./Subdomains.sh -d example.com
```

**Save results to file:**
```bash
./Subdomains.sh -d example.com -o subdomains.txt
```

**Multiple domains with report:**
```bash
./Subdomains.sh -dL domains.txt -r security_audit
```

**Check tool status:**
```bash
./Subdomains.sh --check
```

**Debug PATH issues:**
```bash
./Subdomains.sh --debug
```

## 📊 Output & Reporting

FINDER provides comprehensive output including:

- **Real-time Progress**: Live updates as each tool runs
- **Performance Analytics**: Detailed statistics per tool
- **Executive Dashboard**: Key performance indicators
- **Tool Rankings**: Performance comparison across tools
- **HTML Reports**: Professional reports with timestamps and statistics

### Output Modes

1. **Screen Display** (default): Results displayed in terminal with color-coded output
2. **File Output** (`-o` flag): Save results to specified file
3. **HTML Report** (`-r` flag): Generate detailed HTML report

## ⚙️ Configuration

### Chaos API Key

FINDER comes with a pre-configured Chaos API key. To set your own:

```bash
./Subdomains.sh --setup-chaos
```

Or manually set the environment variable:
```bash
export PDCP_API_KEY="your-api-key-here"
```

Get your free API key at: https://chaos.projectdiscovery.io

### PATH Configuration

FINDER automatically detects and configures tool paths. If you encounter PATH issues:

```bash
./Subdomains.sh --debug
```

This will show diagnostic information and suggest fixes.

## 🎯 Features in Detail

### Intelligent Tool Detection
- Automatically finds tools in common installation locations
- Supports multiple PATH configurations
- Handles both system-wide and user-specific installations

### Performance Analytics
- Real-time tool performance metrics
- Success rate tracking
- Tool contribution percentages
- Performance rankings and ratings

### Error Handling
- Graceful handling of tool failures
- Timeout protection for long-running tools
- Automatic cleanup of temporary files
- Detailed error messages and warnings

## 🔍 How It Works

1. **Initialization**: Checks tool availability and refreshes PATH
2. **Enumeration**: Runs all 7 tools in sequence against target domain(s)
3. **Collection**: Gathers results from each tool
4. **Analysis**: Generates performance statistics and analytics
5. **Output**: Displays results and saves to file (if specified)
6. **Cleanup**: Removes temporary files and directories

## 📝 Notes

- **Deduplication**: By default, FINDER preserves all results (no deduplication) for maximum coverage
- **Timeouts**: Tools have timeout protection (5-10 minutes depending on tool)
- **Permissions**: Installation requires root privileges
- **Internet**: Active internet connection required for enumeration

## 🐛 Troubleshooting

### Tools Not Found

If tools are not detected:
```bash
./Subdomains.sh --check
./Subdomains.sh --debug
```

**Solution**: Run `./Subdomains.sh --install` or manually add tool paths to your shell profile.

### PATH Issues

If you see "command not found" errors:
```bash
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
source ~/.bashrc
```

### Installation Failures

If installation fails:
1. Ensure you have root privileges (`sudo`)
2. Check internet connectivity
3. Review error messages for specific tool failures
4. Try manual installation for problematic tools

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

**MuhammadWaseem29**

- GitHub: [@MuhammadWaseem29](https://github.com/MuhammadWaseem29)
- Repository: [subfinder](https://github.com/MuhammadWaseem29/subfinder)

## 🙏 Acknowledgments

- [ProjectDiscovery](https://projectdiscovery.io) for subfinder and chaos
- [RevoltSecurities](https://github.com/RevoltSecurities) for subdominator
- [tomnomnom](https://github.com/tomnomnom) for assetfinder
- [findomain](https://github.com/findomain) for findomain
- [aboul3la](https://github.com/aboul3la) for Sublist3r
- [m8sec](https://github.com/m8sec) for subscraper

## ⚠️ Disclaimer

This tool is for authorized security testing and research purposes only. Users are responsible for ensuring they have proper authorization before testing any domain. The authors and contributors are not responsible for any misuse or damage caused by this tool.

## 📞 Support

For issues, questions, or contributions:
- Open an issue on GitHub
- Check existing issues for solutions
- Review the `--help` output for usage information

---

**Made with ❤️ by MuhammadWaseem29**

*FINDER - Professional Edition - Enterprise-Grade Subdomain Enumeration Framework*
