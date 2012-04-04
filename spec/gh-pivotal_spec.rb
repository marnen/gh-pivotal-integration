require 'gh-pivotal'
require 'rack/test'
require "rspec"
require 'base64'

ENV['RACK_ENV'] = 'test'

describe "Integration" do
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end
  
  describe  "Pivotal-Github integration" do
    it "posts issue state changes" do
      post "/issues", <<-xml
      <activity>
        <id type="integer">1031</id>
        <version type="integer">175</version>
        <event_type>story_update</event_type>
        <occurred_at type="datetime">2009/12/14 14:12:09 PST</occurred_at>
        <author>James Kirk</author>
        <project_id type="integer">26</project_id>
        <description>James Kirk accepted &quot;More power to shields&quot;</description>
        <stories>
          <story>
            <id type="integer">109</id>
            <url>https:///projects/26/stories/109</url>
            <accepted_at type="datetime">2009/12/14 22:12:09 UTC</accepted_at>
            <current_state>accepted</current_state>
          </story>
        </stories>
      </activity>
      xml
      last_response.ok?.should be_true 
    end
  end

  describe "Github-Pivotal Integration" do
    it "exposes github issues as pivotal activities" do
      get "/issues/zauberlabs/zauber-crono", {:Authorization  => "Basic #{Base64.encode64('admin:admin')}" }
      last_response.ok?.should be_true
      last_response.body.should == 
         <<-xml
         <?xml version="1.0"?>
         <external_stories type="array">
           <external_story>
             <external_id>zauberlabs/zauber-crono/issues/1</external_id>
             <name>El active_from de un proyecto, se actualiza a la &#xFA;ltima observacion</name>
             <description></description>
             <requested_by>mcortesi</requested_by>
             <created_at type="datetime">2012-03-30T22:00:56Z</created_at>
             <story_type>bug</story_type>
             <estimate>0</estimate>
           </external_story>
         </external_stories>
         xml
    end
  end
end
