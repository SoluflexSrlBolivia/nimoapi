class Api::V1::ReportsController < Api::V1::BaseController
  before_filter :authenticate_user!

  def_param_group :ruser do
    param :report, Hash, :required => true do
      param :user_id, Fixnum, :desc => "ID del usuario denunciado", :required => true
      param :group_id, Fixnum, :desc => "ID del grupo implicado", :required => true
      param :informer_id, Fixnum, :desc => "ID del usuario reportador", :required => true
    end
  end
  def_param_group :rpost do
    param :report, Hash, :required => true do
      param :post_id, Fixnum, :desc => "ID del post denunciado", :required => true
      param :group_id, Fixnum, :desc => "ID del grupo implicado", :required => true
      param :informer_id, Fixnum, :desc => "ID del usuario reportador", :required => true
    end
  end
  def_param_group :rarchive do
    param :report, Hash, :required => true do
      param :archive_id, Fixnum, :desc => "ID del archivo denunciado", :required => true
      param :group_id, Fixnum, :desc => "ID del grupo implicado", :required => true
      param :informer_id, Fixnum, :desc => "ID del usuario reportador", :required => true
    end
  end

  api! "Reportar Usuario"
  param_group :ruser
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 404, 'Not found'
  example "Response" + '
  {
    "status":"ok"
  }'
  def user
    report = ReportUser.find(report_params)
    if report.nil?
      report = ReportUser.new(report_params)
    end

    return api_error(status: 422, errors: report.errors) unless report.valid?

    report.save!

    render(
        json: {:status=>"ok"}
    )

  end

  api! "Reportar Post"
  param_group :rpost
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 404, 'Not found'
  example "Response" + '
  {
    "status":"ok"
  }'
  def post
    report = ReportPost.find(report_params)
    if report.nil?
      report = ReportPost.new(report_params)
    end

    return api_error(status: 422, errors: report.errors) unless report.valid?

    report.save!

    render(
        json: {:status=>"ok"}
    )
  end

  api! "Reportar Archivo"
  param_group :rarchive
  meta :header => "Authorization:Token token=pU7SOyDNY+URPeGZHlE/knqWzv131oTPOf/t3aXs+mM5x0zGrQfbi+5lGasQl47A6HaLTaPNUbN9KJQ2hA7QYw==, email=demo@gmail.com"
  error 401, "Bad credentials"
  error 403, "not authorized"
  error 404, 'Not found'
  example "Response" + '
  {
    "status":"ok"
  }'
  def archive
    report = ReportArchive.find(report_params)
    if report.nil?
      report = ReportArchive.new(report_params)
    end

    return api_error(status: 422, errors: report.errors) unless report.valid?

    report.save!

    render(
        json: {:status=>"ok"}
    )
  end

  private
  def report_params
    params.require(:report).permit(
        :post_id, :group_id, :informer_id, :archive_id, :user_id
    ).delete_if{ |k,v| v.nil?}
  end
end
