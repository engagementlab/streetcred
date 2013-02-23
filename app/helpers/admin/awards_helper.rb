module Admin::AwardsHelper
  def link_to_add_fields(name, parent, f, association)
    # have to create so we get an id and have to do so through the association so embedded_in can put it in the parent doc
    new_object = parent.send(association).create
    id = new_object.object_id
    fields = f.fields_for("required_actions_attributes[]", new_object) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end
end
