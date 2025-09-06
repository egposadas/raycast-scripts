# Raycast Scripts Collection

A curated collection of useful Raycast scripts organized by category for better maintenance and discoverability.

## 🚀 Quick Start

1. Clone or download this repository
2. Import scripts into Raycast:
   - Open Raycast
   - Go to Extensions
   - Click "+" to add script
   - Navigate to the script file you want to add
   - Click "Add Script"

## 📁 Repository Structure

```
scripts/
├── calendar/          # Calendar and meeting management scripts
├── productivity/      # Productivity and utility scripts
├── system/           # System utilities and configuration scripts
├── vpn/              # VPN management scripts
├── work/             # Work or company-specific scripts
└── templates/        # Script templates for creating new scripts
```

## 📋 Available Scripts

### 📅 Calendar
- **get-meeting-info.sh** - Get information about calendar events by title
- **get-meeting.sh** - Retrieve meeting details
- **get-my-schedule.sh** - Display your schedule

### 🎯 Productivity
- **clipboard-to-markdown.js** - Convert clipboard content to Markdown format
- **mail-deeplink.applescript** - Create deep links for mail items

### 🔧 System
- **dock-autohide.sh** - Toggle dock auto-hide setting
- **toggle-sidecar.js** - Toggle macOS Sidecar functionality
- **generate-git-ignore.sh** - Generate .gitignore files
- **get_env_value.sh** - Retrieve environment variable values
- **github-copilot-rules.sh** - GitHub Copilot configuration utilities

### 🔐 VPN
- **vpn-config.sh** - VPN configuration management
- **vpn-start.sh** - Start VPN connection
- **vpn-status.sh** - Check VPN connection status
- **vpn-stop.sh** - Stop VPN connection

### 🏢 Work
- **riverty-colors.sh** - Company-specific color utilities

## 🛠️ Creating New Scripts

Use the templates in `scripts/templates/` to create new scripts:

1. Copy the appropriate template file:
   - `template.sh` for shell scripts
   - `template.js` for Node.js scripts
   - `template.applescript` for AppleScript scripts

2. Replace placeholder values:
   - `[Script Title]` - Your script's title
   - `[Brief description]` - What your script does
   - `[Your Name]` - Your name
   - `[Your URL]` - Your website/profile URL

3. Implement your script logic

4. Make the script executable: `chmod +x your-script.sh`

## 📋 Raycast Script Parameters

Each script includes metadata headers that Raycast uses:

- `@raycast.schemaVersion` - Always set to 1
- `@raycast.title` - Script name shown in Raycast
- `@raycast.mode` - Output mode (silent, inline, compact, fullOutput)
- `@raycast.icon` - Icon displayed in Raycast (emoji or SF Symbol)
- `@raycast.description` - Brief description of functionality
- `@raycast.author` - Script author
- `@raycast.authorURL` - Author's website or profile

## 🔧 Dependencies

Some scripts may require additional dependencies:

- **Node.js scripts** - Require Node.js installation
- **Python scripts** - Require Python installation
- **Shell scripts** - Work with standard macOS shell

Install dependencies as needed for the scripts you want to use.

## 📖 Usage Tips

1. **Script Organization**: Scripts are organized by functionality to make them easier to find
2. **Naming Convention**: Use descriptive names that clearly indicate the script's purpose
3. **Documentation**: Each script includes inline documentation and usage examples
4. **Permissions**: Some scripts may require system permissions (accessibility, calendar access, etc.)

## 🤝 Contributing

1. Create new scripts using the provided templates
2. Place scripts in the appropriate category folder
3. Follow the existing naming conventions
4. Include proper Raycast metadata headers
5. Test scripts thoroughly before adding

## 📄 License

This collection is for personal use. Individual scripts may have their own licenses - check script headers for details.

## 🆘 Troubleshooting

### Common Issues

1. **Permission Denied**: Make sure scripts are executable (`chmod +x script-name.sh`)
2. **Script Not Found**: Verify the script path and file permissions
3. **Missing Dependencies**: Install required dependencies (Node.js, Python, etc.)
4. **System Permissions**: Grant necessary permissions in System Preferences

### Getting Help

- Check script headers for specific requirements
- Ensure all dependencies are installed
- Verify system permissions are granted
- Test scripts from command line first

---

Happy scripting! 🎉
