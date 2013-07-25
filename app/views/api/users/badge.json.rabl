object false
#@user, @campaign

node(:uid) {@user.id}
child :recipient do
  node(:type) {'email'}
  node(:hashed) {'false'}
  node(:identity) {@user.email}
end
node(:image) {@campaign.individual_badge}
node(:evidence) {@campaign.id}
node(:issuedOn) {@campaign.created_at}
node(:badge) {'/badge.json'}
child :verify do
  node(:type) {'hosted'}
  node(:url) {'/badge.json'}
end
