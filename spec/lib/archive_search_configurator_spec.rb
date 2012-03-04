require 'spec_helper'
require 'blacklight/configuration'

describe 'HRWA::ArchiveSearchConfigurator' do
  before ( :all ) do
    @configurator = HRWA::ArchiveSearchConfigurator.new
  end

  it 'returns the correct partial name' do
    @configurator.result_partial.should == 'group'
  end

  it 'returns the correct result type' do
    @configurator.result_type.should == 'group'
  end

  context '#config_proc' do
    before( :all ) do
      @blacklight_config = Blacklight::Configuration.new
      config_proc        = @configurator.config_proc
      @blacklight_config.configure &config_proc
    end

    it 'sets Blacklight::Configuration.default_solr_params correctly' do
      @blacklight_config.default_solr_params.should ==
        {
          :defType          => "dismax",
          :facet            => true,
          :'facet.field'    => [
                                'domain',
                                'geographic_focus__facet',
                                'organization_based_in__facet',
                                'organization_type__facet',
                                'language__facet',
                                'contentMetaLanguage',
                                'creator_name__facet',
                                'mimetype',
                                'dateOfCaptureYYYY',
                               ],
          :'facet.mincount' => 1,
          :group            => true,
          :'group.field'    => 'originalUrl',
          :'group.limit'    => 10,
          :hl               => true,
          :'hl.fragsize'    => 1000,
          :'hl.fl'          => [
                               'originalUrl',
                               'contentTitle',
                               'contentBody',
                               'contentMetaDescription',
                               'contentMetaKeywords',
                               'contentMetaLanguage',
                               'contentBodyHeading1',
                               'contentBodyHeading2',
                               'contentBodyHeading3',
                               'contentBodyHeading4',
                               'contentBodyHeading5',
                               'contentBodyHeading6',
                               ],
          :'hl.usePhraseHighlighter' => true,
          :'hl.simple.pre'  => '<code>',
          :'hl.simple.post' => '</code>',
          :'q.alt'          => "*:*",
          :qf               => ["contentTitle^1",
                                "contentBody^1",
                                "contentMetaDescription^1",
                                "contentMetaKeywords^1",
                                "contentMetaLanguage^1",
                                "contentBodyHeading1^1",
                                "contentBodyHeading2^1",
                                "contentBodyHeading3^1",
                                "contentBodyHeading4^1",
                                "contentBodyHeading5^1",
                                "contentBodyHeading6^1"],
          :rows             => 10,
        }
    end

    it 'sets Blacklight::Configuration.facet_fields.* stuff correctly' do
      expected_facet_fields = {
        'domain'                       => { :label => 'Domain',                     :limit => 10 },
        'geographic_focus__facet'      => { :label => 'Organization/Site Geographic Focus',
                                                                                    :limit => 10 },
        'organization_based_in__facet' => { :label => 'Organization/Site Based In', :limit => 10 },
        'organization_type__facet'     => { :label => 'Organization Type',          :limit => 10 },
        'language__facet'              => { :label => 'Website Language',           :limit => 10 },
        'contentMetaLanguage'          => { :label => 'Language of page',           :limit => 10 },
        'creator_name__facet'          => { :label => 'Creator Name',               :limit => 10 },
        'mimetype'                     => { :label => 'File Type',                  :limit => 10 },
        'dateOfCaptureYYYY'            => { :label => 'Year of Capture',            :limit => 10 },
      }

      expected_facet_fields.each { | name, expected |
        @blacklight_config.facet_fields[ name ].should_not be_nil
        @blacklight_config.facet_fields[ name ].label.should == expected[ :label ]
        @blacklight_config.facet_fields[ name ].limit.should == expected[ :limit ]
      }
    end

    it 'sets Blacklight::Configuration.index.* stuff correctly' do
      @blacklight_config.index.show_link.should           == 'contentTitle'
      @blacklight_config.index.record_display_type.should == ''
    end

    it 'sets Blacklight::Configuration.index_fields correctly' do
        @blacklight_config.index_fields.should be_empty
    end

    it 'sets Blacklight::Configuration.search_fields correctly' do
      @blacklight_config.search_fields.should be_empty
    end

    it 'sets Blacklight::Configuration.show_fields correctly' do
        @blacklight_config.show_fields.should be_empty
    end

    it 'sets Blacklight::Configuration.sort_fields correctly' do
      expected_sort_fields = {
        'score desc' => { :label => 'relevance' },
      }

      expected_sort_fields.each { | name, expected |
        @blacklight_config.sort_fields[ name ].should_not be_nil
        @blacklight_config.sort_fields[ name ].label.should == expected[ :label ]
      }
    end

    it 'sets Blacklight::Configuration.spell_max correctly' do
      @blacklight_config.spell_max.should == 5
    end

    it 'sets Blacklight::Configuration.unique_key correctly' do
      @blacklight_config.unique_key.should == 'recordIdentifier'
    end

    it '#post_blacklight_processing_required? returns true' do
      @configurator.post_blacklight_processing_required?.should == true
    end

    it '#post_blacklight_processing modifies result_list correctly' do
      raw_response         = create_mock_raw_response
      expected_result_list = raw_response[ 'grouped' ][ 'originalUrl' ][ 'groups' ]

      solr_response = create_mock_rsolr_ext_response
      result_list   = [ "doesn't matter what's in here -- should never see this" ]
      solr_response, result_list = @configurator.post_blacklight_processing( solr_response, result_list )
      result_list.should == expected_result_list
    end

    # TODO: add group and highlight specs
  end

  describe '#process_search_request' do
    before :each do
      @params = { :search_type => 'archive', :search_mode => 'advanced', :q => 'women', :q_and => 'women', :q_phrase => '', :q_or => '', :q_exclude => '', :lim_domain => '', :lim_mimetype => '', :lim_language => '', :lim_geographic_focus => '', :lim_organization_based_in => '', :lim_organization_type => '', :lim_creator_name => '', :crawl_start_date => '', :crawl_end_date => '', :rows => '10', :sort => 'score+desc', :solr_host => 'harding.cul.columbia.edu', :solr_core_path => '%2Fsolr-4%2Fasf', :submit_search => 'Advanced+Search' }
    end
    
    domains_to_exclude = [ 
                           [ 'www.hrw.org', 'wayback.archive-it.org', 'amnesty.org' ],
                           [ 'advocacyforum.org' ],
                           [ ],
                         ]
    domains_to_exclude.each { | domains |
      it "creates correct fq SOLR params for excl_domain[] = #{ domains }" do
        @params.merge!( { :'excl_domain' => domains } )
        extra_controller_params = {}      
        @configurator.process_search_request( extra_controller_params, @params )
        extra_controller_params[ :fq ].should == domains.map { | domain | "-domain:#{ domain }" }
      end
    }    
    
  end

end
