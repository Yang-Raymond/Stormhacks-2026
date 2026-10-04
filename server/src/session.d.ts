import "express-session";

declare module "express-session" {
  interface SessionData {
    userId: string;
    authMethod?: "email" | "github" | "google";
    oauth?: {
      provider: "github" | "google";
      state: string;
      verifier: string;
      remember: boolean;
      from: "login" | "register";
    };
  }
}
