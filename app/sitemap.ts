import type { MetadataRoute } from 'next';
export default function sitemap(): MetadataRoute.Sitemap {
  const base = process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000';
  const publicRoutes = ['','/about','/how-it-works','/learn','/professionals','/family','/crisis','/downloads','/pricing','/privacy','/terms','/login','/signup'];
  return publicRoutes.map(path => ({ url: `${base}${path}`, lastModified: new Date(), changeFrequency: 'weekly', priority: path === '' ? 1 : 0.6 }));
}
