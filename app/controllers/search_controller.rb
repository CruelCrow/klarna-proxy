require 'net/http'

class SearchController < ActionController::Base
  protect_from_forgery with: :exception

  def search
    url = URI.parse("#{ENV['KLARNA_API_URL']}/people/search?name=#{params[:name]}&age=#{params[:age]}&phone=#{params[:phone]}&page=#{params[:page]}")
    req = Net::HTTP::Post.new(url.to_s)
    req['X-KLARNA-TOKEN'] = ENV['X_KLARNA_TOKEN']
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }

    if res.code == '201'
      new_results_id = JSON.parse(res.body)['id']

      while true
        url = URI.parse("#{ENV['KLARNA_API_URL']}/people?searchRequestId=#{new_results_id}")
        req = Net::HTTP::Get.new(url.to_s)
        req['X-KLARNA-TOKEN'] = ENV['X_KLARNA_TOKEN']
        begin
          res = Net::HTTP.start(url.host, url.port) {|http|
            http.request(req)
          }
        rescue EOFError => e
          next
        end
        if res.code == '102'
          sleep 0.5
          next
        elsif res.code == '200'
          if res.body.empty?
            sleep 0.5
            next
          else
            render json: {
                request_params: {
                    name: params[:name],
                    age: params[:age],
                    phone: params[:phone],
                    page: params[:page]
                },
                persons: JSON.parse(res.body)
            }
            return
          end
        end
      end
    else
      render status: res.code, json: {}
      return
    end

    render json: {}
  end
end
