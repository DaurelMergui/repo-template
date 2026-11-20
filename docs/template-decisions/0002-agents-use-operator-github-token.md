---
status: accepted
---
# Agents authenticate to GitHub with the operator's own gh token

We chose one personal token over per-agent machine users or a GitHub App: one secret, no org needed. Cost: every agent commit and PR appears as the operator, so attribution comes from commit trailers and PR labels, not identity. Revisit when a second agent needs write access.
