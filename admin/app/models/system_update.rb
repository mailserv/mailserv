class SystemUpdate < ActiveResource::Base
  self.site             = CONF['web_client_url']
  self.element_name     = "update"
  self.collection_name  = 'updates'
end
