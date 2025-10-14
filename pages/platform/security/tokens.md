# Token security

Buildkite is a member of the [GitHub secret scanning program
](https://docs.github.com/en/code-security/secret-scanning/secret-scanning-partnership-program/secret-scanning-partner-program).

If you have enabled [GitHub Secret Protection](https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security#github-secret-protection) for [repositories](https://docs.github.com/en/code-security/secret-scanning/enabling-secret-scanning-features/enabling-secret-scanning-for-your-repository) in your GitHub organization, GitHub will automatically scan these _private_ or _public_ repositories within your GitHub organization for Buildkite tokens and notify you if any are found.

In the case of user access tokens (`bkua_`) leaked on _public_ repositories, GitHub will notify Buildkite directly and any valid tokens will be automatically revoked and their owner's and associated organizations notified.

If you are notified of any other tokens, please contact Buildkite support.

## Supported tokens

### Buildkite API access tokens

Buildkite [API access tokens](/docs/apis#authentication) are also known as _Buildkite user access_ tokens, whose acronym forms the prefix for these types of tokens.

- Prefix: `bkua_`
- Example: `bkua_MTA.4f6ccde8c73e26244d73c5a77c91c242c0c818ce`

_Applies to API access tokens created after:  March, 2023_

### Buildkite agent access tokens

Buildkite agent access tokens, whose acronym forms the prefix for these types of tokens.

- Prefix: `bkaa_`
- Example: `bkaa_MTA.Miyf6S3a3g9j8pyBGTyLC1frg9k6gDHTJdL9Fy7FXzRhrAVPckkzK6oEmdQVLvzUjt4rvW7cRPJEu`

_Applies to agent access tokens created after: January, 2025_

### Buildkite agent job tokens

- prefix: `bkaj_`
- example: ` bkaj_eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIwMTk2NjAxYi01YTc0LTRlOTUtYmNhOC0wNjM0M2EyYjkwNzkiLCJhdWQiOiIwMTk2NjAxYi01NDcwLTQ0YWYtYjRmNi0xMjllNTcyNDU1ZTUiLCJpc3MiOiJidWlsZGtpdGUiLCJleHAiOjE3NDcxMDQ5MzgsImlhdCI6MTc0NzEwMTAzOCwib3JnYW5pemF0aW9uX2lkIjoiNjQ4OTlhNjUtMmFiZS00MTRiLTg2MjUtYTljOWE3MjYzZGRjIn0.p-IZUkRWJOkbTuVrxa4yaWrb7b1h-X2KsxfcCRHoxsb8h4rMjc47Ox1InAdku5fCjfdQ5hFKxXF2JUJc-YoWHQ`

### Buildkite unclustered agent tokens

Buildkite [unclustered agent tokens](/docs/agent/v3/unclustered-tokens) are also known as _Buildkite agent registration_ tokens, whose acronym forms the prefix for these types of tokens.

- prefix: `bkar_`
- example: `bkar_MTU.D3Efk6R62Fj7uprMGXsGjLhqugSfAXtAvpSjpMsykTzrHQnCH3rKETjo1NJ4yD9cSuGxsW5t3LJ6C`

_Applies to unclustered agent tokens created after: April, 2025_

### Buildkite agent tokens

Buildkite [agent tokens](/docs/agent/v3/tokens) are also known as _Buildkite cluster_ tokens, whose acronym forms the prefix for these types of tokens.

- prefix: `bkct_`
- example: `bkct_MTI.nYMxCVxgALbhwoc7pvvMfEURJgXXvzUVrogdmo1NKZqCcUTsmWRUWu9h3tW9j3nRvJ54aXyaKAdf6`

_Applies to agent tokens created after: April, 2025_

### Buildkite packages registry token

- prefix: `bkpt_`
- example: `bkpt_eyJfcmFpbHMiOnsiZGF0YSI6WyIwMTk2NjAyOC04OTk4LTQzZDctOTAyNC1mOGU0YjJhZThiZmEiLCI2MDA5MTFmMS1kZmU0LTRmMDctOGQ5OC0wYWZmMGI5ZDAyMTgiXSwiZXhwIjoiMjAyNS0wNS0xNlQwMjozNjozNC4wNzZaIn19--3116a4b837e78265cc7d3a90a12d90c263729880`

### Buildkite packages temporary token

- prefix: `bkpt_`
- example: `bkpt_eyJfcmFpbHMiOnsiZGF0YSI6WyIwMTk2NjAzOS0zMGUxLTQ0NmUtOTg4Yi0xNmNjNmQ3ZTlmYmYiLCIwMThmNTZlZi05NTZjLTc0NzAtOTVhNC1lOTE1MDlkMjlmMWUiXSwiZXhwIjoiMjAyNS0wNS0xNlQwMjozNjozNC40MDNaIn19--bb46c0fcd8d9a797df4282403030453043018155`

### Buildkite portal token

- prefix: `bkpat_`
- example: `bkpat_MTQ_5f6ccde8c73e26244d73c5a77c91c242c0c818ce`

### Buildkite portal secret

- prefix: `bkps_`
- example: `bkps_Mw_388c52458682d4e2621f28df4b3018f27b130ee6c7a263bbd3f96eb86916`
