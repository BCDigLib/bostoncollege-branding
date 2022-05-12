## OVERRIDE VARIOUS METHODS/ ADD NEW METHODS
Rails.application.config.after_initialize do
  class Record
    # include accessrestrict in list of notes to fetch and render on search results page
    ABSTRACT = %w(abstract scopecontent accessrestrict)
  end
end