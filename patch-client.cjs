// Kimi access tokens live 15 minutes. Refresh them with the refresh_token the site keeps.
const fs = require('fs');
let s = fs.readFileSync('upstream/kimi2api/client.py', 'utf8');
if (s.includes('ANVIL_REFRESH')) { console.log('client already patched'); process.exit(0); }
const anchor = 'KIMI_RESEARCH_USAGE_PATH = "/api/chat/research/usage"';
if (!s.includes(anchor)) throw new Error('client.py changed: usage path not found');
s = s.replace(anchor, anchor + '\nKIMI_REFRESH_PATH = "/api/auth/token/refresh"');
s = s.replace('        self._kimi_token = token', '        self._kimi_token = token\n        self._refresh_token = os.getenv("KIMI_REFRESH_TOKEN") or None\n        self._access_exp = float((parse_jwt(token) or {}).get("exp") or 0)');
const method = `    async def _token(self) -> str:
        # ANVIL_REFRESH: renew shortly before expiry, and after a 401 handled below.
        if self._refresh_token and self._access_exp and time.time() > self._access_exp - 90:
            try:
                response = await self._client.get(
                    f"{self._base_url}{KIMI_REFRESH_PATH}",
                    headers=self._get_headers(self._refresh_token),
                )
                if response.status_code == 200:
                    new = response.json().get("access_token")
                    if new:
                        self._kimi_token = new
                        self._access_exp = float((parse_jwt(new) or {}).get("exp") or 0)
            except Exception:
                pass
        return self._kimi_token

`;
if (!s.includes('    def _get_headers(')) throw new Error('client.py changed: headers method missing');
s = s.replace('    def _get_headers(', method + '    def _get_headers(');
s = s.split('_get_headers(self._kimi_token)').join('_get_headers(await self._token())');
fs.writeFileSync('upstream/kimi2api/client.py', s);
console.log('client patched for token refresh');
