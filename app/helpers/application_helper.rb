require "net/http"
require 'open-uri'

module ApplicationHelper
    class MarketoRepository
        # http request to return a new mkto access_token 
        def get_marketo_token
            begin
                # http location
                _query_string = "?munchkin_id=#{Config.get_munchkinId}&client_id=#{Config.get_clientId}&client_secret=#{Config.get_secret}&grant_type=#{Config.get_grant_type}"
                _tokenURL = URI.encode(Config.get_base_url + _query_string)
                # http call
                @data = URI.parse(_tokenURL).read
                return JSON.parse(@data)["access_token"]
            rescue => ex
                return "failed: " + ex.message
            end
        end

        # method to generate lead in mkto, requires access_token => get_marketo_token
        def upsert_marketo_lead(params)
            # todo: verify required fields? perhaps get form fields and validation logic from marketo?
            # removing params included by rails
            params.delete :action
            params.delete :controller
            params.delete :marketo_form
            # parse incoming values to json
            body = {
                #"action"=>"createOnly",
                "lookupField"=>"email",
                "input"=>[params]
            }.to_json
            @body = body
            # set post uri
            uri = URI(Config.get_create_lead_url)
            # setup http request
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            uri.query = "access_token=#{get_marketo_token}"
            request = Net::HTTP::Post.new(uri,  { 'Content-Type' => 'application/json' })
            request.body = @body
            # make http request
            response = http.request(request)
            return response.body
        end

        def get_marketo_lead(params)
            # parse incoming values to json
            cookie = URI::escape(params[:cookie])
            # set post uri
            uri = URI(Config.get_marketo_lead_url)
            uri.query = "filterType=cookie&filterValues=#{cookie}&access_token=#{get_marketo_token}"
            # setup http request
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            request = Net::HTTP::Get.new(uri,  { 'Content-Type' => 'application/json' })
            # make http request
            response = http.request(request)
            return response.body
        end
    end

    # Configuration Class
    class Config
        def self.get_munchkinId
            return "058-NIT-467"
        end
        def self.get_base_url
            return "https://#{self.get_munchkinId}.mktorest.com/identity/oauth/token"
        end
        def self.get_create_lead_url
            return "https://#{self.get_munchkinId}.mktorest.com/rest/v1/leads.json"
        end
        def self.get_marketo_lead_url
            return "https://#{self.get_munchkinId}.mktorest.com/rest/v1/leads.json"
        end        
        def self.get_clientId
            return "50966f4b-ce8b-425b-b9c1-282676733428"
        end
        def self.get_secret
            return "AfO3Ck7BETd5JGsikenPeimpj9fdfgEY"
        end                
        def self.get_grant_type
            return "client_credentials"
        end        
    end
end
