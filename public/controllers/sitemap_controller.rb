class SitemapController < ApplicationController
    
    def generate
        @ASPACE_PUBLIC_URL = 'http://localhost:8081'
   
        @sitemap_agents = ["/agents/people/1450", "agents/people/1451"];
        @sitemap_resources = ["/repositories/2/resources/390"];
        @sitemap_digitalobjects = ["/repositories/2/digital_objects/2691"];

        render "sitemap"
    end
end