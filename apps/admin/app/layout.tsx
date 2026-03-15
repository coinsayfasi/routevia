import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Routevia Admin",
  description: "Routevia moderation and editorial operations panel",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="tr">
      <body className="min-h-screen font-sans antialiased">{children}</body>
    </html>
  );
}
