module UsersHelper
  def invite_link_to(user)
    neo4j = UserNeo4j.find(@current_user.neo4j_uuid)
    invited = begin
                neo4j.friends.find(user.neo4j_uuid).present?
              rescue StandardError
                nil
              end

    link_to invite_user_path(user), class: "card-footer-item btn-invite #{'is-active' if invited}" do
      content_tag(:div, nil, class: 'heart') + ' Invite'
    end
  rescue StandardError
    nil
  end

  def friends_path(path)
    return if path.blank?

    path.map do |friend|
      link_to friend.full_name, user_path(friend)
    end.join(' ⇾ ').html_safe
  end
end
