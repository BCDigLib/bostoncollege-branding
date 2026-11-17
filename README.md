# bostoncollege-branding

An [ArchivesSpace](https://archivesspace.org/) plugin with Boston College Libraries' branding and local customizations. It covers the Public User Interface (PUI) for **Burns Library Archival Collections**, plus a few changes to the staff interface and the backend EAD exporter.

The `4.0.0` branch targets **ArchivesSpace v4.0.0**. Branches for older releases (`v3.2.0`, `v3.3.1`, `3.4.0`, `v3.5.1`) are kept for reference.

---

## Installation

1. Clone this repository into the ArchivesSpace `plugins` directory. The directory name must be `bostoncollege-branding`, because locale keys and the plugin menu label depend on it:

   ```sh
   cd /path/to/archivesspace/plugins
   git clone https://github.com/BCDigLib/bostoncollege-branding.git
   cd bostoncollege-branding
   git checkout 4.0.0   # match your ArchivesSpace version
   ```

2. Enable the plugin in `config/config.rb`:

   ```ruby
   AppConfig[:plugins] = ['local', 'lcnaf', 'bostoncollege-branding']
   ```

3. **Manually** copy the PDF stylesheet assets. ArchivesSpace does not load `stylesheets/` from plugins (see [stylesheets/README.md](stylesheets/README.md)):

   ```sh
   cp stylesheets/as-ead-pdf.xsl stylesheets/boston-college-logo.jpg \
      /path/to/archivesspace/stylesheets/
   ```

4. Restart ArchivesSpace.

---

## Repository layout

```
backend/
  model/ead.rb                 Override of the EAD serializer (exporter)
frontend/                      Staff interface customizations
  assets/images/               Environment-specific logos (dev/test)
  locales/                     Staff UI label overrides (user-defined fields, welcome text)
  views/                       Staff UI view overrides
public/                        Public User Interface (PUI) customizations
  plugin_init.rb               AppConfig settings + Ruby class/controller overrides
  routes.rb                    Extra routes (e.g. /faq)
  controllers/                 New controllers (StaticController for the FAQ page)
  assets/                      custom.css, custom.js, favicons, BC logo
  locales/                     PUI label and welcome-page text
  views/                       PUI view overrides (header, footer, search results, record pages…)
stylesheets/                   EAD-to-PDF XSL + logo (copy manually, see above)
```

Files ending in `.old` are previous versions kept for reference. ArchivesSpace ignores them.

---

## What the plugin changes

### Public interface (`public/`)

**Configuration** (top of [public/plugin_init.rb](public/plugin_init.rb))
- Feedback URL points to the Burns Library contact page.
- Search results page size is set to 25.
- Repositories, accessions, subjects and classifications are hidden. Digital objects and container inventory stay visible.
- The PUI "Request" page action is turned off.
- Adds an **FAQ** link to the main nav, served by `/faq` ([routes.rb](public/routes.rb), [static_controller.rb](public/controllers/static_controller.rb), [faq_page.html.erb](public/views/static/faq_page.html.erb)).

**Class overrides** (inside `Rails.application.config.after_initialize` in `plugin_init.rb`)
- `Record`: search results also show the *Conditions Governing Access* note (`accessrestrict`).
- `SearchController`, `ResourcesController`, `AgentsController`, `ObjectsController`: remove **subject** and **repository** facets and search types.
- `WelcomeController`: custom home page that renders repository 2 (Burns Library) directly.

**Views and assets**
- BC header, footer, favicon and logo (`views/shared/`, `assets/`).
- [layout_head.html.erb](public/views/layout_head.html.erb) loads `custom.css`/`custom.js` and optional Google Analytics / Matomo trackers.
- The BC Libraries downtime-notice script is included in [_boston_college_header.html.erb](public/views/shared/_boston_college_header.html.erb).
- Search results, breadcrumbs, record summaries and badges are customized (identifiers, subjects and repository badges are hidden).
- Welcome-page copy (including the harmful-language statement) lives in [public/locales/en.yml](public/locales/en.yml) under `brand:`.

**Analytics** (optional, set in `config/config.rb`)
```ruby
AppConfig[:analytics_id_ga]     = 'G-XXXXXXX'
AppConfig[:analytics_id_matomo] = '1'
```
A tracker loads only when its key is set and not empty.

### Staff interface (`frontend/`)
- Custom labels for user-defined fields (`string_1`–`string_3`, `text_4`) and staff welcome text.
- Override of the instance display (`views/instances/_show.html.erb`).
- Logos for dev/test environments.

### Backend (`backend/`)
- [backend/model/ead.rb](backend/model/ead.rb) overrides the core EAD serializer. Local edits are in `serialize_languages()` and `serialize_digital_object()`.

---

## Upgrading to a new ArchivesSpace version

Many files here are **full copies of core ArchivesSpace files** with BC edits on top, so they need checking on every upgrade.

1. Create a branch named for the target version (e.g. `4.1.0`).
2. Find the overridden files. Most have a header like this:
   ```
   # most recent file version: v4.0.0
   # https://github.com/archivesspace/archivesspace/blob/v4.0.0/...
   ```
3. Diff each file against the same file in the new ArchivesSpace release. Copy the new upstream version over, then re-apply the BC changes, which are marked with `BC NOTE` / `BC local edits` comments.
4. Update the version header in each file.
5. Test on a dev/test instance before deploying to production.

### Conventions
- Mark every local change with a `BC NOTE:` comment explaining what changed and why.
- Comment out upstream code rather than deleting it when that makes the change clearer.
- Put user-facing text in `locales/en.yml`, not hard-coded in views.

---

## Resources
- [ArchivesSpace plugin documentation](https://docs.archivesspace.org/customization/plugins/)
- [ArchivesSpace source (v4.0.0)](https://github.com/archivesspace/archivesspace/tree/v4.0.0)
- [Burns Library contact](https://libguides.bc.edu/burns/contact)
