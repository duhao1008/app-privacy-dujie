export type Locale = 'zh' | 'en' | 'ja' | 'ko' | 'es' | 'pt' | 'de' | 'fr'

export const locales: Locale[] = ['zh', 'en', 'ja', 'ko', 'es', 'pt', 'de', 'fr']

export const localeLabels: Record<Locale, string> = {
  zh: '中文',
  en: 'English',
  ja: '日本語',
  ko: '한국어',
  es: 'Español',
  pt: 'Português',
  de: 'Deutsch',
  fr: 'Français',
}

export interface LocalizedText {
  zh: string
  en: string
  ja: string
  ko: string
  es?: string
  pt?: string
  de?: string
  fr?: string
}

export interface PrivacyApp {
  appleId: string
  appName: LocalizedText
  lastUpdated: string
  contactEmail?: string
}

export interface AppsJson {
  apps: PrivacyApp[]
}

export const defaultContactEmail = 'duhao1008@126.com'

export const fallbackPrivacyApps: PrivacyApp[] = [
  {
    appleId: '6774123126',
    appName: {
      zh: '压降计算',
      en: 'Cable Drop Calc',
      ja: 'Cable Drop Calc',
      ko: 'Cable Drop Calc',
      es: 'Cable Drop Calc',
      pt: 'Cable Drop Calc',
      de: 'Cable Drop Calc',
      fr: 'Cable Drop Calc',
    },
    lastUpdated: '2026-05-30',
  }
]

export async function loadPrivacyApps(): Promise<PrivacyApp[]> {
  try {
    const response = await fetch('/apps.json', { cache: 'no-cache' })
    if (!response.ok) {
      return fallbackPrivacyApps
    }
    const data = (await response.json()) as AppsJson
    if (!Array.isArray(data.apps)) {
      return fallbackPrivacyApps
    }
    return data.apps.filter(isPrivacyApp)
  } catch {
    return fallbackPrivacyApps
  }
}

function isPrivacyApp(value: unknown): value is PrivacyApp {
  if (!value || typeof value !== 'object') {
    return false
  }
  const app = value as PrivacyApp
  return Boolean(
    app.appleId &&
      app.appName?.zh &&
      app.appName?.en &&
      app.appName?.ja &&
      app.appName?.ko &&
      app.lastUpdated,
  )
}

export function getLocalizedAppName(app: PrivacyApp, locale: Locale) {
  return app.appName[locale] || app.appName.en || app.appName.zh
}

export function findPrivacyApp(apps: PrivacyApp[], appleId: string) {
  const normalized = appleId.replace(/\.html$/i, '')
  return apps.find((app) => app.appleId === normalized)
}
