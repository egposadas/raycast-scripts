# Script Templates

Template files for creating new Raycast scripts in different languages.

## Available Templates

### template.sh
Shell script template with proper Raycast metadata headers.
- Copy this file to create new shell scripts
- Replace placeholder values with your script details
- Implement your logic after the headers

### template.js
Node.js script template with proper Raycast metadata headers.
- Copy this file to create new JavaScript scripts
- Requires Node.js to be installed
- Replace placeholder values with your script details

### template.applescript
AppleScript template with proper Raycast metadata headers.
- Copy this file to create new AppleScript scripts
- Works with macOS system automation
- Replace placeholder values with your script details

## Usage

1. Copy the appropriate template file
2. Rename it to your script name
3. Replace all placeholder values marked with `[brackets]`
4. Implement your script logic
5. Make the file executable: `chmod +x your-script.sh`
6. Test the script before adding to Raycast

## Metadata Guidelines

- Use descriptive titles that clearly indicate functionality
- Choose appropriate icons (emojis or SF Symbols)
- Select the right mode based on output needs:
  - `silent` - No visible output
  - `inline` - Single line output
  - `compact` - Multi-line compact output  
  - `fullOutput` - Full detailed output