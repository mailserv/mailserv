ActionController::Routing::Routes.draw do |map|

  # This is where the home page lives
  map.root :controller => 'auth', :action => 'index'

#  map.login  '/',  :controller => 'auth', :action => 'login'
  map.logout '/logout', :controller => 'auth', :action => 'logout'

  map.resources :domains, :active_scaffold => true do |domain|
    domain.resources :users, :active_scaffold => true
    domain.resources :forwardings, :active_scaffold => true
  end

  map.namespace :greylist do |greylist|
    greylist.resources :greylisted, :active_scaffold => true
    greylist.resources :whitelist, :active_scaffold => true
  end

  map.resources :greylist, :active_scaffold => true

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  map.connect ':controller/:action/:ip', :id => nil,
    :requirements => {:ip => /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/}

  map.connect '/domains/:domain_id/:controller/:id/save_admin_domains', :action => 'save_admin_domains',
    :requirements => {:domain_id => /\d+/}

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'

end
