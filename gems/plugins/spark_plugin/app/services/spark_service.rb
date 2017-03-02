class SparkService

  def self.create_spark(course_id, body, user_email)
    return post("#{spark_service_url.path}courses/#{course_id}/spark", body, user_email)
  end

  def self.get_spark(course_id, user_email)
    return get("#{spark_service_url.path}courses/#{course_id}/spark", user_email)
  end

  def self.delete_spark(course_id, user_email)
    return delete("#{spark_service_url.path}courses/#{course_id}/spark", user_email)
  end

  def self.create_spark_for_module(course_id, module_id, body, user_email)
    return post("#{spark_service_url.path}courses/#{course_id}/modules/#{module_id}/spark", body, user_email)
  end

  def self.create_whiteboard_link(course_id, module_id, body, user_email)
    return post("#{spark_service_url.path}courses/#{course_id}/modules/#{module_id}/whiteboard-snapshot", body, user_email)
  end

  def self.get(url, user_email)
    return JSON.parse(http.get(url, headers(user_email)).body)
  end

  def self.post(url, body, user_email)
    return http.post(url, JSON.dump(body), headers(user_email))
  end

  def self.delete(url, user_email)
    return http.delete(url, headers(user_email))
  end

  def self.http
    http = Net::HTTP.new(spark_service_url.host, spark_service_url.port)
    http.use_ssl = true if Rails.env.production?
    return http
  end

  def self.headers(user_email)
    {
      'Authorization' => 'Bearer ' + jwt(user_email),
      'Content-type' => 'application/json',
      'Accept' => 'text/json, application/json'
    }
  end

  def self.spark_service_url
    URI.parse("#{ENV['SPARK_SERVICE_URL']}/canvas/")
  end

  def self.jwt(user_email)
    expiry = Time.zone.now + 5.minutes.to_i
    body = {
      sub: user_email,
      iss: ENV['SPARK_JWT_ISS'],
      jti: SecureRandom.uuid
    }
    Canvas::Security.create_jwt(body, expiry, ENV['SPARK_JWT_SECRET'])
  end

end
