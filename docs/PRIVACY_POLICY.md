# JunctionBox — Privacy Policy

**Effective Date:** November 6, 2026
**Version:** 1.2

This Privacy Policy explains what information **JunctionBox AI** (**"Licensor," "we," "us,"** or **"our"**) collects in connection with JunctionBox (the **"Software"**), how it is used, and the choices available to the individual or entity using the Software (**"you"** or **"your"**). This Policy is incorporated into the JunctionBox End User License Agreement (**"EULA"**) by reference. Terms defined in the EULA have the same meaning here unless stated otherwise.

## 1. The short version

JunctionBox is designed to run locally, on hardware you control. Your agent conversations, run history, credentials, and configuration are stored in a local database on your own machine and are never transmitted to us.

The only information that reaches our servers is (a) what's necessary to operate the Free/Pro licensing system described in Section 2.1, and only if you activate a Pro license, and (b) the anonymous usage statistics described in Section 2.4 — a small daily message of counts, on by default, that you can see exactly and turn off at any time in Settings. Neither includes your conversations, files, or credentials.

Everything else the Software does — talking to an AI model provider, a local CLI tool, or any third-party service you configure (a plugin, an MCP server, a connected account) — is a direct connection between your machine and that third party, governed by that third party's own terms and privacy practices, not ours. We do not see that traffic.

## 2. Information we collect and why

### 2.1 License and billing information (Pro tier only)

If you activate JunctionBox Pro, the following is sent from your installation to our licensing service (operated by us, hosted on infrastructure described in Section 5) and stored there:

- The email address associated with your purchase (from Stripe, or the email you give us for a manually issued license).
- A randomly generated device identifier created by your installation — not derived from any hardware serial number, MAC address, or other identifier that could fingerprint your machine beyond this one random value.
- Your subscription status, tier, current billing period, and whether the subscription is set to renew or cancel — obtained from Stripe, never a raw payment card number.
- A Stripe customer ID and subscription ID, used to look up the above and to open the Stripe-hosted billing portal on request.
- Timestamps of activation, refresh, and deactivation events.

This information exists to let your installation prove its entitlement (via a cryptographically signed token your installation verifies itself) and to let you manage your own subscription. We use it for no other purpose, and do not use it for advertising, profiling, or any purpose unrelated to operating the licensing system.

A **Free-tier installation that never activates a license** still makes one outbound check per day once any license has ever been activated on that device, to keep the cached entitlement current; an install that has never activated anything makes no license-related network calls at all (it does send the anonymous usage statistics in Section 2.4 unless you turn them off).

### 2.2 Payment information

Payment is processed entirely by Stripe, Inc. We never receive, see, process, or store your full card number, CVC, or other sensitive payment details — that data goes directly from your browser to Stripe. We receive only what Stripe discloses to merchants in the ordinary course of processing a transaction (described in 2.1). Stripe's own privacy practices govern the payment step itself; see [stripe.com/privacy](https://stripe.com/privacy).

### 2.3 Support correspondence and bug reports

If you email us for support, billing help, or any other reason, we retain that correspondence (your email address and message content) for as long as reasonably needed to resolve the matter and maintain a support history.

**Bug reports.** You can send us a bug report from the Software (Report a problem). Nothing is sent unless you press Send. A report contains what you type (what happened, what you expected), an email address only if you choose to give one so we can reply, and a screenshot only if you attach one. You may also choose to include diagnostics: the JunctionBox version, your operating system, your plan, installed plugins, the number of agents and boxes you have, and recent warning and error messages from the Software. You can see the diagnostics before sending them. We remove your user name, home folder, email addresses, IP addresses, host names and anything that looks like a password or token from them, but automatic removal is not perfect, so please check them and your screenshot. We store each report and email it to us through Gmail (Google), our support mailbox (Section 5), and keep it for as long as it is needed to investigate and fix the problem and maintain a support history. We do not use bug reports for advertising or sell them.

### 2.4 Anonymous usage statistics (on by default; you can turn them off)

So that we can see how many people use JunctionBox and which features are used, the Software sends our licensing service one small message per day. It contains:

- A random **install ID** that your installation generates for itself. It is not your license, device ID, hardware ID, email address, or account, and it is not linked to them.
- The JunctionBox version, your operating-system family (Linux, macOS or Windows), your processor type, and your plan (Free, trial or Pro).
- How many days ago you installed, and the identifiers of the plugins you have installed.
- Counts: how many agents and boxes you have; how many agent runs, scheduled runs, new agents, new boxes and new schedules happened on a day; which plugins were used on a day; and how often certain TV-app features were used.
- Which first-time steps you have reached (for example "created an agent").

The message never contains your prompts, agent output, files or file paths, the names of your agents, boxes, TVs, books or contacts, host names, addresses you configured, credentials, or anything you type. The counter names that can be sent come from a fixed list in the Software; anything else is discarded before it is stored. Our server does not store the IP address a message arrives from.

You can see the exact message at any time in **Settings → Usage statistics**, and turn the statistics off there (or set the environment variable `JUNCTIONBOX_TELEMETRY=off`). When they are off the Software records and sends nothing, and any counts it had not yet sent are deleted. The first time you sign in, the Software tells you about this and offers the choice.

We keep the latest state reported by each install (while it keeps reporting) and daily totals. We use this only to understand usage and decide what to build and fix, not for advertising, and we do not sell it.

### 2.5 What we do not collect

We do not collect, and the Software does not transmit to us:

- Agent conversations, prompts, or model outputs.
- Files, credentials, API keys, or secrets you configure in the Software.
- Your IP address in connection with normal Software use, beyond what any server incidentally logs for operational/security purposes (Section 6) and is not tied to your identity beyond that.
- Anything beyond the anonymous counts in Section 2.4: there is no third-party analytics SDK, tracking pixel, session recording, or third-party advertising code in the Software, and no crash reports or error logs are sent unless you choose to send a report.

## 3. Third-party services you configure yourself

The Software can be configured to connect to services you choose — AI model providers (Anthropic, OpenAI, xAI, Ollama, or local CLI logins), MCP servers, plugins, and any account a plugin integrates with (for example, an email account, a smart-home account, or a brokerage account, depending which plugins you install and configure). Each of those is a direct connection from your machine to that third party, using credentials you supply and control. We do not operate, see traffic through, or receive data from those connections. Your use of each is governed by that third party's own terms and privacy policy — review them before connecting an account or service that matters to you.

The **Music** feature of the Smart TV Launcher plugin connects from your computer to public directories (Radio Browser and SomaFM for internet radio, Apple's podcast search and each podcast's own feed), to the music server you enter (for example Navidrome), and to the stations and podcast hosts you choose to play. Those requests come from your computer, with your IP address, and are governed by those services' own terms; we do not see them. Your music folders are read only on your computer, and the TV is given songs only through the bridge.

A plugin's backend code runs with the same privileges as the Software's own core (see the EULA's Section 9 on third-party Plugins). A plugin's privacy practices are the plugin author's responsibility, not ours, unless the plugin was authored and distributed by us.

## 4. Local data

Everything the Software stores locally — agent configurations, conversation history, run logs, saved threads, memory, credentials, and settings — lives in a SQLite database and related files on your own machine (by default under `~/.junctionbox/`), encrypted at rest where the Software documents it (see `DEPLOYMENT_SECURITY.md`). You control this data entirely: back it up, inspect it, or delete it at any time by removing that directory. We have no access to it and no copy of it.

## 5. Where licensing data is processed and stored

Licensing, billing, usage-statistics and bug-report data (Sections 2.1, 2.3 and 2.4) is processed by a service we operate, hosted on Fly.io (application hosting, United States) with its database hosted on Neon (PostgreSQL hosting, United States). Bug reports are also delivered to us by email through Gmail (Google, United States). JunctionBox is offered only in the United States, and this data is stored and processed there.

## 6. Security

Licensing data is transmitted over TLS. Entitlement is proven to your own installation using a signed token verified with public-key cryptography, not a password or API key, and we never store or transmit the private signing key outside our own licensing service. Administrative access to the licensing service is protected by a secret bearer token, not a shared account. No security measure is perfect, and we don't warrant that any system is immune from unauthorized access — see the EULA's Section 10 and Section 14 for the full disclaimer.

## 7. Data retention

We retain usage statistics as described in Section 2.4. We retain licensing and billing data for as long as your license is active, and for a reasonable period afterward for support, accounting, fraud-prevention, and legal-compliance purposes. You can ask us to delete your licensing record at any time (Section 8); we'll do so except where we're required to retain it (for example, financial records we must keep for tax purposes).

## 8. Your choices and rights

- **Deactivate a device** at any time from Settings → License, which immediately reverts that install to Free and stops it from being counted as an active device on your license.
- **Manage or cancel your subscription** at any time through the Stripe-hosted billing portal, linked from Settings → License.
- **Access, correct, or delete** the licensing/billing information we hold about you: email **junctionboxai@gmail.com**. We'll respond and act on legitimate requests within a reasonable time, consistent with our legal obligations (for example, we may need to retain billing records for tax purposes even after a deletion request).
- **Turn off the usage statistics** at any time in Settings → Usage statistics. Nothing in Section 2.1 applies unless you activate a Pro license, so with the statistics off a Free install does not contact us.

JunctionBox is offered only to customers in the United States. If you live in a state whose law gives you additional privacy rights (such as access, deletion, or correction), you can exercise them through the same email address above.

## 9. Children's privacy

The Software is not directed to, and we do not knowingly collect information from, children under 13 (or the relevant minimum age in your jurisdiction). If you believe a child has provided us information, contact us and we will delete it.

## 10. Changes to this Policy

We may update this Policy as the Software or our practices change. Material changes will be presented the same way the EULA describes for its own changes — through the Software, our website, or the email address associated with your license. Continued use after a non-material update constitutes acceptance; where we're required to, we'll ask for affirmative acceptance of a material change before you continue using an affected release.

## 11. Contact

Questions about this Policy, or requests concerning your information:

**JunctionBox AI**
Email: **junctionboxai@gmail.com**

## 12. Governing law

This Policy is governed by the laws of the State of Mississippi, consistent with the EULA's Section 20, without regard to conflict-of-law rules.
