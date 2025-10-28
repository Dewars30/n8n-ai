# ⚠️  ACTION REQUIRED: Enable Coder Connect VPN

## What's Happening

VS Code is trying to connect using `n8n-ai-workspace.coder` hostname, which is **correct**! But the connection times out because **Coder Desktop's VPN tunnel is not active**.

```
[02:15:13.060] ssh: connect to host n8n-ai-workspace.coder port 22: Operation timed out
```

## What You Need to Do RIGHT NOW

### Step 1: Open Coder Desktop App

**Option A: Click the menu bar icon**
- Look at the top right of your screen (macOS menu bar)
- Find the Coder icon and click it
- OR open the full app window

**Option B: Use Spotlight**
- Press `Cmd+Space`
- Type: "Coder Desktop"
- Press Enter

### Step 2: Check the Connection Status

Look for a status indicator that says:
- ✅ **"Connected"** - Good! But VPN might not be enabled yet
- ❌ **"Disconnected"** - You need to reconnect
- 🔄 **"Connecting..."** - Wait for it to finish

If it says "Disconnected":
1. Look for a "Connect" or "Sign In" button
2. Enter server URL: `http://127.0.0.1:3000`
3. Authenticate in the browser window that opens

### Step 3: Enable "Coder Connect" Toggle

**This is the critical step!**

Look for a toggle/switch labeled:
- "Coder Connect"
- "Enable VPN"
- "Network Tunnel"
- Or similar VPN-related label

**Make sure this toggle is turned ON (blue/green color)**

If you don't see the toggle:
- Look in Settings/Preferences menu
- Check for a "Network" or "VPN" section

When you enable it:
- macOS might ask for permissions → Click "Allow"
- You might need to enter your Mac password

### Step 4: Verify VPN is Active

After enabling Coder Connect, the menu bar icon should show a connected status.

**Now test from your terminal:**

```bash
# This command should return the workspace hostname
ssh n8n-ai-workspace.coder hostname
```

**Expected result:**
```
coder-Dewars30-n8n-ai-workspace
```

**If it still times out:**
- Toggle Coder Connect OFF, wait 3 seconds, then ON again
- Restart Coder Desktop app entirely
- Check System Settings > Privacy & Security > Network Extensions

### Step 5: Try VS Code Again

Once the SSH test works, try connecting VS Code:

**Method 1: From Coder Desktop**
- Find `n8n-ai-workspace` in the workspace list
- Click "Open in VS Code" button

**Method 2: From VS Code**
- Open VS Code
- Press `Cmd+Shift+P`
- Type: "Remote-SSH: Connect to Host"
- Select: `n8n-ai-workspace.coder`

## Visual Guide

When Coder Desktop is properly configured, you should see:

```
┌─────────────────────────────────────┐
│  Coder Desktop                      │
├─────────────────────────────────────┤
│  Status: Connected                  │
│  Server: http://127.0.0.1:3000      │
│                                     │
│  ☑  Coder Connect    [ON]           │
│     VPN tunnel enabled              │
│                                     │
│  Workspaces:                        │
│  • n8n-ai-workspace  [Running]      │
│    [Open in VS Code] button         │
└─────────────────────────────────────┘
```

## Troubleshooting

### "I don't see Coder Connect toggle"

The VPN feature might be in:
- Preferences/Settings menu
- Advanced settings
- Network section

Or the app might need updating:
```bash
brew upgrade --cask coder/coder/coder-desktop
```

### "macOS won't let me enable VPN extension"

1. Go to: System Settings > Privacy & Security
2. Scroll to: Network Extensions
3. Enable: Coder Desktop
4. Restart Coder Desktop

### "Coder Desktop shows 'Disconnected'"

The server restart broke the connection:

1. Click "Disconnect" if shown
2. Click "Sign In" or "Connect"
3. Enter: `http://127.0.0.1:3000`
4. Authenticate in browser
5. Enable "Coder Connect" toggle

### "SSH test still times out"

Try forcing a reconnection:

```bash
# Quit Coder Desktop completely
pkill -9 "Coder Desktop"

# Wait 5 seconds
sleep 5

# Restart it
open -a "Coder Desktop"

# Wait 10 seconds for it to connect
sleep 10

# Test again
ssh n8n-ai-workspace.coder hostname
```

## Why This is Necessary

Coder Desktop creates a VPN tunnel that makes your workspace accessible via the `.coder` hostname. Without the VPN:
- ❌ `n8n-ai-workspace.coder` → times out
- ❌ VS Code Remote-SSH → times out
- ❌ Any IDE integration → fails

With the VPN active:
- ✅ `n8n-ai-workspace.coder` → connects instantly
- ✅ VS Code Remote-SSH → works perfectly
- ✅ All development tools → just work

## After You Enable Coder Connect

**Reply to this chat with:**

1. What you see in Coder Desktop (status, toggle position)
2. The result of: `ssh n8n-ai-workspace.coder hostname`
3. Whether VS Code connects successfully

---

**Current Time:** 2025-10-28 02:15 PST
**Action Required:** Enable Coder Connect toggle in Coder Desktop app
**Next Step:** Test SSH connection and then VS Code
