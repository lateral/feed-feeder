# encoding: UTF-8
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'aws/s3'
require 'fog/google'
require 'open-uri'
require 'open_uri_redirections'
require 'pg'
require 'rmagick'
require 'tempfile'
require 'parallel'
require 'dotenv/load'


config = OpenStruct.new(
  db: {
    dbname: ENV['DB_DATABASE'],
    host: ENV['DB_HOST'],
    port: ENV['DB_PORT'],
    password: ENV['DB_PW'],
    user: ENV['DB_USERNAME']
  },
  fog: {
    google_json_key_location: ENV['GOOGLE_CREDS_LOCATION'],
    google_project: ENV['GOOGLE_PROJECT'],
  }
)

fog = Fog::Storage::Google.new config.fog
bucket = fog.directories.get(ENV['GOOGLE_BUCKET_NAME'])

conn = PG.connect config.db
conn.prepare('mark_added', 'UPDATE items SET image_thumbnail = true WHERE id = $1')
conn.prepare('remove_image', 'UPDATE items SET image = NULL WHERE id = $1')

rows = conn.exec('SELECT id, image FROM items WHERE image_thumbnail IS false AND ' \
		 " created_at > '2018-06-17 00:00:00' AND " \
                 "image IS NOT NULL AND image != '' AND rejected_by_api IS false ORDER BY published DESC")
# images = rows.map { |row| { id: row['id'].to_i, url: row['image'] } }

print 'Number of rows to process:'
print rows.count

def exception(id, e, conn)
  # Remove image if bad response
  if e.message == '403 Forbidden' || e.message == '401 Authorization Required' || e.message == '400 Bad Request'
    ap "Bad response from ID #{id}"
    conn.exec_prepared('remove_image', [id])
  else
    ap "Error parsing  #{id}"
    ap e.message
    ap e.backtrace
    if e.respond_to?(:io)
      ap '----------------'
      response = e.io
      ap response.string
    end
    conn.exec_prepared('remove_image', [id])
  end
end

rows.each do |row|
  ap "Processing ##{row['id']}"

  begin
    # Create temp file
    tmp = Tempfile.new([row['id'].to_s, '.jpg'])

    # Go to next if it takes longer than 60s
    Timeout::timeout(60) do
      # Get the image from the URL
      begin
        ua = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36'
        begin
          urlimage = open(URI.parse(URI.encode(row['image'].strip)), allow_redirections: :safe, 'User-Agent' => ua).read
        rescue
          urlimage = open(row['image'], allow_redirections: :safe, 'User-Agent' => ua).read
        end

      # Handle HTTP error
      rescue OpenURI::HTTPError => e

        # Remove the image if it 404s
        response = e.io
        conn.exec_prepared('remove_image', [row['id']]) if response.status[0] == '404'

        # Skip this row for now if there was an HTTP error
        exception(row['id'], e, conn)
        next
      end

      # Crop the image with RMagick
      image = Magick::ImageList.new
      image.from_blob(urlimage)
      image = image.resize_to_fill(100, 100)
      image.format = 'jpeg'

      # Write to tmp file
      image.write(tmp.path)
      tmp.close

      # Optimise tmp image
      `/usr/bin/jpegoptim --max=70 #{tmp.path}`

      # Write to google cloud storage
      bucket.files.create key: "#{row['id']}.jpg", content_type: 'image/jpeg',
                          body: open(tmp.path), public: true
      tmp.unlink

      conn.exec_prepared('mark_added', [row['id']])
      ap "Saved as #{row['id']}.jpg"
    end

  rescue => e
    tmp.unlink
    exception(row['id'], e, conn)
  end
end
