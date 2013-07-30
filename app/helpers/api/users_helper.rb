module API::UsersHelper
  def asset_url asset
      "#{request.protocol}#{request.host_with_port}#{asset_path(asset)}"
  end
end
