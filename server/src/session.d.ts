import "express-session";

declare module "express-session" {
  interface SessionData {
    userId: string;
    oauth?: {
      provider: "github" | "google";
      state: string;
      verifier: string;
      remember: boolean;
      language?: string;
      from: "login" | "register";
    };
  }
}
