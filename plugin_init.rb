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
  end
end