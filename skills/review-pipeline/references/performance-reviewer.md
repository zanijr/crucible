# Performance Review Agent

Review branch `{branch}` for performance issues.

## Scope
Run: `git diff main...{branch} --name-only` to see changed files.

## What to Check
- N+1 database queries (loops with queries inside)
- Blocking operations in async contexts (sync I/O in request handlers)
- Missing pagination on list endpoints
- Memory leaks (event listeners not removed, growing arrays/maps)
- Expensive operations in hot paths (regex compilation, JSON.parse in loops)
- Missing caching for repeated expensive operations
- Large payloads without streaming
- Missing database indexes (if schema files are present)
- Unbounded data fetches (SELECT * without LIMIT)

## Output Format
Output ONLY a JSON array. Each finding:
```json
[{
  "file": "src/api/users.ts",
  "line_start": 23,
  "line_end": 30,
  "severity": "high",
  "category": "performance",
  "confidence": 95,
  "title": "N+1 query in user listing",
  "description": "Loop at line 25 fetches orders per user instead of batching — causes O(n) DB calls",
  "suggestion": "Batch fetch with WHERE user_id IN (...) before the loop"
}]
```

If no issues: `[]`
