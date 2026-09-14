# Versioned application configuration

These files are a sanitized, reviewable baseline for rebuilding the Starr stack.
Runtime databases, logs, caches, media indexes, and credentials are intentionally excluded.
The live application data remains in each application's `config/` directory.

Run `scripts/export-config.sh` after intentional configuration changes and commit the diff.
Restore the compose stack first, then restore each application's settings through its UI or API.
