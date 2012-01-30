# -*- encoding : utf-8 -*-
require 'archive_search_configurator'
require 'find_site_search_configurator'

class Configurator

  def initialize( search_request_type )
    case search_request_type
      when :archive
        @configurator = ArchiveSearchConfigurator.new
      when :find_site
        @configurator = FindSiteSearchConfigurator.new
    end
  end

  def config_proc
    return @configurator.config_proc
  end

end