module AuthHelper
  # App's client ID. Register the app in Application Registration Portal to get this value.
  CLIENT_ID = '10536f42-a541-4d7b-a10b-1b9b184fb581'
  # App's client secret. Register the app in Application Registration Portal to get this value.
  CLIENT_SECRET = '65xsAGXHnQV9QWmh2mNkeRs'

  # Scopes required by the app
  SCOPES = [ 'openid',
             'profile',
             'offline_access',
             'User.Read',
             'Mail.Read' ]

  # REDIRECT_URI = 'http://localhost:3000/authorize' # Temporary!

  # Generates the login URL for the app.
  def get_login_url
    client = OAuth2::Client.new(CLIENT_ID,
                                CLIENT_SECRET,
                                :site => 'https://login.microsoftonline.com',
                                :authorize_url => '/common/oauth2/v2.0/authorize',
                                :token_url => '/common/oauth2/v2.0/token')

    login_url = client.auth_code.authorize_url(:redirect_uri => authorize_url, :scope => SCOPES.join(' '))
  end

  def get_token_from_code(auth_code)
    client = OAuth2::Client.new(CLIENT_ID,
                                CLIENT_SECRET,
                                :site => 'https://login.microsoftonline.com',
                                :authorize_url => '/common/oauth2/v2.0/authorize',
                                :token_url => '/common/oauth2/v2.0/token')

    token = client.auth_code.get_token(auth_code,
                                       :redirect_uri => authorize_url,
                                       :scope => SCOPES.join(' '))
  end

  # Gets the current access token
  def get_access_token
    # Get the current token hash from session
    token_hash = session[:azure_token]

    client = OAuth2::Client.new(CLIENT_ID,
                                CLIENT_SECRET,
                                :site => 'https://login.microsoftonline.com',
                                :authorize_url => '/common/oauth2/v2.0/authorize',
                                :token_url => '/common/oauth2/v2.0/token')

    token = OAuth2::AccessToken.from_hash(client, token_hash)

    # Check if token is expired, refresh if so
    if token.expired?
      new_token = token.refresh!
      # Save new token
      session[:azure_token] = new_token.to_hash
      access_token = new_token.token
    else
      access_token = token.token
    end
  end

  # Gets the user's email from the /Me endpoint
  def get_user_email(access_token)
    callback = Proc.new { |r| r.headers['Authorization'] = "Bearer #{access_token}"}

    graph = MicrosoftGraph.new(base_url: 'https://graph.microsoft.com/v1.0',
                               cached_metadata_file: File.join(MicrosoftGraph::CACHED_METADATA_DIRECTORY, 'metadata_v1.0.xml'),
                               &callback)

    me = graph.me
    email = me.mail
  end
end
