"""
Shared MySQL connection helper for all chart scripts in this folder.

Credentials are read from environment variables so nothing sensitive is
hardcoded into a file that might get committed to version control:

    DB_HOST      (default: localhost)
    DB_PORT      (default: 3306)
    DB_USER      (default: root)
    DB_PASSWORD  (required, no default)
    DB_NAME      (default: crm_sales_opportunities)

Set them before running a script, e.g. in PowerShell:
    $env:DB_PASSWORD = "your_password_here"
    python python_scripts/top_agents_by_revenue.py
"""
import os
from urllib.parse import quote_plus
from sqlalchemy import create_engine

DB_HOST = os.environ.get("DB_HOST", "localhost")
DB_PORT = os.environ.get("DB_PORT", "3306")
DB_USER = os.environ.get("DB_USER", "root")
DB_PASSWORD = os.environ.get("DB_PASSWORD")
DB_NAME = os.environ.get("DB_NAME", "crm_sales_opportunities")

if DB_PASSWORD is None:
    raise EnvironmentError(
        "DB_PASSWORD environment variable is not set. "
        "Set it before running any chart script, e.g.:\n"
        '  PowerShell:  $env:DB_PASSWORD = "your_password_here"\n'
        "  Bash:        export DB_PASSWORD='your_password_here'"
    )


def get_engine():
    # quote_plus escapes special characters (@, :, /, etc.) so a password
    # containing them doesn't get misparsed as part of the host/port.
    user = quote_plus(DB_USER)
    password = quote_plus(DB_PASSWORD)
    url = f"mysql+pymysql://{user}:{password}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    return create_engine(url)
