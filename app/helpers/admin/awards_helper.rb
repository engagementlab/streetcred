module Admin::AwardsHelper
  def link_to_add_fields(link_name, parent, f, association)
    new_object = parent.send(association).new
    id = new_object.object_id
    fields = f.fields_for("required_actions_attributes[]", new_object, index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(link_name, '#', class: "add_fields btn btn-small btn-success", data: {id: id, fields: fields.gsub("\n", "")})
  end
end
