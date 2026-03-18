import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  experimental: {
    serverActions: {
      bodySizeLimit: "2mb",
    },
  },
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "*.supabase.co",
      },
    ],
  },
  // Keep legal redirects and crawler assets available on the production domain.
  async redirects() {
    return [
      {
        source: "/business",
        destination: "https://legal.routevia.tabserve.com.tr/business",
        permanent: true,
      },
      {
        source: "/privacy",
        destination: "https://legal.routevia.tabserve.com.tr/privacy",
        permanent: true,
      },
      {
        source: "/terms",
        destination: "https://legal.routevia.tabserve.com.tr/terms",
        permanent: true,
      },
      {
        source: "/ads",
        destination: "https://legal.routevia.tabserve.com.tr/ads",
        permanent: true,
      },
      {
        source: "/community",
        destination: "https://legal.routevia.tabserve.com.tr/community",
        permanent: true,
      },
      {
        source: "/account-deletion",
        destination: "https://legal.routevia.tabserve.com.tr/account-deletion",
        permanent: true,
      },
    ];
  },
};

export default nextConfig;
