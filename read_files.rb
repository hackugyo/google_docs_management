# coding: utf-8
require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Drive API Ruby Quickstart'
CLIENT_SECRETS_PATH = 'client_id.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "drive-ruby-quickstart.yaml")
SCOPE = [Google::Apis::DriveV3::AUTH_DRIVE,
         Google::Apis::DriveV3::AUTH_DRIVE_FILE,
         Google::Apis::DriveV3::AUTH_DRIVE_READONLY,
         Google::Apis::DriveV3::AUTH_DRIVE_METADATA_READONLY]
# Google::Apis.logger.level = Logger::DEBUG

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(
    client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(
      base_url: OOB_URI)
    puts "Open the following URL in the browser and enter the " +
         "resulting code after authorization"
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI)
  end
  credentials
end


class Google::Apis::DriveV3::Reply
  def to_json
    json = <<"EOS"
  {
    "kind": "#{kind}",
    "id": "#{id}",
    "createdTime": "#{created_time}",
    "modifiedTime": "#{modified_time}",
    "author": {
      "kind": "#{author.kind}",
      "displayName": "#{author.display_name}",
      "photoLink": "#{author.photo_link}",
      "me": #{author.me},
      "permissionId": "#{author.permission_id}",
      "emailAddress": "#{author.email_address}"
    },
    "htmlContent": "#{html_content}",
    "content": "#{content}",
    "deleted": #{deleted}
  }
EOS
  end
end

class Google::Apis::DriveV3::Comment
  def to_json
    replies_pp = replies.map { |r| r.to_json }
    json = <<"EOS"
{
  "kind": "#{kind}",
  "id": "#{id}",
  "createdTime": "#{created_time}",
  "modifiedTime": "#{modified_time}",
  "author": {
    "kind": "#{author.kind}",
    "displayName": "#{author.display_name}",
    "photoLink": "#{author.photo_link}",
    "me": #{author.me},
    "permissionId": "#{author.permission_id}",
    "emailAddress": "#{author.email_address}"
  },
  "htmlContent": "#{html_content}",
  "content": "#{content}",
  "deleted": #{deleted},
  "resolved": #{resolved},
  "quotedFileContent": {
    "mimeType": "#{quoted_file_content&.mime_type}",
    "value": "#{quoted_file_content&.value}"
  },
  "anchor": "#{anchor}",
  "replies": [
  #{replies_pp.join(',')}
  ]
}
EOS
  end
end

# Initialize the API
service = Google::Apis::DriveV3::DriveService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

FILE_ID = ARGV[0]

# response = service.list_files(page_size: 10,
#                              fields: 'nextPageToken, files')
# file = response.files.first { |element| element.id == FILE_ID }

file = service.get_file(FILE_ID, fields:'kind,id,name,mimeType,description,starred,trashed,parents,properties,appProperties,spaces,version,webContentLink,webViewLink,originalFilename,fullFileExtension,fileExtension,contentHints')
puts "#{file.name} (#{file.id})"

revision = service.get_revision(FILE_ID, 'head')
puts "revision: #{revision.id}"

comment_list = service.list_comments(FILE_ID, fields: 'comments').comments
comments = comment_list.map {|c| c.to_json }

format = 'plain'
puts 'https://docs.google.com/document/d/' + FILE_ID + '/export?format=' + format
# text = service.export_file(FILE_ID, 'text/' + format) # TODO: こいつをgithubにミラーする

puts comment_list.first.to_json

