import Config

config :zendesk,
  token: System.get_env("ZENDESK_TOKEN"),
  email: System.get_env("ZENDESK_EMAIL"),
  subdomain: System.get_env("ZENDESK_SUBDOMAIN")
