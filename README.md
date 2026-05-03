# turbo_modal / @finchi/turbo-modal

A Bootstrap/CoreUI modal that loads its content over Turbo, manages browser history, and dismisses cleanly on a redirect-style turbo_stream. Single repo, two packages, single release cadence.

## Install

`Gemfile`:

```ruby
gem "turbo_modal", git: "https://github.com/finchi/turbo-modal.git", tag: "v1.0.1"
```

`package.json`:

```json
"@finchi/turbo-modal": "git+https://github.com/finchi/turbo-modal.git#v1.0.1"
```

Then `bundle install` and `yarn install`.

## JavaScript

Register the Stimulus controller:

```js
import { Application } from "@hotwired/stimulus"
import { TurboModalController } from "@finchi/turbo-modal"

const application = Application.start()
application.register("turbo-modal", TurboModalController)
```

Peer deps: `@hotwired/stimulus`, `@hotwired/turbo-rails`, `@coreui/coreui`.

### Side effect: `Turbo.StreamActions.redirect`

**Importing this package has a side effect.** Loading `@finchi/turbo-modal` (or any of its named exports) registers a custom Turbo stream action named `redirect` on the global `Turbo.StreamActions` object. The controller's `handleResponse` intercepts incoming `<turbo-stream action="redirect">` elements and turns them into `Turbo.visit(target)`, which is what dismisses the modal and navigates after a successful form submission.

You do **not** need a separate `import "@finchi/turbo-modal/register"` call. The assignment runs at module-evaluation time, the first time anything imports the package:

```js
// node_modules/@finchi/turbo-modal/src/index.js
import { Turbo } from "@hotwired/turbo-rails"

Turbo.StreamActions.redirect = function() { /* ... */ }   // ← runs on first import

export { TurboModalController } from "./turbo_modal_controller.js"
```

Notes:

- The package shares a single `Turbo` instance with your app via the `@hotwired/turbo-rails` peer dependency. Two copies in the tree would silently break this — keep peer deps singular.
- Bundlers preserve the assignment because the package does **not** declare `"sideEffects": false` in its `package.json`. Tree-shaking won't remove it.
- The registration runs once per page load. Re-imports return the cached module without re-running top-level code.
- If your app already defines its own `Turbo.StreamActions.redirect`, this package will overwrite it. Don't define a competing handler with the same name.

## Helpers

The Rails engine auto-includes the helpers into ActionView. Available in any view:

```erb
<%# in your application layout, once: %>
<%= turbo_modal_tag %>

<%# in any new/edit view: %>
<%= turbo_modal(title: t("helpers.edit", model: User.model_name.human)) do |m| %>
  <%= simple_form_for @user, data: { turbo: m.turbo_form? } do |f| %>
    <%= f.error_notification %>
    <div class="form-inputs">
      <%= f.input :name %>
    </div>
    <%= m.with_modal_form_footer(form: f) %>
  <% end %>
<% end %>
```

`TurboModal::Component` initializer args: `title:`, `modal_backdrop:`, `modal_static_backdrop:`, `modal_size:` (e.g. `"modal-lg"`), `modal_header_tag:` (default `:h3`).

Slots: `modal_html`, `modal_header`, `modal_footer`, `modal_form_footer` (typed as `TurboModal::FormActionsComponent`).

## Controller concern

```ruby
class ApplicationController < ActionController::Base
  include TurboModal::Redirects
end
```

Provides:

- `turbo_modal_redirect_to(target, notice:, alert:, status: 302)` — emits a `redirect` turbo_stream the JS controller turns into a `Turbo.visit`.
- `turbo_modal_redirect_back(fallback_location:, allow_other_host: _allow_other_host, notice:, alert:, status: 302)` — uses `request.referer` if `turbo_modal_host_allowed?(url)` says so, else `fallback_location`. On Hotwire Native, always uses `fallback_location`.
- `redirect_on_record_not_found_to(route, alert:)` — class macro wiring `rescue_from ActiveRecord::RecordNotFound` to redirect via turbo_stream or html.

### Allowing extra hosts

Override `turbo_modal_host_allowed?(url)` to extend the modal redirect-back allow-list **without** affecting Rails' `redirect_back_or_to`:

```ruby
class ApplicationController < ActionController::Base
  include TurboModal::Redirects

  ALLOWED_HOSTS = %w[primary.example.com secondary.example.com].freeze

  private

  def turbo_modal_host_allowed?(url)
    host = URI(url.to_s).host rescue nil
    return true if host && ALLOWED_HOSTS.include?(host)
    super
  end
end
```

The default implementation delegates to Rails' built-in `_url_host_allowed?` (same-host only).

## Markup contract (Stimulus)

| Hook | Name |
| --- | --- |
| `data-controller` | `turbo-modal` |
| `data-action` | `turbo:before-stream-render@document->turbo-modal#handleResponse hidden.coreui.modal->turbo-modal#resetModalElement` |
| Stimulus values | `backdrop` (Boolean, default `true`), `staticBackdrop` (Boolean, default `false`), `advanceUrl` (String, optional) |
| Body data attribute | `data-turbo-modal-history-advanced="true"` (set when the controller pushes history; consumed by the back-button handler) |

## Releases

### v1.0.0 — faithful extraction

Behaviorally identical to the original implementation in the source app, modulo the host-allow-list refactor (named `turbo_modal_host_allowed?` hook instead of overriding Rails' private method). Default behavior is the same. **Includes the popstate listener leak** present in the original. Useful as a baseline.

### v1.0.1 — popstate listener cleanup

Fixes a bug where each `connect()` registered an anonymous `popstate` listener that `disconnect()` never removed. After several modal cycles, accumulated stale listeners caused a single browser-Back press to skip multiple history entries. Pin `v1.0.1` directly.

## Versioning

Semver. Renames of the controller class, Stimulus values, the stream-action name (`redirect`), helper names, concern method names (including `turbo_modal_host_allowed?`), or slot names are major bumps. The `package.json` `version` and `lib/turbo_modal/version.rb`'s `TurboModal::VERSION` must always match.

## License

MIT.
