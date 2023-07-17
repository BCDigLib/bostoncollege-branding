# These are the custom config overrides for this local instance of archivesspace

AppConfig[:feedback_url] = "https://libguides.bc.edu/burns/contact"
AppConfig[:pui_search_results_page_size] = 25
AppConfig[:enable_public] = true
AppConfig[:pui_hide][:repositories] = true
AppConfig[:pui_hide][:accessions] = true
AppConfig[:pui_hide][:subjects] = true
AppConfig[:pui_hide][:digital_objects] = true
AppConfig[:pui_hide][:classifications] = true
AppConfig[:pui_hide][:container_inventory] = true
AppConfig[:pui_page_actions_request] = false

# Include custom routes.rb file
Plugins::extend_aspace_routes(File.join(File.dirname(__FILE__), "routes.rb"))

# Add FAQ link to main nav
Plugins::add_menu_item('/faq', 'plugin.bostoncollege-branding.faq_menu_label')

## OVERRIDE VARIOUS METHODS/ ADD NEW METHODS
Rails.application.config.after_initialize do
  # most recent file version: v3.4.0
  # https://github.com/archivesspace/archivesspace/blob/v3.4.0/public/app/models/record.rb
  class Record
    # include "accessrestrict" in list of notes to fetch and render on search results page
    ABSTRACT = %w(abstract scopecontent accessrestrict)
  end

  # most recent file version: v3.4.0
  # https://github.com/archivesspace/archivesspace/blob/v3.4.0/public/app/controllers/search_controller.rb
  class SearchController < ApplicationController
    # remove "subjects" and "repository" facets from "Additional filters" list
    DEFAULT_SEARCH_FACET_TYPES = ['primary_type', 'published_agents', 'langcode']

    # remove "subject" from list of record types to search
    DEFAULT_TYPES = %w{archival_object digital_object digital_object_component agent resource repository accession classification}
  end

  # most recent file version: v3.4.0
  # https://github.com/archivesspace/archivesspace/blob/v3.4.0/public/app/controllers/resources_controller.rb
  class ResourcesController < ApplicationController
    # remove "subjects" from list of resource facet types
    DEFAULT_RES_FACET_TYPES = %w{primary_type published_agents langcode}
  end
  
  # most recent file version: v3.4.0
  # https://github.com/archivesspace/archivesspace/blob/v3.4.0/public/app/controllers/agents_controller.rb
  class AgentsController < ApplicationController
    # remove "subjects" from list of agent facet types
    DEFAULT_AG_FACET_TYPES = %w{primary_type}

    # remove "repository" from list of agent facet types, it was being added by default, see commented out code for context
    def index
      repo_id = params.fetch(:rid, nil)
      Rails.logger.debug("repo_id: #{repo_id}")
      if !params.fetch(:q, nil)
        DEFAULT_AG_SEARCH_PARAMS.each do |k, v|
          params[k] = v unless params.fetch(k, nil)
        end
      end
      search_opts = default_search_opts(DEFAULT_AG_SEARCH_OPTS)
      search_opts['fq'] = ["used_within_published_repository:\"/repositories/#{repo_id}\""] if repo_id
      @base_search = repo_id ? "/repositories/#{repo_id}/agents?" : '/agents?'
      default_facets = DEFAULT_AG_FACET_TYPES.dup
      # only use original DEFAULT_AG_FACET_TYPES values; don't add "repository" to list of facet types
      # default_facets.push('used_within_published_repository') unless repo_id
      page = Integer(params.fetch(:page, "1"))
  
      begin
        set_up_and_run_search( DEFAULT_AG_TYPES, default_facets, search_opts, params)
      rescue NoResultsError
        flash[:error] = I18n.t('search_results.no_results')
        redirect_back(fallback_location: '/') and return
      rescue Exception => error
        flash[:error] = I18n.t('errors.unexpected_error')
        redirect_back(fallback_location: '/agents') and return
      end
  
      @context = repo_context(repo_id, 'agent')
      if @results['total_hits'] > 1
        @search[:dates_within] = false
        @search[:text_within] = true
      end
  
      @page_title = I18n.t('agent._plural')
      @results_type = @page_title
      all_sorts = Search.get_sort_opts
      @sort_opts = []
      %w(title_sort_asc title_sort_desc).each do |type|
        @sort_opts.push(all_sorts[type])
      end
      if params[:q].size > 1 || params[:q][0] != '*'
        @sort_opts.unshift(all_sorts['relevance'])
      end
      @no_statement = true
      render 'search/search_results'
    end


  end
  
  # most recent file version: v3.4.0
  # https://github.com/archivesspace/archivesspace/blob/v3.4.0/public/app/controllers/objects_controller.rb
  class ObjectsController < ApplicationController
    # remove "subjects" from list of object facet types
    DEFAULT_OBJ_FACET_TYPES = %w(repository primary_type published_agents langcode)
  end

end
