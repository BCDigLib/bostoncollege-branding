# These are the custom config overrides for this local instance of archivesspace

AppConfig[:feedback_url] = "https://libguides.bc.edu/burns/contact"
AppConfig[:pui_search_results_page_size] = 25
AppConfig[:enable_public] = true
AppConfig[:pui_hide][:repositories] = true
AppConfig[:pui_hide][:accessions] = true
AppConfig[:pui_hide][:subjects] = true
AppConfig[:pui_hide][:digital_objects] = false
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

  class WelcomeController < ApplicationController
    # override current welcome page display
    def metadata
      md = {
            '@context' => "http://schema.org/",
            '@type' => 'ArchiveOrganization',
            '@id' => AppConfig[:public_proxy_url] + @result['uri'],
            #this next bit will always be the repo name, not the name associated with the agent record (which is overwritten if the repo record is updated)
            'name' => @result['agent_representation']['_resolved']['display_name']['sort_name'],
            'url' => @result['url'],
            'logo' => @result['image_url'],
            #this next bit will never work since ASpace has a bug with how it enacts its repo-to-agent concept (at least in versions 2.4 and 2.5).... and you can't add an authority ID directly to a repo record.
            'sameAs' => @result['agent_representation']['_resolved']['display_name']['authority_id'],
            'parentOrganization' => {
              '@type' => 'Organization',
              'name' => @result['parent_institution_name']
            }
            # removing contactPoint, since this would need to be on the repo record (along with different contact types... e.g. reference assistance, digitization requests, whatever)
            # 'contactPoint' => @result['agent_representation']['_resolved']['agent_contacts'][0]['name']
          }

      if @result['org_code']
        if @result['country']
          md['identifier'] = @result['country']+'-'+ @result['org_code']
        else
          md['identifier'] = @result['org_code']
        end
      end

      if @result['repo_info']

        md['description'] = @result['repo_info']['top']['description'] if @result['repo_info']['top'] && @result['repo_info']['top']['description']
        md['email'] = @result['repo_info']['email'] if @result['repo_info']['email']

        if @result['repo_info']['telephones']
          md['faxNumber'] = @result['repo_info']['telephones']
            .select {|t| t['number_type'] == 'fax'}
            .map {|f| f['number']}

          md['telephone'] = @result['repo_info']['telephones']
            .select {|t| t['number_type'] == 'business'}
            .map {|b| b['number']}
        end

        if @result['repo_info']['address']
          md['address'] = {
            '@type' => 'PostalAddress',
            'streetAddress' => @result['repo_info']['address'].join(", "),
            'addressLocality' => @result['repo_info']['city'],
            'addressRegion' => @result['repo_info']['region'],
            'postalCode' => @result['repo_info']['post_code'],
            'addressCountry' => @result['repo_info']['country']
          }
        end
      end

      md.compact
    end

    def show
      @page_title = I18n.t 'brand.welcome_page_title'
      @search = Search.new(params)
      uri = "/repositories/2"
      resources = {}
      query = "(id:\"#{uri}\" AND publish:true)"
      @counts = get_counts("/repositories/2")
      @criteria = {}
      @criteria[:page_size] = 1
      @data = archivesspace.search(query, 1, @criteria) || {}
      if !@data['results'].blank?
        @result = ASUtils.json_parse(@data['results'][0]['json'])
        @badges = Repository.badge_list(@result['repo_code'].downcase)
        @badges.delete('classification')
        @badges.delete('accession')
        @badges.delete('subject')
        # make the repository details easier to get at in the view
        if @result['agent_representation']['_resolved'] && @result['agent_representation']['_resolved']['jsonmodel_type'] == 'agent_corporate_entity'
          @result['repo_info'] = process_repo_info(@result)
        end
        @sublist_action = "/repositories/2/"
        @result['count'] = resources
        #@page_title = strip_mixed_content(@result['name'])
        @search = Search.new(params)

        render

      else
        record_not_found(uri, 'repository')
      end
    end

    private

    # get counts of various records belonging to a repository
    def get_counts(repo_uri)
      types = %w(pui_collection pui_archival_object pui_record_group pui_accession pui_digital_object pui_agent pui_agent_family pui_subject)
      counts = archivesspace.get_types_counts(types, repo_uri)
      # 'pui_record' as defined in AppConfig ('record_badge') is intended for archival objects only,
      # which in solr is 'pui_archival_object' not 'pui_record' so we need to flip it here
      counts['pui_record'] = counts.delete 'pui_archival_object'
      final_counts = {}
      counts.each do |k, v|
        # there is a special case required for agent records - we need to add in counts for family
        # types for the badge, because the list page ends up including them both
        if k == 'pui_agent_family'
          final_counts['agent'] += v
        else
          final_counts[k.sub("pui_", '')] = v
        end
      end
      final_counts['resource'] = final_counts['collection']
      final_counts['classification'] = final_counts['record_group']
      final_counts
    end

     # extract the repository agent info
    def process_repo_info(repo)
      info = {}
      info['top'] = {}
      unless repo.nil?
        %w(name uri url parent_institution_name image_url repo_code description).each do |item|
          info['top'][item] = repo[item] unless repo[item].blank?
        end
        unless repo['agent_representation'].blank? || repo['agent_representation']['_resolved'].blank? || repo['agent_representation']['_resolved']['agent_contacts'].blank? || repo['agent_representation']['_resolved']['jsonmodel_type'] != 'agent_corporate_entity'
          in_h = repo['agent_representation']['_resolved']['agent_contacts'][0]
          %w{city region post_code country email }.each do |k|
            info[k] = in_h[k] if in_h[k].present?
          end
          if in_h['address_1'].present?
            info['address'] = []
            [1, 2, 3].each do |i|
              info['address'].push(in_h["address_#{i}"]) if in_h["address_#{i}"].present?
            end
          end
          info['telephones'] = in_h['telephones'] if !in_h['telephones'].blank?
        end
      end
      info
    end
  end
end
