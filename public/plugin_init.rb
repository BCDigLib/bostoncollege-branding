# These are the custom config overrides for this local instance of archivesspace
AppConfig[:enable_public] = true
AppConfig[:pui_hide][:repositories] = true
AppConfig[:pui_hide][:accessions] = true
AppConfig[:pui_hide][:subjects] = true
AppConfig[:pui_hide][:classifications] = true
AppConfig[:pui_hide][:container_inventory] = true
AppConfig[:pui_page_actions_request] = false
AppConfig[:request_list] = {
  :button_position => 0,
  :record_types => ['archival_object', 'resource', 'top_container'],
  :request_handlers => {
    :harvard_aeon => {
      :name => 'Harvard Aeon',
      :profile => :harvard_aeon,
      :url => 'https://burnsaccount.bc.edu/logon?Action=11&Form=31',
      :list_opts => {
        :return_link_label => 'Return to Search Burns Archives',
        :form_target => 'RequestForm',
        :aeon_link_url => 'https://burnsaccount.bc.edu/logon',
        :request_types => {
          'Visit' => {
            'RequestType' => 'Loan',
            'UserReview' => 'No',
            'SkipOrderEstimate' => '',
          },
           'Copy' => {
            'RequestType' => 'Copy',
            'UserReview' => 'No',
            'SkipOrderEstimate' => 'Yes',
          }
        },
        :format_options => [
                            'Reference PDF (1 week)',
                            'Reference JPG (1 week)'
                           ],
        :delivery_options => [
                              'Download'
                             ]
      }
    }
  },
  :repositories => {
    :default => {
      :handler => :harvard_aeon,
    },
  }
}


## OVERRIDE VARIOUS METHODS/ ADD NEW METHODS
Rails.application.config.after_initialize do
  # most recent file version: v3.2.0
  # https://github.com/archivesspace/archivesspace/blob/v3.2.0/public/app/models/record.rb
  class Record
    # include "accessrestrict" in list of notes to fetch and render on search results page
    ABSTRACT = %w(abstract scopecontent accessrestrict)
  end

  # most recent file version: v3.2.0
  # https://github.com/archivesspace/archivesspace/blob/v3.2.0/public/app/controllers/search_controller.rb
  class SearchController < ApplicationController
    # remove "subjects" and "repository" facets from "Additional filters" list
    DEFAULT_SEARCH_FACET_TYPES = ['primary_type', 'published_agents', 'langcode']

    # remove "subject" from list of record types to search
    DEFAULT_TYPES = %w{archival_object digital_object digital_object_component agent resource repository accession classification}
  end

  # most recent file version: v3.2.0
  # https://github.com/archivesspace/archivesspace/blob/v3.2.0/public/app/controllers/resources_controller.rb
  class ResourcesController < ApplicationController
    DEFAULT_RES_FACET_TYPES = %w{primary_type published_agents langcode}
  end
  
  # most recent file version: v3.2.0
  # https://github.com/archivesspace/archivesspace/blob/v3.2.0/public/app/controllers/agents_controller.rb
  class AgentsController < ApplicationController
    DEFAULT_AG_FACET_TYPES = %w{primary_type}
  end
  
  # most recent file version: v3.2.0
  # https://github.com/archivesspace/archivesspace/blob/v3.2.0/public/app/controllers/objects_controller.rb
  class ObjectsController < ApplicationController
    DEFAULT_OBJ_FACET_TYPES = %w(repository primary_type published_agents langcode)
  end

end