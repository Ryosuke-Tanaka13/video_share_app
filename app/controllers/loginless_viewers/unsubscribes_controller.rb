  before_action :ensure_logged_in
  before_action :owner_in_same_organization_as_set_loginless_viewer
  before_action :set_viewer
