# JunctionBox — Privacy Policy

**Effective Date:** October 13, 2026
**Version:** 1.0

This Privacy Policy explains what information **JunctionBox AI** (**"Licensor," "we," "us,"** or **"our"**) collects in connection with JunctionBox (the **"Software"**), how it is used, and the choices available to the individual or entity using the Software (**"you"** or **"your"**). This Policy is incorporated into the JunctionBox End User License Agreement (**"EULA"**) by reference. Terms defined in the EULA have the same meaning here unless stated otherwise.

## 1. The short version

JunctionBox is designed to run locally, on hardware you control. Your agent conversations, run history, credentials, and configuration are stored in a local database on your own machine and are never transmitted to us.

The only information that reaches our servers is what's necessary to operate the Free/Pro licensing system described in Section 2 below — and only if you activate a Pro license. A Free-tier install that never activates a license never contacts us at all beyond the automatic daily check described there.

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

A **Free-tier installation that never activates a license** still makes one outbound check per day once any license has ever been activated on that device, to keep the cached entitlement current; an install that has never activated anything makes no license-related network calls at all.

### 2.2 Payment information

Payment is processed entirely by Stripe, Inc. We never receive, see, process, or store your full card number, CVC, or other sensitive payment details — that data goes directly from your browser to Stripe. We receive only what Stripe discloses to merchants in the ordinary course of processing a transaction (described in 2.1). Stripe's own privacy practices govern the payment step itself; see [stripe.com/privacy](https://stripe.com/privacy).

### 2.3 Support correspondence

If you email us for support, billing help, or any other reason, we retain that correspondence (your email address and message content) for as long as reasonably needed to resolve the matter and maintain a support history.

### 2.4 What we do not collect

We do not collect, and the Software does not transmit to us:

- Agent conversations, prompts, or model outputs.
- Files, credentials, API keys, or secrets you configure in the Software.
- Your IP address in connection with normal Software use, beyond what any server incidentally logs for operational/security purposes (Section 6) and is not tied to your identity beyond that.
- Analytics, usage telemetry, crash reports, or any behavioral tracking. There is no analytics SDK, tracking pixel, or third-party advertising code in the Software.
- Anything from a Free-tier installation that has never activated a Pro license.

## 3. Third-party services you configure yourself

The Software can be configured to connect to services you choose — AI model providers (Anthropic, OpenAI, xAI, Ollama, or local CLI logins), MCP servers, plugins, and any account a plugin integrates with (for example, an email account, a smart-home account, or a brokerage account, depending which plugins you install and configure). Each of those is a direct connection from your machine to that third party, using credentials you supply and control. We do not operate, see traffic through, or receive data from those connections. Your use of each is governed by that third party's own terms and privacy policy — review them before connecting an account or service that matters to you.

A plugin's backend code runs with the same privileges as the Software's own core (see the EULA's Section 9 on third-party Plugins). A plugin's privacy practices are the plugin author's responsibility, not ours, unless the plugin was authored and distributed by us.

## 4. Local data

Everything the Software stores locally — agent configurations, conversation history, run logs, saved threads, memory, credentials, and settings — lives in a SQLite database and related files on your own machine (by default under `~/.junctionbox/`), encrypted at rest where the Software documents it (see `DEPLOYMENT_SECURITY.md`). You control this data entirely: back it up, inspect it, or delete it at any time by removing that directory. We have no access to it and no copy of it.

## 5. Where licensing data is processed and stored

Licensing and billing data (Section 2.1) is processed by a service we operate, hosted on Fly.io (application hosting, United States) with its database hosted on Neon (PostgreSQL hosting, United States). If you are located outside the United States, activating JunctionBox Pro means this limited data is transferred to and processed in the United States.

## 6. Security

Licensing data is transmitted over TLS. Entitlement is proven to your own installation using a signed token verified with public-key cryptography, not a password or API key, and we never store or transmit the private signing key outside our own licensing service. Administrative access to the licensing service is protected by a secret bearer token, not a shared account. No security measure is perfect, and we don't warrant that any system is immune from unauthorized access — see the EULA's Section 10 and Section 14 for the full disclaimer.

## 7. Data retention

We retain licensing and billing data for as long as your license is active, and for a reasonable period afterward for support, accounting, fraud-prevention, and legal-compliance purposes. You can ask us to delete your licensing record at any time (Section 8); we'll do so except where we're required to retain it (for example, financial records we must keep for tax purposes).

## 8. Your choices and rights

- **Deactivate a device** at any time from Settings → License, which immediately reverts that install to Free and stops it from being counted as an active device on your license.
- **Manage or cancel your subscription** at any time through the Stripe-hosted billing portal, linked from Settings → License.
- **Access, correct, or delete** the licensing/billing information we hold about you: email **junctionboxai@gmail.com**. We'll respond and act on legitimate requests within a reasonable time, consistent with our legal obligations (for example, we may need to retain billing records for tax purposes even after a deletion request).
- **Use the Free tier without ever contacting us**: nothing in Section 2.1 applies unless you activate a Pro license.

If you are located in the European Economic Area, the United Kingdom, California, or another jurisdiction with its own data-protection law, you may have additional rights under that law (such as data portability or the right to object to processing); the mechanism to exercise them is the same email address above.

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
