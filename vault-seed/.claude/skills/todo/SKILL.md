---
name: todo
description: Add, complete, or review tasks in the vault's Tasks.md. Use when I say "add a task", "todo", "remind me to", "what's on my plate", or mention something I need to do.
allowed-tools: Read, Write, Edit, Bash(date:*)
---

# Manage tasks

Tasks live in `Tasks.md` as checkboxes under sections: Inbox, Today, Soon, Someday, Done.

- **Add:** put a new `- [ ] task` under the right section (default Inbox). Include a
  due date in parentheses if I gave one. Confirm briefly.
- **Complete:** change `- [ ]` to `- [x]` and move it to Done.
- **Review ("what's on my plate"):** summarize Today + Soon concisely; surface
  anything overdue. Check the date first with `date`.

Keep the list tidy — collapse duplicates, move stale Inbox items to the right place.
