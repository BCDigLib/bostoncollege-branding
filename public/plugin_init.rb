## OVERRIDE VARIOUS METHODS/ ADD NEW METHODS
Rails.application.config.after_initialize do
  class Record
    # include accessrestrict in list of notes to fetch and render on search results page
    ABSTRACT = %w(abstract scopecontent accessrestrict)
  end

  class SearchController < ApplicationController
    # remove "Subjects" facet from "Additional filters" list
    DEFAULT_SEARCH_FACET_TYPES = ['primary_type', 'published_agents', 'langcode']
  end

  class ResourcesController < ApplicationController
    DEFAULT_RES_FACET_TYPES = %w{primary_type published_agents langcode}
  end

  class AgentsController < ApplicationController
    DEFAULT_AG_FACET_TYPES = %w{primary_type}
  end

  class ObjectsController < ApplicationController
    DEFAULT_OBJ_FACET_TYPES = %w(repository primary_type published_agents langcode)
  end
end