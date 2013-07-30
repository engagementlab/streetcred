object @campaign

node(:name) { 'StreetCred' }
node(:image) { "#{request.protocol}#{request.host_with_port}/assets/logo.png" }
node(:url) { "#{request.protocol}#{request.host_with_port}" }
node(:email) { 'admin@streetcred.dev' }
