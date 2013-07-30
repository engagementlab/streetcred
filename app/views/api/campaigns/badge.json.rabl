object @campaign

attributes :name, :description
attribute :individual_badge => :image
node(:criteria) {"#{request.protocol}#{request.host_with_port}/api/campaigns/#{@campaign.id}.json"}
node(:tags) {'["civic", "volunteer"]'}
node(:issuer) {"#{request.protocol}#{request.host_with_port}/api/organization.json"}
