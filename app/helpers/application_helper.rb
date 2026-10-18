module ApplicationHelper
  NavLink = Struct.new(:name, :path)

  def main_nav_links
    if Current.user
      [
        NavLink.new("Dashboard", root_path),
        NavLink.new("Tests", minitest_test_classes_path),
        NavLink.new("Journeys", journeys_path),
        NavLink.new("Settings", settings_path)
      ]
    else
      [
        NavLink.new("Login", sign_in_path),
        NavLink.new("Sign up", sign_up_path)
      ]
    end
  end

  def nav_link_to(name, path)
    link_to(
      name,
      path,
      class: class_names(
        "inline-flex items-center border-b-2 px-1 pt-1 text-sm font-medium",
        "border-indigo-500 text-gray-900": current_page?(path),
        "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700": !current_page?(path)
      ),
      html: {aria_current: current_page?(path)}
    )
  end

  def mobile_nav_link_to(name, path)
    link_to(
      name,
      path,
      class: class_names(
        "block border-l-4 border-transparent py-2 pl-3 pr-4 text-base font-medium",
        "text-gray-600 hover:border-gray-300 hover:bg-gray-50 hover:text-gray-800": !current_page?(path),
        "border-indigo-500 bg-indigo-50 text-indigo-700": current_page?(path)
      ),
      aria: {current: current_page?(path)}
    )
  end
end
