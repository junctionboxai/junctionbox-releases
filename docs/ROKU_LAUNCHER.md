# Roku Launcher: your own home screen on your Roku TVs

Roku Launcher puts a custom home screen on your Roku TVs and boxes. It shows your streaming apps as big tiles, the weather, and a row of JunctionBox controls: your lights and air conditioning, your Ring cameras, your generated videos and photos, and your books. When you leave an app, the TV comes back to it by itself.

It has two parts, and the **Roku Launcher plugin** sets up both:

- **The TV app**, a small app installed on each Roku in developer mode (called "sideloading").
- **The bridge**, a small background program on the computer that runs JunctionBox. The TV app asks the bridge for weather, camera pictures, your photos and so on, and the bridge sends the launcher back to the screen when you exit an app.

Nothing here goes through Roku's channel store, and nothing leaves your home network except the weather lookup (Open-Meteo and the US National Weather Service).

## What you need

- JunctionBox running on a computer that stays on (Linux or macOS). The bridge runs on the same computer, as your own user, and must be on whenever you want the launcher to work.
- One or more Roku TVs or Roku boxes on the same home network as that computer.
- Python 3.9 or newer with the `venv` module on that computer. Ubuntu and Debian: `sudo apt install python3 python3-venv`. macOS: `brew install python`.
- Optional, for specific features:
  - **ffmpeg**, for Ring live view and the Web Video fallback player.
  - **poppler** (`pdftoppm`), for reading Book Studio and Comic Studio PDFs on the TV.
  - **Google Chrome**, for Web Video. Without it the plugin downloads a browser for you.

## Step 1: Turn on developer mode on each Roku

Do this once on every Roku you want the launcher on. It doesn't void the warranty and doesn't change how the Roku works. It only lets you install apps from your own computer. (This guide shows the steps for the TV's own remote. The Roku mobile app's remote works too.)

1. Turn the Roku on and go to its **Home** screen.
2. On the remote, press these buttons, fairly quickly and in this order:

   **Home, Home, Home, Up, Up, Right, Left, Right, Left, Right**

3. The **Developer Settings** screen opens. Write down the **IP address** it shows.
4. Choose **Enable installer and restart**, then accept the license agreement.
5. Choose a **webserver password**. Pick something simple and unique; you'll type it into JunctionBox, and it's only used on your home network. Write it down.
6. The Roku restarts. Developer mode is now on, and it stays on after restarts.

If the key sequence does nothing, check that the Roku is on its Home screen (not inside an app), then try again a little slower.

**One app slot.** A Roku can have only one sideloaded ("dev") app. Installing the launcher replaces any other app you sideloaded before.

### Give each Roku a fixed address

The launcher finds each TV by its IP address, so it must not change. In your router's settings, find "DHCP reservation", "address reservation" or "static lease", pick each Roku from the list of connected devices, and reserve its current address. Do the same for the computer that runs JunctionBox, because the TV app is built with that computer's address. If a TV or the computer ever changes address, update it in the plugin and press **Install** again on each TV.

## Step 2: Install the plugin

1. In JunctionBox, open **Settings, then Plugins**.
2. Choose **Browse for plugin ZIP** and pick `roku-launcher.zip` (it's attached to each JunctionBox release).
3. Restart JunctionBox when asked. **Roku Launcher** appears in the sidebar.

## Step 3: Use the setup page

Open **Roku Launcher**. The page has four numbered cards.

### 1. Developer mode

A reminder of Step 1 above, so you can keep this page open at the TV.

### 2. Start the bridge

Press **Set up the bridge**. The plugin does everything for you and shows its progress:

1. copies the bridge program to `~/.roku-launcher/runtime`,
2. builds a private Python environment for it (it never touches your system Python),
3. installs the image library it needs,
4. registers it as a background service that starts when you log in (systemd on Linux, launchd on macOS), and starts it.

When the page shows **Running**, the bridge is up. It lists **optional parts**:

| Part | What it adds | Notes |
|---|---|---|
| Ring live view | Live video and audio from your Ring cameras on the TV | Large download. Needs ffmpeg. |
| Web Video | A browser on your computer that you steer from the TV remote, with the video handed to the TV's own player | Needs Google Chrome or a downloaded browser. |
| ffmpeg | Re-streaming video | Install with your package manager. |
| pdftoppm | Reading Book Studio and Comic Studio PDFs | Install `poppler`. |

Install the ones you want. You can add them later. Anything missing is simply unavailable on the TV; the rest keeps working.

### 3. Add your TVs and install the launcher

1. Press **Find Rokus on my network** (or type the Roku's address). The plugin checks that the Roku is reachable, that developer mode is on, and that the password you typed is accepted.
2. Press **Add TV**.
3. Press **Install** on the TV's row. The launcher is built for your installation (your computer's address and a private key are written into it) and sent to the TV. The TV opens it right away.

**Install or update on all TVs** does every TV at once. After a JunctionBox update brings a newer launcher, each row shows **Update available**; press **Update**.

The key is a random token created on your computer, stored only in `~/.roku-launcher/token` (readable only by you) and inside the app on your TVs. The bridge ignores requests without it.

### 4. Choose what the home screen shows

- **Weather location**: search for your town and press **Use**.
- **Apps on the home screen**: press **Pick from this TV's apps** to list the channels actually installed on a TV, tick the ones you want as tiles, put them in order with the arrows, and press **Save apps**. Tile pictures come from the TV itself.

Changes show up the next time the launcher opens on the TV.

## Using the launcher on the TV

- **Home screen**: the top row of tiles are your apps. **Media Player** plays a video or audio URL. **Web Video** is described below. **JunctionBox** opens a row of hub tiles. **Settings** has the exit control.
- **Leaving an app** (Back or Home) returns you to the launcher. To really leave it, use **Settings, then Exit launcher**. Auto-return pauses so you can use the Roku's own Home and Settings, and resumes when you open the launcher again or turn the TV off and on.
- **JunctionBox hub**, depending on which plugins you have installed:
  - **Home Control**: lights, groups, colours, air conditioning, and a TV remote.
  - **Ring Security**: snapshots with battery levels and live view with audio.
  - **Video Studio**: play videos you generated.
  - **Photos**: your Stickers, Age Shift, Storyboard and Time Machine results. Hidden groups never appear, and password-protected groups show as locked with nothing inside.
  - **Books**: Comic Studio and Book Studio PDFs.
  - **Box Status**: your JunctionBox machines.
- **Web Video**: browse a website on the TV. Arrow keys either **jump** between links or move a **pointer** (switch with `*`, then Mode). **OK** clicks, **Rewind and Fast-forward** scroll, **Back** goes to the previous page. When the page has a video, a green badge says **VIDEO FOUND**; press **Play** and it plays in the Roku's own player. Videos protected by copy protection (Netflix, Hulu, Disney+ and similar) can't play this way.
  - **YouTube links** open in the Roku's own YouTube app, because YouTube doesn't expose a single stream.
  - **Watch List**: the separate **Watch List** plugin lets you save video links in JunctionBox; they appear on Web Video's start page.

## Updating and removing

- **Updating**: install a newer `roku-launcher.zip`, restart JunctionBox, then on the Roku Launcher page press **Update the bridge** (if offered) and **Update** on each TV.
- **Removing a TV**: **Remove** on its row. You'll be asked whether to also delete the launcher app from the TV.
- **Removing everything**: remove the TVs, press **Stop** on the bridge, delete the plugin, and delete the folder `~/.roku-launcher`. On Linux also run `systemctl --user disable --now roku-launcher-bridge`; on macOS delete `~/Library/LaunchAgents/com.junctionbox.roku-launcher-bridge.plist`.

## Troubleshooting

| What you see | What to do |
|---|---|
| "Can't reach a Roku at that address" | Check the TV is on (not just standby), the address is right, and the computer and TV are on the same network. Some routers keep Wi-Fi devices on a separate "guest" network. |
| "Developer mode is off" | Redo Step 1. After a factory reset, developer mode must be turned on again. |
| "The Roku rejected the developer password" | Use the webserver password from Step 1. To change it, repeat Step 1 and choose a new one. |
| "Set up the bridge first" | Finish card 2 and wait for **Running**. |
| The TV app says it can't reach the bridge | The bridge must be running, and the TV must be able to reach this computer's address. If the computer has more than one network connection, open **Advanced** in card 4 and enter the address the TV should use, then press **Install** on each TV again. Also check that your computer's firewall allows incoming connections on the bridge's port (8791 by default). |
| Weather or tiles don't update | They refresh when the launcher opens. Check that the bridge is **Running**. |
| Ring or Home Control tiles say a secret isn't found | Set up that plugin (Ring Security or Home Control) in JunctionBox first, then reopen the tile. |
| Ring live view is missing | Install **Ring live view** and **ffmpeg** in card 2. |
| The launcher vanished from a TV after an update | The Roku refused the new app. The plugin shows the Roku's own message when you press **Install**; the bridge log (**Show log**) has more. |
| The TV keeps going back to the launcher | That's auto-return. Use **Settings, then Exit launcher** on the TV. |
| "Python 3.9 or newer ... is needed" | Install Python with `venv` support (see What you need), then press **Set up the bridge** again. |

The bridge's log is `~/.roku-launcher/bridge.log`; **Show log** displays the end of it.

## Privacy and safety

- The bridge listens on your home network only. Every request needs the private token; media links given to the TV are signed and short-lived.
- The Roku **developer password** is stored encrypted in the JunctionBox database. It's used only to install the launcher on your own TVs.
- The bridge reads your JunctionBox data folder read-only (photos, videos, books). It never writes to the JunctionBox database. For Home Control and Ring Security, JunctionBox hands the bridge each plugin's private secret in memory, over the local connection only, using a second token that never goes onto a TV.
- Anything your plugins mark as hidden stays hidden, and password-protected photo groups appear locked with nothing inside, on the TV too.
- Don't expose the bridge's port to the internet.

## For developers

- The plugin source is `plugins/source/roku-launcher/`: the plugin's own `backend/` and `frontend/`, plus `launcher/` with the Roku app (`launcher/app`, a SceneGraph/BrightScript app) and the bridge (`launcher/bridge`, Python standard library plus optional packages). `scripts/package-local-plugins.py` builds `plugins/packages/roku-launcher.zip` from it.
- The app's source contains two placeholders, `__BRIDGE_URL__` and `__BRIDGE_TOKEN__`. The plugin fills them in when it builds the package for a TV, so neither the address nor the token is ever in the source or the zip. No third-party streaming logos are shipped: the bridge fetches each channel's icon from the TV that asks (`/tvicon/<id>`, cached for a week) and serves it to the launcher, because the Roku can't load pictures from its own control port.
- `launcher/tools/make_assets.py` regenerates the artwork in `launcher/app/images` (needs Pillow).
- Tests: `cd plugins/source/roku-launcher && PYTHONPATH=../../../backend pytest backend/tests/` (37 tests). They use a throwaway database and data folder, and a fake Roku developer page that checks the digest login and package upload, and never touch your real TVs.
- Roku BrightScript notes learned the hard way: never name things `left`, `step` or `next`; a Task node already has a `state` field; `setFocus(true)` on a parent does nothing while a hidden child list still holds focus, so give a screen a dedicated focus node.
