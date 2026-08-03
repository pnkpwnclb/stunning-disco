#!/usr/bin/env bash

# ===== CONFIG =====
GITHUB_USER="pnkpwnclb"
REPO_NAME="stunning-disco"
BRANCH="main"
DOMAIN="pnkpwn.club"

GITHUB_TOKEN="${GITHUB_TOKEN:?set the GITHUB_TOKEN env var before running}"


# ===== STEP 1: Push local site =====
echo "Pushing site to GitHub..."

cd site/

git add .
git commit -m "Deploy static site" || true
git branch -M $BRANCH
git remote remove origin 2>/dev/null
git remote add origin https://$GITHUB_USER:$GITHUB_TOKEN@github.com/$GITHUB_USER/$REPO_NAME.git
git push -u origin $BRANCH

# ===== STEP 2: Enable GitHub Pages =====
echo "Enabling GitHub Pages..."

curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/$GITHUB_USER/$REPO_NAME/pages \
  -d "{
    \"source\": {
      \"branch\": \"$BRANCH\",
      \"path\": \"/\"
    }
  }"

# ===== STEP 3: Set custom domain (optional) =====
if [ -n "$DOMAIN" ]; then
  echo "Setting custom domain..."

  curl -s -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    https://api.github.com/repos/$GITHUB_USER/$REPO_NAME/pages \
    -d "{
      \"cname\": \"$DOMAIN\"
    }"
fi

echo "✅ GitHub Pages setup complete!"