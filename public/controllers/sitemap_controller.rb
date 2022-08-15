class SitemapController < ApplicationController
    
    def generate
        @aspace_public_url = 'http://localhost:8081'
   
        @sitemap_agents = ["/agents/people/1450", "agents/people/1451","/agents/people/1452","/agents/people/1453","/agents/people/1454"];
        @sitemap_resources = ["/repositories/2/resources/390", "/repositories/2/resources/391", "/repositories/2/resources/392", "/repositories/2/resources/393","/repositories/2/resources/394"];
        @sitemap_digitalobjects = ["/repositories/2/digital_objects/2690","/repositories/2/digital_objects/2691","/repositories/2/digital_objects/2692","/repositories/2/digital_objects/2693","/repositories/2/digital_objects/2694"];

        @sitemap_agents.each do |agent|
            File.write('sitemap.xml', "#{agent}\n", mode:'a')
        end

        render "sitemap"
    end
end