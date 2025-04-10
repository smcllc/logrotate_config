# Logrotate Configuration Script

A bash script to automate the standardization of logrotate configurations across your system.

## Overview

This script provides a systematic way to update and standardize logrotate configuration files in `/etc/logrotate.d/`. It helps enforce consistent log rotation policies by setting standard values for rotation count and maximum age while backing up original configuration files.

## Features

- Sets standard rotation count (6) for all log configurations
- Sets maximum age (60 days) for all log files
- Changes `missingok` to `notifempty` in configuration files
- Creates backups of original configuration files
- Provides a dry-run mode to preview changes without modifying files
- Automatically skips the `wtmp` configuration file
- Verifies changes after applying them

## Requirements

- Root privileges
- Bash shell
- Logrotate installed on your system

## Installation

Clone the repository:

```bash
git clone https://github.com/yourusername/logrotate_config.git
cd logrotate_config
```

Make the script executable:

```bash
chmod +x logrotate_config.sh
```

## Usage

### Dry Run Mode

To see what changes would be made without actually modifying any files:

```bash
sudo ./logrotate_config.sh --dry-run
```

### Apply Changes

To apply the standardized configuration settings:

```bash
sudo ./logrotate_config.sh
```

## How It Works

1. Checks for root privileges
2. Creates backups of existing configuration files
3. For each configuration file in `/etc/logrotate.d/`:
   - Sets rotation count to 6
   - Sets maximum age to 60 days
   - Changes `missingok` to `notifempty`
4. Skips processing the `wtmp` configuration file
5. Verifies the changes
6. Restarts the logrotate service (if it exists as a systemd service)

## Configuration

The script has several configurable parameters at the top:

- `CONFIG_DIR`: Directory containing logrotate configurations
- Rotation count (set to 6)
- Maximum age (set to 60 days)

## Backup

The script automatically creates backups of all configuration files before making changes. Backups are stored in:

```
/etc/logrotate.d/backup-YYYYMMDD_HHMMSS/
```

## Security Considerations

This script requires root privileges to modify system configuration files. Always review the script before running it with elevated privileges.

## Contribute

Contributions are welcome! Please feel free to submit a Pull Request.


## License

Copyright (C) 2025 Scott Moore

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.
