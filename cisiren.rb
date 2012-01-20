require_relative 'document_retriever'
require_relative 'morse_encoder'
require_relative 'morse_light_thread'
require_relative 'light_controller'

class CiSiren

  # The message we want the red light to send out when the build fails
  BUILD_FAIL_MORSE_MESSAGE = "SOS CQ"
  
  BUILD_STATE_LIGHT_MAP = {
    "Successful Build" => "GREEN",
    "Failed Build" => "RED",
    "Building" => "YELLOW",
    "Off" => "OFF"
	}

  def initialize
  	morse_encoder = MorseEncoder.new
  	@morse_msg = morse_encoder.encode(BUILD_FAIL_MORSE_MESSAGE);
  	
  	@doc_retriever = DocumentRetriever.new
  	
  	@build_status_rss_feed_uri =  URI('http://tools.dev.nymag.biz/httpAuth/feed.html?buildTypeId=bt6&itemsType=builds&userKey=1326404101969')
  	@uri_request_username = ""
  	@uri_request_password = ""
  	
  	@light_controller = LightController.new
  end
  
  def doc_retriever
  	@doc_retriever
  end
  
  def morse_msg
  	@morse_msg
  end
  
  def light_thread
  	@light_thread
  end
  
  def light_thread=(val)
    @light_thread = val
  end
  
  def build_status_rss_feed_uri
  	@build_status_rss_feed_uri
  end
  
  def uri_request_username
  	@uri_request_username
  end
  
  def uri_request_password
  	@uri_request_password
  end

  def run

  	while true	
		
		# First we want to check if the trunk is currently building.
		# Unfortunately, the build status rss feed only informs us if a build has been successful or if it has failed. It doesn't inform us if there is a build in progress.
		# Because of this, we need to look elsewhere to get that data: the build branch page.
	
		# The build branch page displays the current status of the build.
		# When a build is in progress, the current status is "Running 1 build".
		# When no build is in progress, the current status is "Idle": <span id="runningStatusTextIdbt6">Idle</span>

		# The value of the current status is displaedy in a span element which has the "runningStatusTextIdbt6" id.
	
		# So, what we want to do is retrieve that span element and check its text value:
		# 	- If it's equal to "Idle" then there is no build in progress
		#	- If it's not equal to "Idle", there there is a build in progress.
	
		# TODO: implementation of  finding out if build is in progress

		# create xml document build branch page 
		# doc = doc_retriever.get_xml_doc(build_branch_page_uri, username, password)
	
		# retrieve build provress which is the value of the current status span element
		#build_progress = XPath.first(doc, "//span[contains(., 'Idle')]").to_s
	
		#p build_progress
	
	
		# If there is no build in progress, let's check the build state:

		# create xml document of rss feed
		doc = doc_retriever.get_xml_doc(build_status_rss_feed_uri, uri_request_username, uri_request_password)

		# Get the values we are interested in that will allow us to determine the status of the feed
		#title = XPath.first(doc, '//entry/title').text()
		name_xml_element = XPath.first(doc, "//entry/author/name")
		
	
		if name_xml_element != nil
			build_status_text = name_xml_element.text()
	
			light_color_key = BUILD_STATE_LIGHT_MAP[build_status_text]
	
			if build_status_text == "Successful Build"
				switch_on_success_light(light_color_key)
		
			elsif build_status_text == "Failed Build"
				manage_build_failure_light_thread(morse_msg, light_color_key)
			end
			
		end
		
		# wait a second  before polling again
		sleep 1
		
	end
		
  end
  
  def manage_build_failure_light_thread(morse_msg, light_color_key)
  
  	# If the light thread hasn't been created or has been destroy, then create a new one and run it
  	if @morse_light_thread.nil?
		@thread = Thread.new { 
			@morse_light_thread = MorseLightThread.new(morse_msg, light_color_key)
			@morse_light_thread.run
		}
	end
  end
  
  def switch_on_success_light(light_color_key)
  	
  	# stop the build failure thread
  	if !@morse_light_thread.nil?

  		# Stop running the endless loop that is managing the error light
		@morse_light_thread.running = false
		
		# Wait until that thread running the loop stops running
		if !@thread.nil?
			# kill the thread
			@thread.kill
			while !@thread.status
				# wait for thread to stop
			end
			
			# destroy the thread object
			@thread = nil
		end
		
		# Destroy the object the thread was running
		@morse_light_thread = nil
	end
	
	# Make light display success color light
	@light_controller.light(light_color_key)
	
  end
  
end