module ServiceSupport
  extend ActiveSupport::Concern
  
  def service
    Sails.service
  end
  
  # Insert a instance into Sails.service
  def insert_service(instance)
    service.services << simple
    service.send(:define_service_methods!)
  end
end
