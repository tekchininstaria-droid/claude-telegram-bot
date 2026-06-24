---
name: journal
description: Append a dated journal entry to the vault. Use when I reflect on my day, share how something went, or say "journal this", "log today", "add to my journal".
allowed-tools: Read, Write, Edit, Bash(date:*)
---

# Journal entry

1. Get the date: run `date "+%Y-%m-%d"` (and `%Y-%m` for the filename).
2. Open or create `Journal/YYYY-MM.md`.
3. Add a `## YYYY-MM-DD` heading at the **top** of the file (newest first); if
   today's heading already exists, append under it.
4. Write the entry in my voice — concise, first person.
5. If the entry reveals something durable (a goal, a preference, a decision),
   also update the relevant `Me/` note.

Confirm in one line.
