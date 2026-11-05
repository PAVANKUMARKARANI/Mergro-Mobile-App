/// Disables Riverpod's automatic retry for a provider (`retry:`).
///
/// Data screens show a failed load at once with a Retry button; silent
/// retries would hide errors such as a not-found lead for ~30 s.
Duration? noAutomaticRetry(int retryCount, Object error) => null;
