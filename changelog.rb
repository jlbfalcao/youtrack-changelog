
require 'rubygems'
require 'bundler/setup'
require 'erb'
Bundler.require

project = ARGV[0]
version_bundler = ARGV[1]
base_url = ARGV[2]
login = ARGV[3]
password = ARGV[4]

p base_url

conn = Faraday.new(:url => base_url) do |faraday|
  faraday.request  :url_encoded
  faraday.adapter  Faraday.default_adapter
  # faraday.response :logger
end
conn.ssl[:verify] = false

# login
res = conn.post 'rest/user/login' do |req|
  req.params.update \
    :login => login,
    :password => password
  req.headers['Content-Length'] = '0'
end
conn.headers['Cookie'] = res.headers['set-cookie']
conn.headers['Cache-Control'] = 'no-cache'

# load all released versions.
response = conn.get "rest/admin/customfield/versionBundle/#{version_bundler}"
versions = []
REXML::Document.new(response.body).root.each_element do |version|
  # REXML::Document.new(response.body).root.elements.each '//version[@released="true"]' do |version|
  versions << version.text
end

# load all issues
issues = {}
versions.each do |version|
  response = conn.get 'rest/issue', \
    filter: "project: #{project} Fix versions: #{version} Affected versions: -#{version} visible to: {All Users} Type: Feature , Bug, Improvement order by: Type, Priority"
  issues[version] = REXML::Document.new(response.body).root.elements.to_a.map do |issue|
    {
      id: issue.attributes['id'],
      summary: issue.elements['field[@name="summary"]/value'].text,
      type: issue.elements['field[@name="Type"]/value'].text
    }
  end
end

params = {}
File.open('changelog.html', 'w') {|f| f.write(ERB.new(File.new('views/changelog.erb').read).result) }

# require 'sinatra'
# get '/changelod' do
#   erb :changelog
# end


