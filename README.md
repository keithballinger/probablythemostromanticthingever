probablythemostromanticthingever
================================

Sinatra+Redis app for ephemeral messaging based on FB user IDs.
As with most great projects, written for a lady.

Left/Right cards are generated by partials in views/partials/[left/right].
They default to -1 (unauth'ed, no more messages), and count up from
day 0 (0.erb, 1.erb, 2.erb, etc.).

Keys for services are expected in config/application.yml. Currently
using fb_[key/secret], twilio_[key/secret/to/from], typekit_key, and
google_analytics_key.

<a href="http://probablythemostromanticthingever.com"
target="_blank">http://probablythemostromanticthingever.com </a>
