module Grape::Middleware::FormatterOverride
  def before
    negotiate_content_type
    read_body_input unless env.key? Grape::Env::RACK_REQUEST_FORM_HASH
  end
end
