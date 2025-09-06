#!/bin/bash

# Setup script for Raycast Scripts Repository
# This script helps prepare the repository for use with Raycast

echo "🚀 Setting up Raycast Scripts Repository"
echo "======================================="

# Make all scripts executable
echo "📝 Making all scripts executable..."
find scripts -name "*.sh" -exec chmod +x {} \;
find scripts -name "*.js" -exec chmod +x {} \;
find scripts -name "*.applescript" -exec chmod +x {} \;

echo "✅ All scripts are now executable"

# Display repository structure
echo ""
echo "📁 Repository structure:"
tree scripts/ 2>/dev/null || find scripts -type f | sort

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Open Raycast"
echo "2. Go to Extensions"
echo "3. Click '+' to add a script"
echo "4. Navigate to the script files in this repository"
echo "5. Add the scripts you want to use"
echo ""
echo "📖 See README.md for detailed usage instructions"