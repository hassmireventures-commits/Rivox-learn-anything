/// B13 optional encrypted cloud backup/restore — Phase 1 (auth + opt-in
/// plumbing only, see the approved implementation plan). Ships dark: stays
/// `false` until deliberately flipped on for internal testing, and again
/// until Phase 2 (backup) + Phase 3 (restore) actually land.
const bool kCloudBackupEnabled = false;
