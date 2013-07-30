object @campaign

attributes :name, :description
attribute :individual_badge => :image
node(:criteria) { 'http://streetcred.dev/api/campaigns/51ef440ce9aba4015d000005' }
node(:tags) {'["civic", "volunteer"]'}
node(:issuer) {'http://streetcred.dev/api/organization'}
