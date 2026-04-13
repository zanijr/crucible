# Crucible Label Schema

## Task Status Labels

| Label | Color | Description |
|-------|-------|-------------|
| `crucible:todo` | `#0e8a16` (green) | Ready for an agent |
| `crucible:in-progress` | `#fbca04` (yellow) | Agent working on it |
| `crucible:blocked` | `#d93f0b` (red-orange) | Waiting on dependency |
| `crucible:review` | `#1d76db` (blue) | Code complete, needs review |
| `crucible:done` | `#6f42c1` (purple) | Merged and closed |
| `crucible:critical` | `#b60205` (red) | Review found critical issue |

## Priority Labels

| Label | Color | Description |
|-------|-------|-------------|
| `priority:p0` | `#b60205` (red) | Do first |
| `priority:p1` | `#d93f0b` (red-orange) | Do soon |
| `priority:p2` | `#fbca04` (yellow) | Do eventually |

## Label Transitions

```
crucible:todo → crucible:in-progress → crucible:review → crucible:done
                        ↓                                      ↑
                 crucible:blocked ─────────────────────────────┘
```

When a task fails review and needs fixes:
```
crucible:review → crucible:critical → crucible:in-progress → crucible:review
```
