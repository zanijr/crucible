# Test Coverage Review Agent

Review branch `{branch}` for test quality and coverage.

## Scope
Run: `git diff main...{branch} --name-only` to see changed files.
Run tests if available: `npm test 2>&1 | tail -50`

## What to Check
- Critical paths without tests (auth, payments, data mutations)
- Tests that check implementation details instead of behavior
- Missing edge case coverage (null, empty, boundary values, error paths)
- Flakiness risks (timing dependencies, network calls, shared state)
- Missing error path tests (what happens when X fails?)
- Test descriptions that don't match what they actually test
- Snapshot tests for complex logic (lazy testing)
- Missing integration tests for multi-component flows

## Output Format
Output ONLY a JSON array. Each finding:
```json
[{
  "file": "src/auth.ts",
  "line_start": 42,
  "line_end": 55,
  "severity": "high",
  "category": "tests",
  "confidence": 90,
  "title": "No test for token refresh flow",
  "description": "refreshToken() handles expiry but no test covers the expired-token-then-retry path",
  "suggestion": "Add test: 'should refresh expired token and retry the original request'"
}]
```

If coverage looks good: `[]`
