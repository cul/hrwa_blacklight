require 'blacklight/catalog'
require 'pp'

class CatalogController < ApplicationController

  include Blacklight::Catalog
  include HRWA::AdvancedSearch::Query
  include HRWA::Debug

  # displays values and pagination links for a single facet field
  def facet
    _configure_by_search_type
    @configurator.configure_facet_action( self.blacklight_config )
    @pagination = get_facet_pagination(params[:id], params)
  end

  # get search results from the solr index
  def index
    if !params[:search].blank?

      _configure_by_search_type
      
      # Add our own processing to the end of the standard Blacklght SOLR
      # params method chain
      
      if params[ :search_mode ] == "advanced"
      
      # Advanced searches require some extra params manipulation
        self.solr_search_params_logic << :advanced_search_processing
      end
      
      self.solr_search_params_logic << :process_search_request

      begin
        (@response, @result_list) = get_search_results( params, {} )
      rescue => ex
        @errors = ex.to_s.html_safe

        # TODO: remove this from production version
        if params.has_key?( :hrwa_debug )
          _set_debug_display
        end
      
        render :error and return
      end

      # Configurator might need to manipulate the @response and @result_list
      # This is absolutely the case for an archive search
      if @configurator.post_blacklight_processing_required?
        @response, @result_list = @configurator.post_blacklight_processing( @response,
                                                                            @result_list )
      end

      @filters = params[:f] || []

      # Select appropriate partials
      @result_partial = @configurator.result_partial
      @result_type    = @configurator.result_type

      # TODO: remove this from production version
      if params.has_key?( :hrwa_debug )
        _set_debug_display
      end

      respond_to do |format|
        format.html { save_current_search_params }
        format.rss  { render :layout => false }
        format.atom { render :layout => false }
      end

    end

  end

  # display the site detail for an fsf record, using bib_key as a unique identifier
  # use the bib_key to get a single document from the solr index
  def site_detail
    _configure_by_search_type('site_detail')
    @bib_key = params[:bib_key]
    @response, @document = get_solr_response_for_doc_id(@bib_key)
  end

  def advanced_search_processing( solr_parameters, user_params )
    # For now the q_* fields are processed the same for all search_types
    advanced_search_processing_q_fields( solr_parameters, user_params )
  end
  
  # This has to be defined in controller in order to be added to solr_search_params_logic
  def process_search_request( solr_parameters, user_params )
    @configurator.process_search_request( solr_parameters, user_params )
  end

  private

  def _configure_by_search_type(search_type = params[:search_type])
    @debug = ''.html_safe

    @search_type = search_type.to_sym

    @configurator = HRWA::Configurator.new( @search_type )

    # See https://issues.cul.columbia.edu/browse/HRWA-324
    @configurator.reset_configuration( self.blacklight_config )

    # CatalogController.configure_blacklight yields a Blacklight::Configuration object
    # that expects a block/proc which sets its attributes accordingly
    CatalogController.configure_blacklight( &@configurator.config_proc )

    Blacklight.solr = RSolr::Ext.connect( :url => @configurator.solr_url )
  end
  
  def _set_debug_display
    @debug << "<h1>@result_partial = #{ @result_partial }</h1>".html_safe
    @debug << "<h1>@result_type    = #{ @result_type }</h1>".html_safe

    @debug << "<h1>params[]</h1>".html_safe
    @debug << params_list

    @debug << '<h1>solr_search_params_logic</h1>'.html_safe
    @debug << array_pp( self.solr_search_params_logic )

    @debug << "<h1>self.solr_search_params( params )</h1>\n\n".html_safe
    solr_search_parameters = self.solr_search_params( params ) 
    solr_search_parameters.keys.sort{ | a, b | a.to_s <=> b.to_s }.each do | key |
      @debug << "<strong>#{key}</strong> = ".html_safe << solr_search_parameters[ key ].to_s << "<br/>".html_safe
    end

    if @response
      @debug << '<h1>@response.request_params</h1>'.html_safe
      @debug << "<pre>#{ @response.request_params.pretty_inspect }</pre>".html_safe

      @debug << '<h1>@result_list</h1>'.html_safe
      @debug << "<pre>#{ @result_list.pretty_inspect }".html_safe

      @debug << '<h1>@response</h1>'.html_safe
      @debug << "<pre>#{ @response.pretty_inspect }</pre>".html_safe
    end
  end

end
