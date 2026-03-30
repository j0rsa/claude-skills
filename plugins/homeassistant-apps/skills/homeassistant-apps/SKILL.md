---
name: homeassistant-apps
description: Home Assistant app development for the j0rsa/home-assistant-apps repository. Use when creating, updating, or maintaining Home Assistant apps (containerized services), including web UIs (HTML/JS/CSS in www/), Dockerfiles, run.sh scripts, config.yaml, build.yaml, documentation pages in docs/_apps/, and CHANGELOG.md files. Applies to any task involving this app repository.
---

# Home Assistant App Developer

Develop and maintain containerized Home Assistant apps with web UIs, proper configuration, and documentation.

## Development Workflow

Follow this sequence for every app change:

### 1. Understand the App

Before making any changes, read the app's key files:

- `config.yaml` - Current version, options, schema, ports, architecture
- `translations/en.yaml` - Human-readable names and descriptions for config options (if present)
- `www/` directory - Web UI files (if present): `index.html`, `app.js`, `converter.js`, `style.css`
- `run.sh` - Container entry point
- `Dockerfile` - Build instructions
- `CHANGELOG.md` - Existing changelog (if present)
- `docs/_apps/<app-name>.md` - Documentation page (if present)

### 2. Make Changes

Apply changes following the patterns described below. Key rules:

- **All files in an app live in its directory** (e.g., `xray-configurator/`)
- **Web UIs are pure client-side** - No backend processing, all logic runs in browser
- **Respect existing code style** - Match indentation, naming, patterns already in the file
- **CSS uses theme variables** - Never hardcode colors, use `var(--variable-name)`
- **JavaScript uses vanilla JS** - No frameworks, no build tools

### 3. Bump Version (MANDATORY)

After changes are complete, bump the version in `config.yaml`:

- **Patch** (1.1.3 -> 1.1.4): Bug fixes, minor tweaks
- **Minor** (1.1.3 -> 1.2.0): New features, UI additions
- **Major** (1.1.3 -> 2.0.0): Breaking changes, major rewrites

### 4. Update CHANGELOG.md (MANDATORY)

Add a new entry at the top of `CHANGELOG.md` (create the file if it doesn't exist):

```markdown
## X.Y.Z

- Add feature description
- Fix bug description
```

Format rules:
- Version header uses `##`
- Each change is a bullet point starting with a verb: Add, Fix, Update, Remove, Improve
- Keep entries concise (one line each)
- Group related changes under the same version

### 5. Update Translations (MANDATORY for apps with config options)

If `translations/en.yaml` exists, update it to match any new or changed options. If it doesn't exist yet, create it. Every option in `config.yaml` `options:` must have a `name` and `description` in the translations file.

### 6. Update Documentation Page

If `docs/_apps/<app-name>.md` exists, review it for accuracy:

- Do new features need to be listed?
- Are usage instructions still correct?
- Are security implications documented?
- Do configuration examples reflect current options?

### 7. Update docs/index.md (new apps only)

When **creating a new app**, add an entry to `docs/index.md` under the appropriate category section. Follow the existing format:

```markdown
#### [App Name](/apps/<app-slug>/)
One-line description of what the app does.
- Key feature 1
- Key feature 2
- Key feature 3
- Key feature 4

**Architectures:** `aarch64` `amd64`
```

Categories in order: Backup & Storage, Download Management, AI & Machine Learning, Networking & Proxy, DevOps & Git.

## Repository Structure

```
home-assistant-apps/
├── <app-name>/             # Each app in its own directory
│   ├── config.yaml         # HA app configuration (REQUIRED)
│   ├── build.yaml          # Architecture-specific base images (REQUIRED)
│   ├── Dockerfile          # Container build (REQUIRED)
│   ├── run.sh              # Entry point script (optional)
│   ├── CHANGELOG.md        # Version history
│   ├── README.md           # App documentation
│   ├── icon.png            # App icon
│   ├── logo.png            # App logo
│   ├── translations/       # UI field descriptions (recommended)
│   │   └── en.yaml
│   └── www/                # Web UI files (for web-based apps)
│       ├── index.html
│       ├── app.js
│       ├── style.css
│       └── *.js            # Additional JS modules
├── docs/
│   └── _apps/              # Documentation site pages
│       └── <app-name>.md
└── get_matrix.py           # CI/CD matrix generation
```

## config.yaml Pattern

```yaml
---
name: "App Name"
version: "1.0.0"
slug: "app-slug"
description: |
  Short description of the app.
init: false
startup: services
arch:
  - aarch64
  - amd64
map:
  - addon_config:rw
boot: auto
codenotary: "red.avtovo@gmail.com"
image: "ghcr.io/j0rsa/haddon-<app-slug>-{arch}"
udev: false
url: https://github.com/j0rsa/home-assistant-apps
webui: "http://[HOST]:[PORT:<port>]/"
ports:
  <port>/tcp: <port>
ports_description:
  <port>/tcp: Web UI port
ingress: true
ingress_port: <port>
panel_icon: mdi:web-box
```

Key fields:
- `version` - Semver string, must be bumped on every change
- `codenotary` - Always `"red.avtovo@gmail.com"`
- `image` - Always uses `ghcr.io/j0rsa/haddon-<slug>-{arch}` pattern
- `arch` - Typically `aarch64` and `amd64`

## Translations (translations/en.yaml)

Every app with config options should have a `translations/en.yaml` file that provides human-readable names and descriptions for the HA UI. This file is displayed in the app's configuration panel.

**Structure:**

```yaml
configuration:
  <option_name>:
    name: Human-Readable Name
    description: >-
      Multi-line description explaining what this option does,
      valid values, and any defaults.
network:
  <port>/tcp: Short port description
```

**Rules:**
- Every key in `config.yaml` `options:` must have a corresponding entry in `configuration:`
- Every key in `config.yaml` `ports:` should have a corresponding entry in `network:`
- Use `>-` (folded block scalar) for multi-line descriptions
- Descriptions should explain what the option does, valid values, and behavior when left blank
- Reference: [Mosquitto translations](https://github.com/home-assistant/addons/blob/master/mosquitto/translations/en.yaml)

**Example:**

```yaml
configuration:
  api_key:
    name: API Key
    description: >-
      Authentication key for the REST API. If left blank, the API runs
      without authentication. Consider setting this for production use.
  log_level:
    name: Log Level
    description: >-
      Controls log verbosity. Options: TRACE, DEBUG, INFO, WARN, ERROR.
network:
  6333/tcp: REST API port
  6334/tcp: gRPC API port
```

## Web UI Patterns

### Theme System

All web UIs support light/dark themes. CSS variables are defined in `:root`, `@media (prefers-color-scheme: dark)`, `:root[data-theme="dark"]`, and `:root[data-theme="light"]`.

**Always use theme variables for colors:**

```css
/* Available variables */
--bg-primary, --bg-secondary, --bg-tertiary     /* Backgrounds */
--text-primary, --text-secondary, --text-muted   /* Text colors */
--text-white                                      /* Always white */
--border-primary, --border-secondary              /* Borders */
--accent-primary                                  /* Brand/focus color */
--accent-success, --accent-success-hover          /* Green actions */
--accent-danger, --accent-danger-hover            /* Red/destructive */
--accent-warning                                  /* Orange/caution */
--shadow-light, --shadow-medium, --shadow-dark    /* Shadows */
--accent-focus                                    /* Focus rings */
--accent-hover                                    /* Hover backgrounds */
```

**Never hardcode colors in CSS.** If you need a new color, add it as a variable in all four theme blocks.

### Adding a New UI Section

Follow the established section pattern:

```html
<div class="section-name-section">
    <h3>Section Title</h3>
    <div class="section-name-group">
        <!-- Optional checkbox to make section toggleable -->
        <div class="option-header">
            <input type="checkbox" id="enableFeature" checked>
            <label for="enableFeature" class="checkbox-label">Enable Feature</label>
        </div>
        <!-- Collapsible content wrapper -->
        <div id="featureWrapper" class="feature-wrapper">
            <!-- Section content -->
        </div>
    </div>
</div>
```

CSS for new sections follows the group pattern:

```css
.section-name-group {
    padding: 12px;
    background: var(--bg-primary);
    border-radius: 6px;
    border: 1px solid var(--border-secondary);
    transition: border-color 0.3s, box-shadow 0.3s, background-color 0.3s;
}

.section-name-group:hover {
    border-color: var(--accent-primary);
    box-shadow: 0 2px 8px var(--accent-hover);
}
```

### Collapsible Sections

Use CSS max-height transitions for collapse/expand:

```css
.wrapper {
    max-height: 500px;
    transition: max-height 0.3s ease, opacity 0.3s ease;
    overflow: hidden;
}

.wrapper.collapsed {
    max-height: 0;
    opacity: 0;
}
```

### Event Handling

All UI changes trigger conversion via a debounced `performConversion()` function:

```javascript
// Element references
const myCheckbox = document.getElementById('myCheckbox');
const myInput = document.getElementById('myInput');

// Event listeners
myCheckbox.addEventListener('change', handleMyCheckboxChange);
myInput.addEventListener('input', performConversion);

// Checkbox handler pattern
function handleMyCheckboxChange() {
    if (myCheckbox.checked) {
        wrapper.classList.remove('collapsed');
        myInput.disabled = false;
    } else {
        wrapper.classList.add('collapsed');
        myInput.disabled = true;
    }
    performConversion();
}
```

### Converter Pattern (for xray-configurator)

The converter class generates Xray JSON configs. When adding new config sections:

1. Add parameter to `createXrayConfigVless()` and `createXrayConfigShadowsocks()` (both!)
2. Add parameter to `convertLink()` and pass it through
3. Add the config section to the returned object
4. In `app.js`, read the UI value and pass it to `converter.convertLink()`

## Routing Rules

Xray routing rules must only reference inbound tags that actually exist:

```javascript
// Build inbound tags from enabled proxies only
const inboundTags = [];
if (enableSocks) inboundTags.push('socks-in');
if (enableHttp) inboundTags.push('http-in');

const routingRules = [];
if (inboundTags.length > 0) {
    routingRules.push({
        type: 'field',
        inboundTag: inboundTags,
        outboundTag: 'vless-out'  // or 'ss-out' for Shadowsocks
    });
}
```

**Never hardcode inbound tags** - always check which inbounds are enabled.

## CHANGELOG.md Format

```markdown
# Changelog

## 1.2.0

- Add optional DNS configuration with customizable DNS servers
- Fix routing rules to only include inbound tags for enabled proxy types

## 1.1.3

- Fix theme detection and copy buttons
```

## Documentation Page Format (docs/_apps/)

```markdown
---
name: app-slug
title: App Name - Short Description
description: One-line description for SEO
category: Category Name
version: latest
architectures:
  - amd64
  - aarch64
ports:
  - 8099
---

# App Name

Brief intro paragraph.

## About
## Features
## Installation
## Usage
## Security
## Troubleshooting
## Support
```

## Git & CI/CD Rules

The CI pipeline uses `get_matrix.py` to detect changed directories from `HEAD~1`.

**Single commit spanning multiple apps is fine** — all changed directories are detected in one diff. Commit all app changes together and push once.

**Multiple commits in a single push is not fine** — only the last commit's diff (`HEAD~1`) is evaluated, so earlier commits may be skipped and never built.

Example: if you changed both `xray-configurator/` and `hev-socks5-tproxy/`:

- **OK**: Stage both apps → one commit → `git push`
- **Not OK**: Commit app1 → commit app2 → `git push` (only app2 gets built)

Changes within a single app (including its `docs/_apps/` page) can always be included in the same commit.

## Checklist Before Completion

After every app update, verify:

- [ ] Version bumped in `config.yaml`
- [ ] `CHANGELOG.md` updated with new entry
- [ ] `translations/en.yaml` updated to match config options
- [ ] `docs/_apps/<name>.md` reviewed and updated if needed
- [ ] Entry added to `docs/index.md` under the correct category (new apps only)
- [ ] CSS uses only theme variables (no hardcoded colors)
- [ ] Both VLESS and Shadowsocks code paths updated (if modifying converter)
- [ ] Routing rules only reference existing inbound tags
- [ ] Mobile responsive styles added for new UI elements
- [ ] New checkboxes use the standard `option-header` pattern
- [ ] New collapsible sections use the `collapsed` CSS class pattern
