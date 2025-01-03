class AwsS3Controller < ApplicationController
  def new
    @aws = AwsS3.new
  end

  def create
    @aws = AwsS3.(newaws_s3_params)
    if @aws.save
      redirect_to aws_s3_path(@aws), notice: '動画が正常にアップロードされました。'
    else
      render :new
    end
  end

  def index
    @aws = AwsS3.all
  end


  private
  def aws_s3_params
    params.require(:aws_s3).permit(:title, :file_url, :thumbnail_url, :status)
  end
end
