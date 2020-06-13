module ApplicationHelper
  def user_name
    return 'Nobody' unless session[:session_user_id]

    User.where({ id: session[:session_user_id] }).max(:first_name)
  end

  def users_links(html_class = 'navbar-item')
    items = []
    users = User.
      order_by({ last_name: 'ASC', first_name: 'ASC' }).
      pluck(:id, :first_name, :last_name)

    users.each do |user|
      id, first_name, last_name = user

      items << link_to(
        "#{last_name.upcase}, #{first_name}",
        sign_in_path({ user_id: id }),
        { class: html_class }
      )
    end

    items.join("\n").html_safe
  end
end
