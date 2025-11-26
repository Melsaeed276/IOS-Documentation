#!/bin/bash

# Script to push DocC documentation to GitHub
# This script will prompt for your GitHub credentials

cd "/Users/muhammed.aksis/Library/Mobile Documents/iCloud~md~obsidian/Documents/Structure Docuemnt"

echo "🚀 Pushing DocC documentation to GitHub..."
echo ""
echo "Repository: https://github.com/Melsaeed276/IOS-Documentation.git"
echo ""
echo "You will be prompted for:"
echo "  - Username: Your GitHub username"
echo "  - Password: Use a Personal Access Token (NOT your GitHub password)"
echo ""
echo "To create a Personal Access Token:"
echo "  1. Go to: https://github.com/settings/tokens"
echo "  2. Click 'Generate new token (classic)'"
echo "  3. Select 'repo' scope"
echo "  4. Copy the token and use it as your password"
echo ""
echo "Press Enter to continue or Ctrl+C to cancel..."
read

git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo "📚 View your documentation at: https://github.com/Melsaeed276/IOS-Documentation"
else
    echo ""
    echo "❌ Push failed. Please check your credentials and try again."
fi

