# Smart TV Launcher: your own home screen on your Roku and Google TVs

Smart TV Launcher puts a custom home screen on your Roku TVs and boxes, and on Google TV and Android TV sets. It shows your streaming apps as big tiles, the weather, and a row of JunctionBox controls: your lights and air conditioning, your Ring cameras, your generated videos and photos, your books and Bibles, and terminals for the Claude, Codex and Grok coding agents on your computer, plus shells on your JunctionBox boxes and screen sharing of them. When you leave an app, the TV comes back to it by itself.

It has two parts, and the **Smart TV Launcher plugin** sets up both:

- **The TV app**, a small app installed on each TV: a sideloaded app on a Roku (in developer mode), or a small Android app on a Google TV.
- **The bridge**, a small background program on the computer that runs JunctionBox. The TV app asks the bridge for weather, camera pictures, your photos and so on, and the bridge sends the launcher back to the screen when you exit an app.

Nothing here goes through Roku's channel store, and nothing leaves your home network except the weather lookup (Open-Meteo and the US National Weather Service).

## What it looks like

These pictures are of the real launcher on a TV, showing made-up demo data (no real boxes, photos or cameras).

![The home screen: your apps, the weather and the time](images/roku/home.jpg)

![The JunctionBox screen: status at the top, plugins below, a row of five at a time](images/roku/junctionbox-plugins-2.jpg)

| | |
|---|---|
| ![Home Control](images/roku/home-control-quick-access.jpg) | ![Ring cameras](images/roku/ring-cameras.jpg) |
| ![Video Studio](images/roku/video-studio-clips.jpg) | ![Photos](images/roku/photos-age-shift.jpg) |
| ![A Bible with chapters](images/roku/bible-reading.jpg) | ![Web Video](images/roku/web-video-page.jpg) |
| ![An agent terminal](images/roku/claude-answer.jpg) | ![Screen Share](images/roku/screen-share-desktop.jpg) |

## What you need

- JunctionBox running on a computer that stays on (Linux or macOS). The bridge runs on the same computer, as your own user, and must be on whenever you want the launcher to work.
- One or more Roku TVs or boxes, and/or Google TV or Android TV sets, on the same home network as that computer.
- Python 3.9 or newer with the `venv` module on that computer. Ubuntu and Debian: `sudo apt install python3 python3-venv`. macOS: `brew install python`.
- Optional, for specific features:
  - **ffmpeg**, for Ring live view and the Web Video fallback player.
  - **poppler** (`pdftoppm`), for reading Book Studio and Comic Studio PDFs and Bibles on the TV.
  - **Claude Code** (`claude`), **Codex** (`codex`) and/or **Grok** (`grok`), signed in on the computer, for the terminal tiles. Only the ones you have get a working tile.
  - **Google Chrome**, for Web Video (Roku only). Without it the plugin downloads a browser for you.
  - **adb** (Android's debugging tool), for Google TVs only. The plugin downloads Google's copy for you (about 12 MB) if you don't have it.

## Step 1: Get each TV ready

Do this once on every TV you want the launcher on. It doesn't void the warranty and doesn't change how the TV works. It only lets you install apps from your own computer.

### Roku: turn on developer mode

1. Turn the Roku on and go to its **Home** screen.
2. On the remote, press these buttons, fairly quickly and in this order:

   **Home, Home, Home, Up, Up, Right, Left, Right, Left, Right**

3. The **Developer Settings** screen opens. Write down the **IP address** it shows.
4. Choose **Enable installer and restart**, then accept the license agreement.
5. Choose a **webserver password**. Pick something simple and unique; you'll type it into JunctionBox, and it's only used on your home network. Write it down.
6. The Roku restarts. Developer mode is now on, and it stays on after restarts.

If the key sequence does nothing, check that the Roku is on its Home screen (not inside an app), then try again a little slower.

**One app slot.** A Roku can have only one sideloaded ("dev") app. Installing the launcher replaces any other app you sideloaded before.

### Google TV or Android TV: turn on wireless debugging

1. Open **Settings, System, About** and press **Build** (or **Android TV OS build**) seven times, until it says you are a developer.
2. Open **Settings, System, Developer options** and turn on **USB debugging** and **Wireless debugging**.
3. In Wireless debugging choose **Pair device with pairing code**. The TV shows a six-digit **code** and an address with a **pairing port**. Leave that screen open; you'll type them into JunctionBox in step 3. The code expires in a minute or two.

Pairing lets this computer install and open apps on the TV. You can take that permission back under Developer options, **Revoke wireless debugging authorizations**.

### Give each TV a fixed address

The launcher finds each TV by its IP address, so it must not change. In your router's settings, find "DHCP reservation", "address reservation" or "static lease", pick each TV from the list of connected devices, and reserve its current address. Do the same for the computer that runs JunctionBox, because the TV apps are built with that computer's address. If a TV or the computer ever changes address, update it in the plugin and press **Install** again on each TV.

## Step 2: Install the plugin

1. In JunctionBox, open **Settings, then Plugins**.
2. Choose **Browse for plugin ZIP** and pick `smart-tv-launcher.zip` (it's attached to each JunctionBox release).
3. Restart JunctionBox when asked. **Smart TV Launcher** appears in the sidebar.

## Step 3: Use the setup page

Open **Smart TV Launcher**. The page has six numbered cards.

### 1. Get each TV ready

The two sets of steps above, so you can keep this page open at the TV.

### 2. Start the bridge

Press **Set up the bridge**. The plugin does everything for you and shows its progress:

1. copies the bridge program to `~/.roku-launcher/runtime`,
2. builds a private Python environment for it (it never touches your system Python),
3. installs the libraries it needs (Pillow for pictures, pyte for the terminal screens),
4. registers it as a background service that starts when you log in (systemd on Linux, launchd on macOS), and starts it.

When the page shows **Running**, the bridge is up. It lists **optional parts**:

| Part | What it adds | Notes |
|---|---|---|
| Ring live view | Live video and audio from your Ring cameras on the TV | Large download. Needs ffmpeg. |
| Web Video (Roku) | A browser on your computer that you steer from the TV remote, with the video handed to the TV's own player | Needs Google Chrome or a downloaded browser. |
| ffmpeg | Re-streaming video | Install with your package manager. |
| pdftoppm | Reading Book Studio and Comic Studio PDFs | Install `poppler`. |

Install the ones you want. You can add them later. Anything missing is simply unavailable on the TV; the rest keeps working.

### 3. Your TVs

One list holds every TV, with a badge for its kind.

**To add a Roku:** press **Find Rokus on my network** (or choose **Roku** in **Add a TV** and type its address), enter the developer password, and press **Add TV**. The plugin checks that the Roku is reachable, that developer mode is on, and that the password is accepted.

**To add a Google TV:** choose **Google TV / Android TV** in **Add a TV**. If adb isn't ready, press **Get adb**. Enter the TV's address and a name, then the **pairing port and code** from the TV, and press **Pair and add**. Pairing happens once. After that the plugin finds the TV's debugging port by itself, even though that port changes every time the TV restarts its debugging. If this computer is already paired with the TV, leave the pairing boxes empty.

**Install:** press **Install** on a TV's row. The launcher is built for your installation (your computer's address and a private key are put into it) and sent to the TV, which opens it right away. **Install or update on all TVs** does every TV at once. After a JunctionBox update brings a newer launcher, each row shows **Update available**; press **Update**.

The key is a random token created on your computer, stored only in `~/.roku-launcher/token` (readable only by you) and inside the app on your TVs. The bridge ignores requests without it.

**Google TV: make it the Home screen.** When you like how the launcher looks on a Google TV, press **Make it the Home screen** on its row, so the Home button opens it. **Restore Google Home** puts things back at any time, and removing the TV can also delete the app and restore Google's Home screen. The plugin checks that the TV accepted the change. If a TV refuses (the newer Google TV home screen often can't be replaced), the launcher still works as an app you open from the app row.

### 4. Choose what the home screen shows

- **Weather location**: search for your town and press **Use**.
- **Apps on the home screen** (Roku): press **Pick from this TV's apps** to list the channels actually installed on a Roku, tick the ones you want as tiles, put them in order with the arrows, and press **Save apps**. Tile pictures come from the TV itself.
- **Apps on Google TV tiles**: the same, from a Google TV's installed apps. Tiles for apps that aren't installed on a particular TV are hidden on that TV.

Changes show up the next time the launcher opens on the TV.

### 5. Bibles to read on the TV

The launcher comes with seven public-domain Bibles: the King James Version, American Standard Version (1901), Douay-Rheims (with the deuterocanonical books), Catholic Public Domain Version, World English Bible, an **Ethiopian Bible in English** (with the extra books: Enoch, Jubilees, Meqabyan and others) and an **Amharic Bible** (አማርኛ). Tick the ones you want and press **Build**. Each becomes a PDF on this computer (about a minute or two each, 2,000 to 4,000 pages, 4 to 6 MB) and shows up in **Books** on every TV.

Reading a Bible on the TV:

- **Contents.** Press **OK** on Google TV, or **\*** on a Roku and choose *Contents*. Pick **Old Testament** or **New Testament** (Bibles that include extra books also have **Apocrypha and extra books**), then a book. The book opens at chapter 1.
- **Chapters.** In the same menu, *Chapters of this book* lists every chapter of the book you are in (on Google TV press **Menu**).
- **Study guides.** Many New Testament books open with a study guide (author, date, purpose, background, themes, key passages, structure and application) before chapter 1. In the chapter list it appears as **Study guide**, ahead of Chapter 1. It is laid out as its own pages: a title, the key facts, then each section under a gold heading with numbered lists, bullets and quotations, and no verse numbers.
- **Back** steps up one level. The TV remembers the page you were on for each Bible.

![The Contents menu: Old Testament or New Testament](images/roku/bible-contents.jpg)

![Choosing a chapter of the book you are in](images/roku/bible-chapters.jpg)

Comic Studio and Book Studio books get a chapter list too (comic books list the strips inside each chapter). The list is saved when a book is built, so books built before it existed show chapters after their next rebuild.

#### Adding your own Bibles

The launcher only turns texts into PDFs; it does not decide which texts you may use. For any other translation you are entitled to use, run the generator that ships with the launcher (`launcher/tools/make_bibles.py`; it needs `pip install reportlab`):

```
make_bibles.py --book ID "Title" "Subtitle" my_bible.json      # {"Genesis": {"1": [{"number": 1, "text": "..."}, ...]}, ...}
make_bibles.py --combined several.json                         # {"KJV": {...}, "ASV": {...}}
make_bibles.py --copy "Some Bible.pdf" some-id "Title" "Subtitle"   # a PDF you already have, used as it is
```

Output goes to the `bibles` folder inside the launcher's data folder (`~/.roku-launcher/bibles`) and appears in Books straight away. A PDF you copy in has no contents until you add a small `<id>.json` beside it: `{"title": ..., "subtitle": ..., "byline": ..., "toc": [{"n": "Genesis", "p": 12, "c": [[1, 12], [2, 14]]}, ...]}` where `n` is the book name, `p` its first page and `c` pairs of chapter and page. Books with a contents list get the Old Testament, New Testament, book and chapter menus; without one a Bible opens as a plain PDF. Pages are exact only when you give exact pages. Amharic and other Ethiopic text is supported (the launcher ships Noto Serif Ethiopic; for your own files pass a font with `--font-ethiopic`). A book can carry a study guide as its chapter `0`: the generator lays it out as described above from lines such as `--- STUDY GUIDE: Title ---`, `AUTHOR: ...`, `--- BACKGROUND ---`, `1. THEME (Chapters 1, 17): explanation`, `• bullet`, `'A quoted verse' (3:16)`. The book list must keep the Bible's order, with the New Testament starting at *Matthew*, so the Old Testament / New Testament buttons come out right.

### 6. Claude, Codex, Grok, box shells and screen share on the TV

Adds **Claude**, **Codex**, **Grok**, **Box Shells** and **Screen Share** tiles to the home screen of every TV (Screen Share is on the Roku; the Google TV version is not built yet). Each opens a terminal showing that coding agent running **on the JunctionBox computer**, in your home folder.

**Permissions.** Card 6 has a Permissions drop-down for each agent, so you decide how much it may do without asking. The default for all three is the agent's normal ask-first mode. A choice applies the next time that agent starts (a running session keeps its mode; use **End it** and open the tile again). Modes marked *dangerous* are flagged on the card.

| Agent | Modes |
|---|---|
| Claude | Ask before each action; Edit files freely, ask before commands; Plan only; Automatic; Never ask (allowed tools only); **Do everything, no permission checks** (`--dangerously-skip-permissions`) |
| Codex | Read-only; Edit the home folder, ask for anything else; Automatic review of requests; Work in the home folder without asking; **Do everything, no sandbox, no questions** (`--dangerously-bypass-approvals-and-sandbox`) |
| Grok | Ask before each action; Edit files freely, ask before commands; Plan only; Automatic; Never ask (allowed tools only); **Bypass all permission checks**; **Approve every action automatically** (`--always-approve`) |

In the ask-first modes the agent's questions appear on the TV; answer with the quick keys (1, 2, 3, y, n, Enter). Codex's startup update check is always off so pressing OK can't start an installer. The mode list lives in `launcher/bridge/terminal_modes.json`, and your choices in `term-modes.json` in the launcher's data folder.

**Box Shells** opens a shell on any box JunctionBox knows. Enter the PIN, pick a box from the list, and you get a terminal on it: an `ssh` session using that box's saved key (or its saved password when `sshpass` is installed), or a local shell for the computer JunctionBox runs on. Nothing is typed or stored on the TV; the keys never leave your computer. It works exactly like the agent terminals, with the same quick keys, plus **Back to the list of boxes** in the quick-key menu.

**Leaving it running.** Every terminal, agents and box shells alike, keeps running on your computer when you leave the screen. Close the app, come back later, enter the PIN, and you are in the same session (a box shows *(running)* in the list). **Leave (it keeps running)** in the quick-key menu exits the screen and signs the TV out; **End session** stops it. Card 6 lists running box shells with an **End it** button, and ending is the only thing that closes them (a Mac or Linux box's shell also ends if you type `exit`).

**Screen Share** shows a box's whole screen on the TV and lets you drive it with the remote. It is JunctionBox's own screen sharing (the same thing you open from the boxes page in the web app), viewed through the browser that Web Video uses, so it needs the **Web Video** part from card 2. Enter the PIN, pick a box, and the screen appears; the first time on a box JunctionBox may install its screen server, which can take a minute. Linux, macOS and Windows boxes work as they do in the web app, and the box needs someone logged in at its screen.

- **D-pad** moves the pointer, faster the longer you hold. **OK** clicks. **Rewind / Fast-forward** scroll. **Play** opens the TV's keyboard to type; typing on the Roku phone app's keyboard goes straight to the box.
- **\*** or **Back** opens the menu: right-click, double-click, pick up and drop (drag), **Zoom 2x or 3x** (the view follows the pointer, so small text is readable from the couch), jump the pointer to the middle or a corner, keys (Enter, Escape, Tab, arrows, Delete, Home, End, Page up and down, F5), shortcuts (copy, paste, select all, undo, save, find, Alt+Tab, Alt+F4, the Windows or Command key, Ctrl+Alt+Delete), back to the list of boxes, and **Stop sharing and leave**.
- Unlike a shell, a screen share **does not keep running** when you leave: it ends when you leave the screen, or a minute after the TV stops asking for pictures, and JunctionBox switches the box's screen server off again.
- The screen is redrawn a few times a second, which is fine for browsing and typing but not for video.

![Pick a box to share](images/roku/screen-share-list.jpg)

![A box's screen on the TV, with the pointer](images/roku/screen-share-desktop.jpg)

![The menu: click, drag, zoom, keys and shortcuts](images/roku/screen-share-menu.jpg)

![Zoomed to 2x so small text is readable](images/roku/screen-share-zoom.jpg)

Each agent and each box has its own session, so you can leave Codex working, have a shell open on two boxes, and open Claude. They keep running when you leave; close the app and come back to the same conversation. A tile whose command isn't installed says so when you open it. A box that is switched off or unreachable shows the ssh error on the screen. Card 6 shows which of the three were found.

Because it is a shell on that computer, it is **off until you set a PIN** (4 to 12 digits) on this card:

- The TV asks for the PIN each time you open the terminal. The bridge checks it (salted PBKDF2) and never stores it in the clear. Five wrong tries lock the terminal for five minutes.
- A TV that stops using the terminal is signed out after 15 minutes.
- **Turn off** removes the PIN and ends the session. **End running session** stops all running sessions without removing the PIN. One PIN covers all three agents.
- It needs a Mac or Linux bridge, at least one of the three commands on the computer, and the small `pyte` package, which "Update the bridge" installs.

On the TV: the D-pad sends the arrow keys, OK sends Enter, and Play opens the TV's keyboard to type a line. On Google TV a USB or Bluetooth keyboard types straight into the agent. Press `*` (or Menu, or Back) for a list of quick keys: Esc, Tab, Shift+Tab, Ctrl+C, 1, 2, 3, y, n, page up/down through what the agent has printed, Restart, End session, and Leave. Rewind and Fast-forward also scroll back. Both TVs show the agent's colours; the bridge draws the Roku's screen as a picture.

![The PIN prompt](images/roku/terminal-pin.jpg)

![Claude Code on the TV, answering a question about a project folder](images/roku/claude-answer.jpg)

![The quick keys menu](images/roku/terminal-quick-keys.jpg)

![Codex](images/roku/codex-answer.jpg)

![Grok](images/roku/grok-answer.jpg)

![Box Shells: pick a box, get a shell](images/roku/box-shells-list.jpg)

![A shell on a box](images/roku/box-shell.jpg)

The first time, Claude asks whether you trust the folder. (Codex and Grok go straight to their prompt; Grok also asks once whether to share coding data. That one is your choice.) The highlighted choice is **"No, exit"**, which closes Claude, so press **Down** first and then OK to choose "Yes, I trust this folder". If Claude does end, press OK (Enter on Google TV) on the terminal screen to start it again.

Only open this on a network you trust: anyone who knows the PIN and can reach the bridge gets the same access you have at that computer.

### How the two kinds differ

- **Home screen.** On a Roku, the bridge watches the TV and sends it back to the launcher when you leave an app (auto-return). On a Google TV the launcher is the Home screen itself, so the Home button comes back to it.
- **Screens.** The Roku launcher is a native Roku app. The Google TV launcher is a small Android app that shows pages served by the bridge, so those screens update without reinstalling anything. Both have the same screens: apps, weather, Home Control, Ring Security, Video Studio, Photos, Books, Box Status and Media Player, and the Watch List. **Web Video** is Roku-only, because Google TVs already have real browsers.
- **Building the Google TV app yourself.** The app's sources and a build script that needs only the Android command-line tools are in `launcher/android` (see For developers).

## Using the launcher on the TV

- **Home screen**: the top row of tiles are your apps. **Media Player** plays a video or audio URL. **Web Video** is described below. **JunctionBox** opens a row of hub tiles. **Settings** has the exit control.
- **Leaving an app** (Back or Home) returns you to the launcher. To really leave it, use **Settings, then Exit launcher**. Auto-return pauses so you can use the Roku's own Home and Settings, and resumes when you open the launcher again or turn the TV off and on.
- **JunctionBox hub**, depending on which plugins you have installed. On a Roku the tiles are shown a row of five at a time: press **Down** for the next row and **Up** to go back (a "Row 1 of 3" note at the top right shows where you are). The tiles are:
  - **Home Control**: lights, groups, colours, air conditioning, and a TV remote.
  - **Ring Security**: snapshots with battery levels and live view with audio.
  - **Video Studio**: play videos you generated. It remembers where you stopped and offers to resume (press `*` to start from the beginning). Left, Right, Rewind and Fast-forward scrub, going faster the more you press; OK confirms the jump.
  - **Photos**: your Stickers, Age Shift, Storyboard and Time Machine results. Hidden groups never appear, and password-protected groups show as locked with nothing inside.
  - **Books**: Comic Studio and Book Studio PDFs and your Bibles. Each remembers the page you were on, and has a contents and chapter list (see card 5).
  - **Claude, Codex and Grok**: a terminal for that coding agent on your computer. It asks for your PIN each time (see card 6).
  - **Box Status**: your JunctionBox machines.
- **Web Video**: browse a website on the TV. Arrow keys either **jump** between links or move a **pointer** (switch with `*`, then Mode). **OK** clicks, **Rewind and Fast-forward** scroll, **Back** goes to the previous page. When the page has a video, a green badge says **VIDEO FOUND**; press **Play** and it plays in the Roku's own player. Videos protected by copy protection (Netflix, Hulu, Disney+ and similar) can't play this way.
  - **YouTube links** open in the Roku's own YouTube app, because YouTube doesn't expose a single stream.
  - **Watch List**: the separate **Watch List** plugin lets you save video links in JunctionBox; they appear on Web Video's start page.

  ![The Web Video start page with your Watch List and bookmarks](images/roku/web-video-start.jpg)


## Updating and removing

- **Updating**: install a newer `smart-tv-launcher.zip`, restart JunctionBox, then on the Smart TV Launcher page press **Update the bridge** (if offered) and **Update** on each TV.
- **Removing a TV**: **Remove** on its row. You'll be asked whether to also delete the launcher app from the TV.
- **Removing everything**: remove the TVs, press **Stop** on the bridge, delete the plugin, and delete the folder `~/.roku-launcher`. On Linux also run `systemctl --user disable --now roku-launcher-bridge`; on macOS delete `~/Library/LaunchAgents/com.junctionbox.roku-launcher-bridge.plist`.

## Troubleshooting

| What you see | What to do |
|---|---|
| "Can't reach a Roku at that address" | Check the TV is on (not just standby), the address is right, and the computer and TV are on the same network. Some routers keep Wi-Fi devices on a separate "guest" network. |
| "Developer mode is off" | Redo the Roku steps in Step 1. After a factory reset, developer mode must be turned on again. |
| "The pairing code was wrong or has expired" | On the Google TV open **Pair device with pairing code** again for a fresh code and port, and type them in within a minute or two. |
| "Couldn't connect to the TV" (Google TV) | On the TV check Developer options, Wireless debugging is on. Turning it off and on again gives a new port, which the plugin finds by itself; if it still fails, pair again. |
| "The Roku rejected the developer password" | Use the webserver password from Step 1 (Roku). To change it, repeat Step 1 and choose a new one. |
| "Set up the bridge first" | Finish card 2 and wait for **Running**. |
| The TV app says it can't reach the bridge | The bridge must be running, and the TV must be able to reach this computer's address. If the computer has more than one network connection, open **Advanced** in card 4 and enter the address the TV should use, then press **Install** on each TV again. Also check that your computer's firewall allows incoming connections on the bridge's port (8791 by default). |
| Weather or tiles don't update | They refresh when the launcher opens. Check that the bridge is **Running**. |
| Ring or Home Control tiles say a secret isn't found | Set up that plugin (Ring Security or Home Control) in JunctionBox first, then reopen the tile. |
| Ring live view is missing | Install **Ring live view** and **ffmpeg** in card 2. |
| The launcher vanished from a TV after an update | The Roku refused the new app. The plugin shows the Roku's own message when you press **Install**; the bridge log (**Show log**) has more. |
| The TV keeps going back to the launcher | That's auto-return. Use **Settings, then Exit launcher** on the TV. |
| A box shell says the connection was refused or timed out | The box is off, asleep or on another network. Try it from this computer with `ssh` first. A box without a saved key or password asks for the password in the terminal itself. |
| Screen Share says it needs the Web Video part | Install **Web Video** in card 2 (it brings the browser Screen Share uses), then try again. |
| Screen Share says it couldn't find a graphical session | The box needs someone logged in at its desktop; JunctionBox can't share a box that is at a login screen with nobody signed in. The same message appears in the web app. |
| A terminal tile says the command was not found | Install that tool on the computer (Claude Code, Codex or Grok) and sign in to it there once. Card 6 shows which of the three were found. |
| "The terminal is off" | Set a terminal PIN on card 6. |
| "Wrong PIN" or "locked" | Five wrong tries lock all three terminals for five minutes. Wait, or set a new PIN on card 6. |
| "The terminal session timed out" | You were away for more than 15 minutes, or the bridge restarted. Open the tile again and enter the PIN. |
| A terminal ended straight away | Claude's first question about trusting the folder defaults to "No, exit". Open the tile again and press **Down** then **OK** to trust it. When an agent has ended, **OK** starts it again. |
| The Roku reads out every button | That is the Roku's Audio Guide, which pressing `*` four times in a row switches on. Turn it off in the Roku's Settings, Accessibility, Audio Guide. In the terminal press Back for the quick keys instead of `*`. |
| "Python 3.9 or newer ... is needed" | Install Python with `venv` support (see What you need), then press **Set up the bridge** again. |

The bridge's log is `~/.roku-launcher/bridge.log`; **Show log** displays the end of it.

## Privacy and safety

- The bridge listens on your home network only. Every request needs the private token; media links given to the TV are signed and short-lived.
- The Roku **developer password** is stored encrypted in the JunctionBox database. It's used only to install the launcher on your own TVs.
- The bridge reads your JunctionBox data folder read-only (photos, videos, books). It never writes to the JunctionBox database. For Home Control and Ring Security, JunctionBox hands the bridge each plugin's private secret in memory, over the local connection only, using a second token that never goes onto a TV.
- Anything your plugins mark as hidden stays hidden, and password-protected photo groups appear locked with nothing inside, on the TV too.
- The Claude, Codex and Grok terminals are a remote shell for the account that runs the bridge. They are off until you set a PIN, ask for it every time, lock after five wrong tries and sign out after 15 idle minutes; the PIN is stored only as a salted hash. Box shells reach every box you've added to JunctionBox with the credentials JunctionBox already holds for it, so a PIN holder has the same access to those boxes as you do from JunctionBox's own terminal. Each agent starts in the permission mode you chose on card 6, so a "do everything" mode means anyone with the PIN can act as you on that computer. Only use it on a network you trust.
- Don't expose the bridge's port to the internet.

## For developers

- The plugin source is `plugins/source/smart-tv-launcher/`: the plugin's own `backend/` and `frontend/`, plus `launcher/` with the Roku app (`launcher/app`, a SceneGraph/BrightScript app) and the bridge (`launcher/bridge`, Python standard library plus optional packages). `scripts/package-local-plugins.py` builds `plugins/packages/smart-tv-launcher.zip` from it.
- The app's source contains two placeholders, `__BRIDGE_URL__` and `__BRIDGE_TOKEN__`. The plugin fills them in when it builds the package for a TV, so neither the address nor the token is ever in the source or the zip. No third-party streaming logos are shipped: the bridge fetches each channel's icon from the TV that asks (`/tvicon/<id>`, cached for a week) and serves it to the launcher, because the Roku can't load pictures from its own control port.
- `launcher/android/` is the Google TV app (a small Java WebView shell). `build_apk.sh` builds `launcher.apk` with only the Android SDK command-line tools and a JDK, no Gradle. It signs with a key kept outside the repository (`~/.junctionbox/roku-launcher-android.keystore`): keep that key, because every update must be signed with the same one. `launcher/bridge/gtv/` holds the pages the app shows.
- `launcher/tools/make_assets.py` regenerates the artwork in `launcher/app/images` (needs Pillow).
- The terminals: `launcher/bridge/terminal.py` runs each agent or box shell in a pseudo-terminal (`pty`), keeps its screen and scrollback with `pyte`, and shares one PIN check and session key across agents. `launcher/bridge/terminal_modes.json` is the single list of each agent's permission modes (the page and the bridge both read it); the chosen modes are in `term-modes.json` and the PIN hash in `term-pin.json`, both in the data folder with mode 600. The Roku can't draw a monospace font from a Font node (it rendered nothing), so the bridge draws the screen as a PNG with Pillow and the bundled DejaVu Sans Mono (braille characters are drawn as dots) and the Roku shows it in two posters it swaps; the signed picture URL needs no header. Google TV draws the same screen as coloured text. `launcher/tools/make_term_tiles.py` draws the tiles.
- Bibles: `launcher/bridge/pdfbooks.py` renders PDF pages to pictures and reads the contents lists; `launcher/tools/make_bibles.py` builds the Bible PDFs and their contents from the bundled texts in `launcher/bibles` (seven `*.json.gz` plus `index.json`). Book Studio and Comic Studio write `<id>.toc.json` next to each book when it is built.
- Screenshots: the pictures in `docs/images/roku` are real screenshots of a Roku (the developer page's Screenshot tool gives a 1920x1080 picture of what the TV draws, and the Roku's remote-control port presses the buttons), taken with the demo data so nothing real appears. The tools, and how to run them, are in `launcher/tools/demo` (`README.md` there); `make_tv_mockups.py` makes the TV-framed and animated versions used on the website in `docs/images/roku/website`.
- Tests: `cd plugins/source/smart-tv-launcher && PYTHONPATH=../../../backend pytest backend/tests/` (85 tests).
- Screen share: `launcher/bridge/screenshare.py` opens JunctionBox's existing screen sharing in a headless browser (Playwright) on `launcher/bridge/novnc/viewer.html` (noVNC 1.7.0 served to the browser from disk, never over the network), takes a JPEG of it a few times a second, crops and zooms it with Pillow, draws the pointer, and turns the TV's keys into mouse and keyboard events (mouse through the browser, keys through noVNC's `sendKey`). The plugin starts the session with JunctionBox's own `screen_share.start_screen_share` (`POST /api/plugins/smart-tv-launcher/mcp/share/start/{box}`, loopback only, bridge-only token, same throttle) and hands the viewer a one-time login for the socket; the bridge revokes that login the moment the socket is open, and the plugin will only revoke logins it handed out. The same PIN and session key as the terminals guard it, and the share ends when the TV stops asking for pictures.
- Box shells: the bridge never holds JunctionBox's master key, so for a box it asks the plugin (`GET /api/plugins/smart-tv-launcher/mcp/box/{id}`, loopback only, bridge-only token, same throttle as the secret route; a TV's own token is refused). The plugin decrypts the box's credentials, writes a private temporary key file (mode 600 under `~/.junctionbox/keys`) and returns the `ssh` command; a password goes in the `SSHPASS` environment variable, never on a command line. The bridge deletes the key file when the shell ends and sweeps any left by a crash when it starts. The picker reads only the box id, name, host and platform from the database; the credential columns are never selected. They use a throwaway database and data folder, and a fake Roku developer page that checks the digest login and package upload, and never touch your real TVs.
- Roku BrightScript notes learned the hard way: never name things `left`, `step` or `next`; a one-line `if ... then A : B` runs `B` regardless, so use multi-line `if`; a dialog hands focus back to whatever had it before, so call `setFocus(true)` on your screen after closing one; custom `Font` nodes can render nothing on a real device; a Task node already has a `state` field; `setFocus(true)` on a parent does nothing while a hidden child list still holds focus, so give a screen a dedicated focus node.
