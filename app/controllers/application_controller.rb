class ApplicationController < ActionController::Base

  def home
    if request.post?
      begin
        files = params[:files]
        @contents = process_files(files)
      rescue => e
        raise 'Something went wrong'
      end
    end
  end

  private

  def process_files(files)
    days = []
    regex = /Project (?<project_number>\d+): (?<high_low>high|low) Cost City Start Date: (?<start_date>\d{1,2}\/\d{1,2}\/\d{2}) End Date: (?<end_date>\d{1,2}\/\d{1,2}\/\d{2})/i
    
    files.each do |file|
      File.foreach(file.tempfile.path) do |line|
        match = line.match(regex)
        if match
          days.push(match.named_captures) 
        end
      end
    end
    days
  end

end
