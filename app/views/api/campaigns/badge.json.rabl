object @campaign

@tags = ['civic','volunteer']

attributes :name, :description
attribute :individual_badge => :image
node(:criteria) {"#{request.protocol}#{request.host_with_port}/campaigns/#{@campaign.id}"}
node :tags do
    @tags.map { |lang| lang }
end
node(:issuer) {"#{request.protocol}#{request.host_with_port}/api/organization.json"}