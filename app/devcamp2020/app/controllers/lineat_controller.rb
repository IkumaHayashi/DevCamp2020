require 'aws-sdk'
require 'line/bot'
require 'net/http'
require 'uri'

class LineatController < ApplicationController

  protect_from_forgery :except => [:callback]

  def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Image
          logger.debug('画像キタコレ')
          logger.debug(event.to_yaml)
          local_file_path = download_line_image(event.message['id'])
          upload(event.message['id'], local_file_path)
          FileUtils.rm(local_file_path)
        end
      end
    }

    head :ok
  end

  def download_line_image(message_id)
    uri = URI.parse("https://api.line.me/v2/bot/message/#{message_id}/content")
    logger.debug(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === "https"

    
    headers = { "Authorization" => "Bearer " + ENV["LINE_CHANNEL_TOKEN"] }
    response = http.get(uri.path, headers)

    file_path =  Rails.root.to_s + "/tmp/storage/#{message_id}"
    file = File.open(file_path, "w+b") # 新規作成書き込みモード
    file.write(response.body)
    file.close

    extension = image_type(file_path)
    File.rename(file_path, file_path + '.' + extension)

    file_path + '.' + extension 

  end

  def image_type(file_path)
    File.open(file_path, 'rb') do |f|
      begin
        header = f.read(8)
        f.seek(-12, IO::SEEK_END)
        footer = f.read(12)
      rescue
        return nil
      end
  
      if header[0, 2].unpack('H*') == %w(ffd8) && footer[-2, 2].unpack('H*') == %w(ffd9)
        return 'jpg'
      elsif header[0, 3].unpack('A*') == %w(GIF) && footer[-1, 1].unpack('H*') == %w(3b)
        return 'gif'
      elsif header[0, 8].unpack('H*') == %w(89504e470d0a1a0a) && footer[-12,12].unpack('H*') == %w(0000000049454e44ae426082)
        return 'png'
      end
    end
    nil
  end

  def upload(dir_name, image_path)
    s3 = Aws::S3::Resource.new(region: 'ap-northeast-1')
    bucket = ENV['AWS_S3_LINE_BUCKET_NAME']
    bucket = s3.bucket('devcamp2020')
    obj = bucket.object(dir_name + '/' + File.basename(image_path))
    obj.upload_file(image_path)
  end


end
