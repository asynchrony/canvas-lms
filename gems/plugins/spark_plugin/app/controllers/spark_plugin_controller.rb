class SparkPluginController < ApplicationController
  def enable_spark
    http = Net::HTTP.new(michelangelo_url.host, michelangelo_url.port)
    response = http.post(
      michelangelo_url.path,
      JSON.dump(spark_params),
      'Content-type' => 'application/json',
      'Accept' => 'text/json, application/json')

    respond_to do |format|
      format.html { redirect_to :back, notice: response_message(response.code) }
    end
  end

  def spark_params
    { courseId: course_id, courseCode: course_code, email: user_email }
  end

  def course_code
    permitted_params[:course_code]
  end

  def user_email
    @current_user.email
  end

  def course_id
    params[:id]
  end

  def response_message(code)
    status_code = code.to_i
    return "Processing enablement of Spark for #{course_code}, please refresh momentarily" if status_code == 202
    return "Spark has been enabled for #{course_code}" if (status_code >= 200 && status_code < 300)
    "Failed to enable Spark for #{course_code} (error code #{status_code})"
  end

  def michelangelo_url
    URI.parse("#{ENV['MICHELANGELO_URL']}/canvas/enable-spark")
  end

  def permitted_params
    strong_params.require(:course).permit(:course_code)
  end

end
