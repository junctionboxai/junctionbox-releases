# Local AI: models on your own hardware

JunctionBox can find free AI models your computers can run, install them, measure what they can really do, and turn them into agents, on this computer or on your other machines. Nothing here costs money and nothing needs an account. Once a model is installed it works with no internet.

Open **Models > Local AI** in the sidebar. This page explains each part. Everything described here is optional and off until you use it.

## 1. Find models that fit your computer

Press **Find My Local AI**. JunctionBox reads your processor, memory, graphics card and free disk space. It does not guess: if it can't measure something (for example the memory of some graphics cards), it says so.

The result is a short list of recommended models: the best overall, the best for coding, the one that uses the least memory, and (on computers without a graphics card) the best for the processor. Each card says how much memory it needs, whether it fits comfortably or tightly, whether it will use the graphics card or the processor, and how big the download is.

The list is curated and only includes models under permissive licenses (Apache-2.0 or MIT). Each entry records the exact version JunctionBox tested, and after an install JunctionBox checks what Ollama downloaded against it.

## 2. Install, test, benchmark

- **Install** downloads the model through Ollama (the free program that runs them). You see progress, can cancel, and can resume later. If Ollama isn't installed or is too old for a model, JunctionBox shows you the exact steps and asks before it changes anything.
- **Test** runs one short question and measures it: how fast the model answers and whether it really ran on the graphics card or the processor. That measurement is more reliable than the estimate.
- **Benchmark** runs 53 short, automatically graded tasks on your computer (a few minutes): chat questions, writing and fixing small bits of code, JSON output, choosing tools, respecting permissions, remembering a conversation. For each kind of work it shows whether the model is recommended, with the scores. Code the model writes runs in a locked-down sandbox with no network and no access to your files (on Linux). The tasks are simple, so a pass means "can handle basic work", not "can do hard problems".

## 3. Make an agent

**Create agent** gives you an agent that uses the model, with restricted permissions: it can chat and use read-only tools, and gets no write or shell access unless you give it. **Coding assistant** creates a cautious, read-only agent for small coding tasks; it suggests changes as a diff, and **Review a patch** checks the diff against a folder, refuses unsafe paths, and only applies it after you approve the exact list of files (with a backup and an undo).

Local agents count as agents like any other: the Free plan allows 2 active agents, and Pro is unlimited. There is no separate charge for local AI.

## 4. What small models are good (and bad) at

Small models are good at everyday chat, short summaries, rewriting, simple questions and small bits of code. They make mistakes a large model wouldn't, are unreliable at long multi-step work, and tool use is hit and miss. Check any code before you run it. For serious coding or research use a stronger agent such as Claude or Codex. Each model card lists what it is good and bad at, and what the benchmark measured on your computer.

## 5. Guarded tool use: make small models dependable with tools

Small models often fail at tools in boring ways: they write the tool call as text instead of making it, call a tool they shouldn't, or invent a value (an email address nobody gave them). **Guarded tool use** is a per-agent switch (Agents > edit > Guarded tool use) that fixes those failures in code:

- each turn the model's answer is forced into a valid tool call or a plain reply, and can only name tools that agent is already allowed to use;
- the arguments are checked against the tool's own definition, and a bad call gets one retry with the error shown;
- a value that isn't in your request or a tool's result is checked, and if the model made it up, the agent asks you instead;
- a plain question, summary or piece of code gets a direct answer, without a pointless tool call.

It is **off by default**, and **on for agents created from the Local AI page**. It helps small and weak models most. A strong model gains little from it. The costs: replies appear all at once instead of streaming, and a turn can take a second model call. Measured on this project's own benchmark, two small models went from failing tool use to passing it (see **Test with guardrails** on an installed model, which measures a model both ways and keeps the results separate).

Guardrails make a small model safe and well-formed. They don't make it good at planning a long task.

## 6. Smart routing

With routing on, an agent can hand a task to the cheapest agent that has earned it instead of always using the strongest. You choose, per kind of task (classify, summarize, chat, structured JSON, light coding, tool tasks, complex coding, deep research), an ordered list of agents. JunctionBox follows your list with fixed rules, no model deciding: an agent is skipped if it's inactive, not installed, too big for the memory free right now, or hasn't *passed the benchmark* for what the task needs (you can allow un-benchmarked models). The **Why?** button shows every reason.

If the chosen agent fails (timeout, out of memory, error, empty answer, or invalid JSON when JSON was required), the next one in your list runs. Cloud agents are never reached silently: with "ask", a cloud step waits for your approval of that exact task, once; "never" excludes them; only "allow" lets one run without asking. Routing never changes an agent's permissions. Agents call it through the `route_task` tool. The log keeps which agent ran and how long, never the task text or the answer.

## 7. Other computers (Boxes)

Under **Other computers (Boxes)** every Box you have registered appears (Linux and macOS). Press **Scan** and JunctionBox looks at that computer's hardware over SSH, shows what it can run, and lets you do everything above there:

- see its live memory, load and the models loaded right now;
- start, install or update Ollama on it (you see the exact command first and confirm; on a Mac you install Ollama yourself, JunctionBox can start it);
- install, test, benchmark, unload and remove models on that Box, with the Box's own speed and its own benchmark results;
- create an agent whose model runs on the Box; routing and local-only mode understand it.

**Nothing on the Box is opened to the network.** JunctionBox reaches the Box's Ollama through an SSH connection that listens only on this computer. If a Box's Ollama is itself listening on the whole network, the card warns you. Models are only installed from the catalog, and removing a model only deletes ones JunctionBox itself installed. The connection closes after 30 quiet minutes, and never while a model is loaded there.

Windows Boxes aren't supported for Local AI yet. The first connection to a Box takes about a second.

## 8. Privacy and control

- **Local-only mode** (Advanced): an agent that would use a cloud service (Anthropic, OpenAI, xAI, the Claude, Codex or Grok command line tools, or an Ollama cloud model) refuses to run and tells you why, instead of sending anything out. Local models and your Boxes keep working. It governs where the *model* runs: web search and other tools still follow each agent's own permissions.
- Choose the preferred runtime (automatic, graphics card, processor), the context length, and how many minutes an idle model stays loaded.
- **Uninstall** deletes a model JunctionBox installed. A model you already had in Ollama is never deleted from here, only forgotten.

## 9. BitNet, for computers with no graphics card

On Linux, Local AI can also offer Microsoft's BitNet model, built to run on an ordinary processor. It is built on your computer the first time (10 to 20 minutes, about 2.5 GB, and it needs the clang and cmake build tools, which JunctionBox can install after showing you the commands). It runs in its own folder at a lower priority, starts when an agent needs it and stops when idle. It is a small general-purpose model: JunctionBox doesn't recommend it for coding, and its tool use failed the benchmark. BitNet is not offered for Boxes.

## What has been tested

Everything has automated tests, and the Linux paths were also run on real hardware: an Intel Core i3 laptop (installs, tests, benchmarks, BitNet build, guarded tool use through a real agent run), and a Linux desktop (Intel i7, 63 GB) and a Mac (Apple M1 Pro) as Boxes. Not yet tested on real hardware: NVIDIA, AMD or Apple graphics for the model recommendations, Windows, a Windows Box, and the largest models. The details and the measured numbers are in the technical notes in the source repository (`docs/LOCAL_AI_MANAGER.md`).
