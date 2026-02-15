# CSP

## Static Code Analysis

Run all static checks:

```bash
bin/static_analysis
```

This runs:

- `bin/rubocop`
- `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error`
- `bin/bundler-audit check`

The same checks are also part of `bin/ci`.
