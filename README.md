# App Privacy

Vue/Vite static site for App privacy policies.

Add a new app by editing `public/apps.json`.

Example:

```json
{
  "appleId": "6798079191",
  "appName": {
    "zh": "中文 App 名",
    "en": "English App Name",
    "ja": "日本語 App Name",
    "ko": "한국어 App Name",
    "es": "Nombre de la app",
    "pt": "Nome do app",
    "de": "Deutscher App-Name",
    "fr": "Nom de l'app"
  },
  "lastUpdated": "2026-05-30"
}
```

The page uses fixed privacy-policy templates for each language and replaces the app name and update date from `apps.json`.

Routes:

- `/{appleId}/zh`
- `/{appleId}/en`
- `/{appleId}/ja`
- `/{appleId}/ko`
- `/{appleId}/es`
- `/{appleId}/pt`
- `/{appleId}/de`
- `/{appleId}/fr`

Cloudflare Pages:

Cloudflare Workers:

- Build command: `npm run build`
- Assets directory: `dist`
- Deploy command: `npm run deploy`
