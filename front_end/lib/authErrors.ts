export function getAuthErrorMessage(code: string | null): string {
  switch (code) {
    case "email_exists":
      return "An account with this email already exists. Log in with your email and password instead.";
    case "account_not_found":
      return "No account found with this profile. Please create an account first.";
    case "oauth_cancelled":
      return "Sign-in was cancelled.";
    case "oauth_state_invalid":
      return "Your sign-in session expired. Please try again.";
    case "provider_error":
      return "We couldn't reach GitHub/Google. Please try again in a moment.";
    case "email_unverified":
      return "Your third-party email is not verified. Please verify it before signing in.";
    case "not_configured":
      return "Third-party authentication is not configured yet.";
    case "oauth_failed":
      return "Third-party sign-in failed. Please try again.";
    default:
      return code ? "An authentication error occurred. Please try again." : "";
  }
}
