# Status

Current spec: `spec_02_method_list.md`.

Status: fixed method list and result table initialized; implementation has not started.

Evidence written:

- `source_discovery.md`
- `method_list.md`
- `method_results.csv`

Checkpoint evidence after Spec 01:

```text
git status --short
 M install.sh
 M scripts/install_skill.sh
 M scripts/uninstall_skill.sh
 M tests/test_install_skill.sh
?? external_skills/
?? remote_transcript_skill_report/
?? temp.md
?? temp/

git log -1 --oneline
ef805d0 Add speed-frame source discovery evidence

git show --stat --oneline --name-status HEAD
ef805d0 Add speed-frame source discovery evidence
A	workflow_speed_frame_detector/source_discovery.md
A	workflow_speed_frame_detector/status.md
```

Spec 03 start requirement:

- Start with M01.
- Implement only M01 before any later method.
