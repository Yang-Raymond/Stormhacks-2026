import type { NextConfig } from "next";

const apiUrl = process.env.API_URL ?? "http://localhost:4000";

const nextConfig: NextConfig = {
  // Problem generation calls Gemini and can take well over the 30s default.
  experimental: { proxyTimeout: 120_000 },
  // Proxy API calls so the session cookie is same-origin.
  async rewrites() {
    return [{ source: "/api/:path*", destination: `${apiUrl}/api/:path*` }];
  },
};

export default nextConfig;
