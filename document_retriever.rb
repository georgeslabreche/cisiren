require "net/http"
require "uri"
require 'rexml/document'
include REXML

class DocumentRetriever
	def get_xml_doc(uri, username, password)

		req = Net::HTTP::Get.new(uri.request_uri)
		req.basic_auth username, password

		res = Net::HTTP.start(uri.host, uri.port) {|http|
			http.request(req)
		}

		# return the doc
		return REXML::Document.new(res.body)
	end
end