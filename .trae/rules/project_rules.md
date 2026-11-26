# Project rules

- All code changes go through OpenSpec. If I ask for a change without an
  active change folder, propose one with /opsx-propose first. Do not edit
  Swift files outside /opsx-apply.
- Before apply, the change artifacts must be approved by me. Do not start
  implementing during propose.
- Only touch files listed in the change's design.md. Unrelated refactoring
  needs my approval.
- Do not modify passing tests to make them pass. If a test looks wrong,
  stop and tell me.
- Never claim tests pass without showing the xcodebuild test output.
- After 3 failed fix attempts on the same failure, stop and summarize instead
  of retrying.
- When a task concerns UI, open the matching screenshot in
  reference/screenshots/ by its state ID.
- After each archived change, append to docs/ai-log.md: change name, what you
  generated, what I corrected, test results.
- Run tests with exactly: `xcodebuild test -project "CamCard Copy.xcodeproj" -scheme "CamCard Copy" -destination "platform=iOS Simulator,name=iPhone 17" -collect-test-diagnostics never -parallel-testing-worker-count 3`
  (`-collect-test-diagnostics never` skips the up-to-10-minute sysdiagnose
  xcodebuild otherwise collects after any failure. Add it to every
  xcodebuild test / test-without-building invocation, including targeted
  `-only-testing` runs.)
  (`-parallel-testing-worker-count 3` caps the parallel simulator clones; with
  five, clone start-up overloaded the Mac and test runners timed out with
  "Timed out waiting for AX loaded notification". Approved 2026-11-26.)
