#!/usr/bin/env ruby

require 'optparse'
require 'rest-client'
require 'csv'
require 'json'

# This will hold the options we parse
options = {}

OptionParser.new do |parser|
  parser.on("-u", "--user USERNAME", "Jira username") do |v|
    options[:username] = v
  end
  parser.on("-p", "--pass PASSWORD", "Jira password") do |v|
    options[:password] = v
  end
  parser.on("-j", "--jira JIRA_BASE_URL", "Jira base URL") do |v|
    options[:jira_url] = v
  end
  parser.on("-c", "--csv CSV_FILE", "CSV file") do |v|
    options[:csv] = v
  end
  parser.on("-s", "--summary SUMMARY", "Test Execution summary") do |v|
    options[:summary] = v
  end
  parser.on("-d", "--description DESCRIPTION", "Test Execution description") do |v|
    options[:description] = v
  end
  parser.on("-v", "--version VERSION", "Version") do |v|
    options[:version] = v
  end
  parser.on("-r", "--revision REVISION", "Revision") do |v|
    options[:revision] = v
  end
  parser.on("-t", "--testplan TEST_PLAN", "Test Plan issue key") do |v|
    options[:plan] = v
  end 
  parser.on("-e", "--environment TEST_ENVIRONMENT", "Test Environment") do |v|
    options[:environment] = v
  end 
end.parse!


endpoint_url = "#{options[:jira_url]}/rest/raven/1.0/import/execution"  
headers = { "Content-Type" => "application/json"}

rows = CSV.read(options[:csv],{:col_sep => ";", :row_sep => :auto })
description = ""

json = { "info" => { "summary" => options[:summary], "version" => options[:version], "description" => (options[:description] || "")}}
json["info"]["revision"] = options[:revision] if !options[:revision].nil? && !options[:revision].empty?
json["info"]["version"] = options[:version] if !options[:version].nil? && !options[:version].empty?
json["info"]["testPlanKey"] = options[:plan] if !options[:plan].nil? && !options[:plan].empty?
json["info"]["testEnvironments"] = [ options[:environment] ] if !options[:environment].nil? && !options[:environment].empty?
json["tests"] = []

first_row_with_tests = 1
test_key_col = 1
status_col = 9
comment_col = 10
step_number_col = 5 
step_status_col = 9
step_comment_col = 10

last_test_key = nil
test_info = {}

rows.each_with_index do |row,idx|
 if idx >= first_row_with_tests

 		# inside some test related info?
 		if !row[test_key_col].nil? &&  (row[test_key_col] =~ /^\w+\-\d+$/)  # !row[test_key_col].empty?

 			# changed test key and has test related info to commit? then add it to the json object
 			if (row[test_key_col] != last_test_key) && !test_info.empty?
 				json["tests"] << test_info
 				test_info = {}
 			end

 			# is it step info or global test run info
 			if !row[step_number_col].nil? && !row[step_number_col].empty?
 				step_info = { "status" => row[step_status_col]}
 				step_info["comment"] = row[step_comment_col] if !row[step_comment_col].nil? && !row[step_comment_col].empty?
 				test_info["steps"] = [] if test_info["steps"].nil?
 				test_info["steps"] << step_info
 			else
 				# test run global row
 				test_info = { "testKey" => row[test_key_col], "status" => row[status_col]}
 				test_info["comment"] = row[comment_col] if !row[comment_col].nil? && !row[comment_col].empty?
 				#puts test_info

 			end

 		else

 			# has test related info to commit? then add it to the json object
 			if !test_info.empty?
 				json["tests"] << test_info
 			end
 			test_info = {}
 		end

 	last_test_key = row[test_key_col]
 end

end

puts json.to_json
RestClient::Request.execute method: :post, url: endpoint_url, user: options[:username] , password: options[:password],  headers: headers, payload: json.to_json

