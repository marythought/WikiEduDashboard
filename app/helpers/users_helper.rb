#= Helpers for users
module UsersHelper
  def contribution_link(user, text=nil, css_class=nil)
    options = { target: '_blank', class: css_class }
    link_to((text || user.username), user.contribution_url, options)
  end
end
