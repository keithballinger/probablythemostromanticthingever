probablythemostromanticthingever
================================

Sinatra+Redis app for ephemeral messaging based on FB user IDs

Left/Right cards are generated by partials in views/partials/[left/right]. They default to -1 (unauth'ed, no more messages), and count up from day 0 (0.erb, 1.erb, 2.erb, etc.).
Keys for services are expected in config/application.yml. Currently using fb_[key/secret], twilio_[key/secret/to/from], and typekit_key.
